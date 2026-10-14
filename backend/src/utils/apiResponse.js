/**
 * Standardized API Response Helpers for LabLend
 */

export const successResponse = (res, {
  statusCode = 200,
  message = 'Success',
  data = {},
  pagination = null
}) => {
  const response = {
    success: true,
    message,
    data,
  };

  if (pagination) {
    response.pagination = pagination;
  }

  return res.status(statusCode).json(response);
};

export const errorResponse = (res, {
  statusCode = 500,
  message = 'An unexpected error occurred',
  code = 'INTERNAL_ERROR',
  errors = []
}) => {
  return res.status(statusCode).json({
    success: false,
    message,
    code,
    errors
  });
};
