import { generateUploadSignature, deleteCloudinaryAsset } from '../config/cloudinary.js';
import Equipment from '../models/Equipment.js';
import { successResponse, errorResponse } from '../utils/apiResponse.js';

export const getSignature = async (req, res, next) => {
  try {
    const folder = req.query.folder || 'lablend/equipment';

    // If Cloudinary secret is not set, provide simulated signature info
    if (!process.env.CLOUDINARY_API_SECRET) {
      return successResponse(res, {
        message: 'Simulation signature generated (Cloudinary API secrets not set in .env)',
        data: {
          signature: 'simulated_dev_signature_' + Date.now(),
          timestamp: Math.round(Date.now() / 1000),
          folder,
          cloudName: process.env.CLOUDINARY_CLOUD_NAME || 'demo',
          apiKey: process.env.CLOUDINARY_API_KEY || '1234567890',
          simulated: true,
        },
      });
    }

    const signatureData = generateUploadSignature(folder);
    return successResponse(res, {
      message: 'Upload signature generated',
      data: signatureData,
    });
  } catch (error) {
    next(error);
  }
};

export const deleteAsset = async (req, res, next) => {
  try {
    const { publicId } = req.params;

    if (!publicId) {
      return errorResponse(res, {
        statusCode: 400,
        message: 'Public ID is required',
        code: 'MISSING_PARAM',
      });
    }

    // Verify ownership: ensure the public ID belongs to an equipment owned by req.user
    const equipment = await Equipment.findOne({
      ownerUser: req.user._id,
      'images.publicId': publicId,
    });

    if (!equipment) {
      return errorResponse(res, {
        statusCode: 403,
        message: 'You are not authorized to delete this asset or the asset was not found',
        code: 'FORBIDDEN',
      });
    }

    if (process.env.CLOUDINARY_API_SECRET) {
      await deleteCloudinaryAsset(publicId);
    }

    // Remove from equipment images array
    equipment.images = equipment.images.filter((img) => img.publicId !== publicId);
    await equipment.save();

    return successResponse(res, {
      message: 'Asset removed successfully',
      data: null,
    });
  } catch (error) {
    next(error);
  }
};
