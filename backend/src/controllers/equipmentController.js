import Equipment from '../models/Equipment.js';
import { successResponse, errorResponse } from '../utils/apiResponse.js';

export const listEquipment = async (req, res, next) => {
  try {
    const {
      search,
      category,
      condition,
      listingType,
      availability,
      minPrice,
      maxPrice,
      city,
      state,
      sort = 'newest',
      page = 1,
      limit = 12,
      featured,
    } = req.query;

    const filter = { isArchived: false };

    if (category) {
      filter.category = category;
    }

    if (condition) {
      filter.condition = condition;
    }

    if (listingType) {
      filter.listingType = listingType;
    }

    if (availability) {
      filter.availability = availability;
    }

    if (featured !== undefined) {
      filter.featured = featured === 'true' || featured === true;
    }

    if (city) {
      filter['location.city'] = { $regex: new RegExp(city, 'i') };
    }

    if (state) {
      filter['location.state'] = { $regex: new RegExp(state, 'i') };
    }

    // Price range filters
    if (minPrice !== undefined || maxPrice !== undefined) {
      const priceFilter = {};
      if (minPrice !== undefined) priceFilter.$gte = Number(minPrice);
      if (maxPrice !== undefined) priceFilter.$lte = Number(maxPrice);

      // Check either rentalPrice or purchasePrice
      filter.$or = [
        { rentalPrice: priceFilter },
        { purchasePrice: priceFilter },
      ];
    }

    // Search query
    if (search && search.trim()) {
      const searchRegex = new RegExp(search.trim(), 'i');
      filter.$or = [
        { title: searchRegex },
        { description: searchRegex },
        { category: searchRegex },
        { 'location.city': searchRegex },
        { 'location.state': searchRegex },
      ];
    }

    // Sort order
    let sortOptions = { createdAt: -1 };
    if (sort === 'price_asc') {
      sortOptions = { rentalPrice: 1, purchasePrice: 1 };
    } else if (sort === 'price_desc') {
      sortOptions = { rentalPrice: -1, purchasePrice: -1 };
    } else if (sort === 'popular') {
      sortOptions = { totalBookings: -1, createdAt: -1 };
    }

    const skip = (Number(page) - 1) * Number(limit);
    const take = Number(limit);

    const [equipmentList, total] = await Promise.all([
      Equipment.find(filter)
        .populate('ownerInstitution', 'name type city state verificationStatus')
        .populate('ownerUser', 'fullName email')
        .sort(sortOptions)
        .skip(skip)
        .limit(take),
      Equipment.countDocuments(filter),
    ]);

    const totalPages = Math.ceil(total / take) || 1;

    return successResponse(res, {
      message: 'Equipment retrieved successfully',
      data: { equipment: equipmentList },
      pagination: {
        page: Number(page),
        limit: take,
        total,
        totalPages,
      },
    });
  } catch (error) {
    next(error);
  }
};

export const getEquipmentById = async (req, res, next) => {
  try {
    const equipment = await Equipment.findOne({
      _id: req.params.id,
      isArchived: false,
    })
      .populate('ownerInstitution', 'name type city state description verificationStatus contactEmail')
      .populate('ownerUser', 'fullName email title department');

    if (!equipment) {
      return errorResponse(res, {
        statusCode: 404,
        message: 'Equipment not found',
        code: 'NOT_FOUND',
      });
    }

    return successResponse(res, {
      message: 'Equipment details retrieved successfully',
      data: { equipment },
    });
  } catch (error) {
    next(error);
  }
};

export const createEquipment = async (req, res, next) => {
  try {
    const equipmentData = {
      ...req.body,
      ownerUser: req.user._id,
      ownerInstitution: req.user.institution._id || req.user.institution,
    };

    const equipment = await Equipment.create(equipmentData);
    const populated = await Equipment.findById(equipment._id)
      .populate('ownerInstitution', 'name type city state verificationStatus')
      .populate('ownerUser', 'fullName email');

    return successResponse(res, {
      statusCode: 201,
      message: 'Equipment listing created successfully',
      data: { equipment: populated },
    });
  } catch (error) {
    next(error);
  }
};

export const updateEquipment = async (req, res, next) => {
  try {
    const equipment = await Equipment.findById(req.params.id);

    if (!equipment || equipment.isArchived) {
      return errorResponse(res, {
        statusCode: 404,
        message: 'Equipment not found',
        code: 'NOT_FOUND',
      });
    }

    // Ownership check: user must be the listing owner
    if (equipment.ownerUser.toString() !== req.user._id.toString()) {
      return errorResponse(res, {
        statusCode: 403,
        message: 'You are not authorized to edit this equipment listing',
        code: 'FORBIDDEN',
      });
    }

    Object.assign(equipment, req.body);
    await equipment.save();

    const populated = await Equipment.findById(equipment._id)
      .populate('ownerInstitution', 'name type city state verificationStatus')
      .populate('ownerUser', 'fullName email');

    return successResponse(res, {
      message: 'Equipment listing updated successfully',
      data: { equipment: populated },
    });
  } catch (error) {
    next(error);
  }
};

export const deleteEquipment = async (req, res, next) => {
  try {
    const equipment = await Equipment.findById(req.params.id);

    if (!equipment || equipment.isArchived) {
      return errorResponse(res, {
        statusCode: 404,
        message: 'Equipment not found',
        code: 'NOT_FOUND',
      });
    }

    // Ownership check
    if (equipment.ownerUser.toString() !== req.user._id.toString()) {
      return errorResponse(res, {
        statusCode: 403,
        message: 'You are not authorized to delete this equipment listing',
        code: 'FORBIDDEN',
      });
    }

    // Soft delete/archive
    equipment.isArchived = true;
    await equipment.save();

    return successResponse(res, {
      message: 'Equipment listing archived successfully',
      data: null,
    });
  } catch (error) {
    next(error);
  }
};

export const getMyEquipment = async (req, res, next) => {
  try {
    const equipmentList = await Equipment.find({
      ownerUser: req.user._id,
      isArchived: false,
    })
      .populate('ownerInstitution', 'name type city state verificationStatus')
      .sort({ createdAt: -1 });

    return successResponse(res, {
      message: 'Your equipment listings retrieved successfully',
      data: { equipment: equipmentList },
    });
  } catch (error) {
    next(error);
  }
};

export const updateAvailability = async (req, res, next) => {
  try {
    const { availability } = req.body;
    const equipment = await Equipment.findById(req.params.id);

    if (!equipment || equipment.isArchived) {
      return errorResponse(res, {
        statusCode: 404,
        message: 'Equipment not found',
        code: 'NOT_FOUND',
      });
    }

    if (equipment.ownerUser.toString() !== req.user._id.toString()) {
      return errorResponse(res, {
        statusCode: 403,
        message: 'You are not authorized to update this listing',
        code: 'FORBIDDEN',
      });
    }

    equipment.availability = availability;
    await equipment.save();

    return successResponse(res, {
      message: `Equipment availability updated to ${availability}`,
      data: { equipment },
    });
  } catch (error) {
    next(error);
  }
};
