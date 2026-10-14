import Request from '../models/Request.js';
import Equipment from '../models/Equipment.js';
import { checkRentalOverlap } from '../services/requestService.js';
import { createNotification } from '../services/notificationService.js';
import { successResponse, errorResponse } from '../utils/apiResponse.js';

export const createRequest = async (req, res, next) => {
  try {
    const {
      equipmentId,
      requestType,
      requestedQuantity = 1,
      rentalStartDate,
      rentalEndDate,
      intendedUse,
      message,
    } = req.body;

    const equipment = await Equipment.findById(equipmentId);
    if (!equipment || equipment.isArchived) {
      return errorResponse(res, {
        statusCode: 404,
        message: 'Equipment not found or no longer available',
        code: 'EQUIPMENT_NOT_FOUND',
      });
    }

    // Requester cannot request their own equipment
    if (equipment.ownerUser.toString() === req.user._id.toString()) {
      return errorResponse(res, {
        statusCode: 400,
        message: 'You cannot request your own equipment',
        code: 'SELF_REQUEST_PROHIBITED',
      });
    }

    // Normalize requestType to canonical 'rental' or 'purchase'
    const normalizedRequestType = (requestType === 'buy' || requestType === 'purchase')
      ? 'purchase'
      : 'rental';

    // Verify listing supports the requested type
    const isRental = normalizedRequestType === 'rental';
    const isPurchase = normalizedRequestType === 'purchase';

    const supportsRental = equipment.listingType === 'both' || equipment.listingType === 'rent';
    const supportsPurchase = equipment.listingType === 'both' || equipment.listingType === 'buy';

    if (isRental && !supportsRental) {
      return errorResponse(res, {
        statusCode: 400,
        message: `This equipment is only available for ${equipment.listingType === 'buy' ? 'purchase' : equipment.listingType}`,
        code: 'INVALID_REQUEST_TYPE',
      });
    }

    if (isPurchase && !supportsPurchase) {
      return errorResponse(res, {
        statusCode: 400,
        message: `This equipment is only available for ${equipment.listingType === 'rent' ? 'rental' : equipment.listingType}`,
        code: 'INVALID_REQUEST_TYPE',
      });
    }

    // For rental requests, check for conflicting approved bookings
    if (isRental) {
      const conflicts = await checkRentalOverlap(equipmentId, rentalStartDate, rentalEndDate);
      if (conflicts.length > 0) {
        return errorResponse(res, {
          statusCode: 409,
          message: 'The requested dates conflict with an existing approved reservation for this equipment',
          code: 'RENTAL_DATE_CONFLICT',
        });
      }
    }

    const newRequest = await Request.create({
      requesterUser: req.user._id,
      requesterInstitution: req.user.institution._id || req.user.institution,
      equipment: equipment._id,
      listingOwner: equipment.ownerUser,
      requestType: normalizedRequestType,
      requestedQuantity,
      rentalStartDate: isRental && rentalStartDate ? new Date(rentalStartDate) : null,
      rentalEndDate: isRental && rentalEndDate ? new Date(rentalEndDate) : null,
      intendedUse,
      message,
      status: 'pending',
    });

    // Notify listing owner
    await createNotification({
      recipientUser: equipment.ownerUser,
      eventType: 'request_created',
      title: `New ${requestType} request for ${equipment.title}`,
      message: `${req.user.fullName} from ${req.user.institution?.name || 'an institution'} submitted a ${requestType} request.`,
      relatedRequest: newRequest._id,
      relatedEquipment: equipment._id,
    });

    const populated = await Request.findById(newRequest._id)
      .populate('equipment', 'title category images rentalPrice rentalPricingUnit purchasePrice')
      .populate('requesterUser', 'fullName email title')
      .populate('requesterInstitution', 'name city state verificationStatus');

    return successResponse(res, {
      statusCode: 201,
      message: 'Request submitted successfully',
      data: { request: populated },
    });
  } catch (error) {
    next(error);
  }
};

export const getSentRequests = async (req, res, next) => {
  try {
    const requests = await Request.find({ requesterUser: req.user._id })
      .populate('equipment', 'title category condition images rentalPrice rentalPricingUnit purchasePrice location')
      .populate('listingOwner', 'fullName email')
      .populate('requesterInstitution', 'name city state verificationStatus')
      .sort({ createdAt: -1 });

    return successResponse(res, {
      message: 'Sent requests retrieved successfully',
      data: { requests },
    });
  } catch (error) {
    next(error);
  }
};

export const getReceivedRequests = async (req, res, next) => {
  try {
    const requests = await Request.find({ listingOwner: req.user._id })
      .populate('equipment', 'title category condition images rentalPrice rentalPricingUnit purchasePrice location')
      .populate('requesterUser', 'fullName email title department contactNumber')
      .populate('requesterInstitution', 'name city state verificationStatus contactEmail')
      .sort({ createdAt: -1 });

    return successResponse(res, {
      message: 'Received requests retrieved successfully',
      data: { requests },
    });
  } catch (error) {
    next(error);
  }
};

export const getRequestById = async (req, res, next) => {
  try {
    const request = await Request.findById(req.params.id)
      .populate('equipment')
      .populate('requesterUser', 'fullName email title department contactNumber')
      .populate('requesterInstitution', 'name type city state verificationStatus')
      .populate('listingOwner', 'fullName email');

    if (!request) {
      return errorResponse(res, {
        statusCode: 404,
        message: 'Request not found',
        code: 'NOT_FOUND',
      });
    }

    // Authorization: only requester or listing owner can view
    const userId = req.user._id.toString();
    const isRequester = request.requesterUser._id.toString() === userId;
    const isOwner = request.listingOwner._id.toString() === userId;

    if (!isRequester && !isOwner) {
      return errorResponse(res, {
        statusCode: 403,
        message: 'You are not authorized to view this request',
        code: 'FORBIDDEN',
      });
    }

    return successResponse(res, {
      message: 'Request details retrieved successfully',
      data: { request },
    });
  } catch (error) {
    next(error);
  }
};

export const approveRequest = async (req, res, next) => {
  try {
    const request = await Request.findById(req.params.id).populate('equipment');

    if (!request) {
      return errorResponse(res, {
        statusCode: 404,
        message: 'Request not found',
        code: 'NOT_FOUND',
      });
    }

    // Only listing owner can approve
    if (request.listingOwner.toString() !== req.user._id.toString()) {
      return errorResponse(res, {
        statusCode: 403,
        message: 'Only the equipment owner can approve this request',
        code: 'FORBIDDEN',
      });
    }

    if (request.status !== 'pending') {
      return errorResponse(res, {
        statusCode: 400,
        message: `Cannot approve request with current status: ${request.status}`,
        code: 'INVALID_STATUS_TRANSITION',
      });
    }

    // If rental, re-check overlap before approving (concurrency protection)
    if (request.requestType === 'rental') {
      const conflicts = await checkRentalOverlap(
        request.equipment._id,
        request.rentalStartDate,
        request.rentalEndDate,
        request._id
      );
      if (conflicts.length > 0) {
        return errorResponse(res, {
          statusCode: 409,
          message: 'Cannot approve: another overlapping rental has already been approved for these dates',
          code: 'RENTAL_DATE_CONFLICT',
        });
      }
    }

    request.status = 'approved';
    request.decisionMetadata = {
      decidedAt: new Date(),
      decidedBy: req.user._id,
      notes: req.body.notes || '',
    };
    await request.save();

    // Increment booking count on equipment
    await Equipment.findByIdAndUpdate(request.equipment._id, { $inc: { totalBookings: 1 } });

    // Notify requester
    await createNotification({
      recipientUser: request.requesterUser,
      eventType: 'request_approved',
      title: `Request Approved: ${request.equipment.title}`,
      message: `Your ${request.requestType} request for ${request.equipment.title} has been approved.`,
      relatedRequest: request._id,
      relatedEquipment: request.equipment._id,
    });

    return successResponse(res, {
      message: 'Request approved successfully',
      data: { request },
    });
  } catch (error) {
    next(error);
  }
};

export const rejectRequest = async (req, res, next) => {
  try {
    const request = await Request.findById(req.params.id).populate('equipment');

    if (!request) {
      return errorResponse(res, {
        statusCode: 404,
        message: 'Request not found',
        code: 'NOT_FOUND',
      });
    }

    // Only listing owner can reject
    if (request.listingOwner.toString() !== req.user._id.toString()) {
      return errorResponse(res, {
        statusCode: 403,
        message: 'Only the equipment owner can reject this request',
        code: 'FORBIDDEN',
      });
    }

    if (request.status !== 'pending') {
      return errorResponse(res, {
        statusCode: 400,
        message: `Cannot reject request with status: ${request.status}`,
        code: 'INVALID_STATUS_TRANSITION',
      });
    }

    request.status = 'rejected';
    request.decisionMetadata = {
      decidedAt: new Date(),
      decidedBy: req.user._id,
      reason: req.body.reason,
    };
    await request.save();

    // Notify requester
    await createNotification({
      recipientUser: request.requesterUser,
      eventType: 'request_rejected',
      title: `Request Declined: ${request.equipment.title}`,
      message: `Your ${request.requestType} request was declined. Reason: ${req.body.reason}`,
      relatedRequest: request._id,
      relatedEquipment: request.equipment._id,
    });

    return successResponse(res, {
      message: 'Request rejected',
      data: { request },
    });
  } catch (error) {
    next(error);
  }
};

export const cancelRequest = async (req, res, next) => {
  try {
    const request = await Request.findById(req.params.id).populate('equipment');

    if (!request) {
      return errorResponse(res, {
        statusCode: 404,
        message: 'Request not found',
        code: 'NOT_FOUND',
      });
    }

    // Only requester can cancel
    if (request.requesterUser.toString() !== req.user._id.toString()) {
      return errorResponse(res, {
        statusCode: 403,
        message: 'Only the requester can cancel this request',
        code: 'FORBIDDEN',
      });
    }

    if (request.status !== 'pending' && request.status !== 'approved') {
      return errorResponse(res, {
        statusCode: 400,
        message: `Cannot cancel a request that is already ${request.status}`,
        code: 'INVALID_STATUS_TRANSITION',
      });
    }

    request.status = 'cancelled';
    request.cancellationMetadata = {
      cancelledAt: new Date(),
      cancelledBy: req.user._id,
      reason: req.body.reason || 'Cancelled by requester',
    };
    await request.save();

    // Notify owner
    await createNotification({
      recipientUser: request.listingOwner,
      eventType: 'request_cancelled',
      title: `Request Cancelled: ${request.equipment.title}`,
      message: `The requester cancelled their ${request.requestType} request for ${request.equipment.title}.`,
      relatedRequest: request._id,
      relatedEquipment: request.equipment._id,
    });

    return successResponse(res, {
      message: 'Request cancelled successfully',
      data: { request },
    });
  } catch (error) {
    next(error);
  }
};

export const completeRequest = async (req, res, next) => {
  try {
    const request = await Request.findById(req.params.id).populate('equipment');

    if (!request) {
      return errorResponse(res, {
        statusCode: 404,
        message: 'Request not found',
        code: 'NOT_FOUND',
      });
    }

    const userId = req.user._id.toString();
    const isOwner = request.listingOwner.toString() === userId;
    const isRequester = request.requesterUser.toString() === userId;

    if (!isOwner && !isRequester) {
      return errorResponse(res, {
        statusCode: 403,
        message: 'You are not authorized to complete this request',
        code: 'FORBIDDEN',
      });
    }

    if (request.status !== 'approved') {
      return errorResponse(res, {
        statusCode: 400,
        message: `Cannot complete a request with status: ${request.status}. It must be approved first.`,
        code: 'INVALID_STATUS_TRANSITION',
      });
    }

    request.status = 'completed';
    request.completionMetadata = {
      completedAt: new Date(),
      notes: req.body.notes || 'Transaction/loan completed successfully',
    };
    await request.save();

    // Notify the other party
    const otherUser = isOwner ? request.requesterUser : request.listingOwner;
    await createNotification({
      recipientUser: otherUser,
      eventType: 'request_completed',
      title: `Request Completed: ${request.equipment.title}`,
      message: `The loan/purchase for ${request.equipment.title} has been marked as completed.`,
      relatedRequest: request._id,
      relatedEquipment: request.equipment._id,
    });

    return successResponse(res, {
      message: 'Request marked as completed',
      data: { request },
    });
  } catch (error) {
    next(error);
  }
};
