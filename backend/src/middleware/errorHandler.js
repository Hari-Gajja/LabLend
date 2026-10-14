import { errorResponse } from '../utils/apiResponse.js';

export const errorHandler = (err, req, res, next) => {
  console.error('[Error Details]', {
    message: err.message,
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined,
    path: req.originalUrl,
    method: req.method,
  });

  // Mongoose validation error
  if (err.name === 'ValidationError') {
    const errors = Object.values(err.errors).map((el) => ({
      field: el.path,
      message: el.message,
    }));
    return errorResponse(res, {
      statusCode: 400,
      message: 'Database validation failed',
      code: 'VALIDATION_ERROR',
      errors,
    });
  }

  // Mongoose duplicate key error (code 11000)
  if (err.code === 11000) {
    const field = Object.keys(err.keyValue || {})[0] || 'field';
    return errorResponse(res, {
      statusCode: 409,
      message: `An entry with this ${field} already exists`,
      code: 'DUPLICATE_KEY_ERROR',
      errors: [{ field, message: `${field} must be unique` }],
    });
  }

  // Mongoose CastError (e.g. invalid ObjectId)
  if (err.name === 'CastError') {
    return errorResponse(res, {
      statusCode: 400,
      message: `Invalid format for parameter: ${err.path}`,
      code: 'INVALID_ID_FORMAT',
      errors: [{ field: err.path, message: `Invalid ID: ${err.value}` }],
    });
  }

  // Multer file upload errors
  if (err.name === 'MulterError') {
    return errorResponse(res, {
      statusCode: 400,
      message: `File upload error: ${err.message}`,
      code: 'UPLOAD_ERROR',
    });
  }

  // JSON syntax error in request body
  if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
    return errorResponse(res, {
      statusCode: 400,
      message: 'Invalid JSON payload in request body',
      code: 'INVALID_JSON',
    });
  }

  // Default fallback
  const statusCode = err.statusCode || 500;
  const message = err.isOperational || process.env.NODE_ENV === 'development'
    ? err.message
    : 'Internal server error';

  return errorResponse(res, {
    statusCode,
    message,
    code: err.code || 'SERVER_ERROR',
  });
};
