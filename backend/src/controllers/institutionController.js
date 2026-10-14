import Institution from '../models/Institution.js';
import { successResponse, errorResponse } from '../utils/apiResponse.js';

export const listInstitutions = async (req, res, next) => {
  try {
    const institutions = await Institution.find().select('name type city state country verificationStatus').sort({ name: 1 });
    return successResponse(res, {
      message: 'Institutions retrieved successfully',
      data: { institutions },
    });
  } catch (error) {
    next(error);
  }
};

export const getMyInstitution = async (req, res, next) => {
  try {
    const institution = await Institution.findById(req.user.institution);
    if (!institution) {
      return errorResponse(res, {
        statusCode: 404,
        message: 'Institution profile not found',
        code: 'NOT_FOUND',
      });
    }

    return successResponse(res, {
      message: 'Institution retrieved successfully',
      data: { institution },
    });
  } catch (error) {
    next(error);
  }
};

export const updateMyInstitution = async (req, res, next) => {
  try {
    const { name, description, address, city, state, postalCode, contactNumber } = req.body;

    const institution = await Institution.findById(req.user.institution);
    if (!institution) {
      return errorResponse(res, {
        statusCode: 404,
        message: 'Institution not found',
        code: 'NOT_FOUND',
      });
    }

    if (name) institution.name = name.trim();
    if (description !== undefined) institution.description = description.trim();
    if (address !== undefined) institution.address = address.trim();
    if (city) institution.city = city.trim();
    if (state) institution.state = state.trim();
    if (postalCode !== undefined) institution.postalCode = postalCode.trim();
    if (contactNumber !== undefined) institution.contactNumber = contactNumber.trim();

    await institution.save();

    return successResponse(res, {
      message: 'Institution updated successfully',
      data: { institution },
    });
  } catch (error) {
    next(error);
  }
};

export const getInstitutionById = async (req, res, next) => {
  try {
    const institution = await Institution.findById(req.params.id).select(
      'name type description city state country verificationStatus createdAt'
    );

    if (!institution) {
      return errorResponse(res, {
        statusCode: 404,
        message: 'Institution not found',
        code: 'NOT_FOUND',
      });
    }

    return successResponse(res, {
      message: 'Institution retrieved successfully',
      data: { institution },
    });
  } catch (error) {
    next(error);
  }
};
