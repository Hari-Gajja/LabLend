import { errorResponse } from '../utils/apiResponse.js';

/**
 * Zod validation middleware factory
 * @param {import('zod').ZodSchema} schema
 * @param {'body' | 'query' | 'params'} source
 */
export const validate = (schema, source = 'body') => {
  return async (req, res, next) => {
    try {
      const parsed = await schema.parseAsync(req[source]);
      req[source] = parsed;
      next();
    } catch (error) {
      const formattedErrors = error.errors?.map((err) => ({
        field: err.path.join('.'),
        message: err.message,
      })) || [{ field: 'unknown', message: error.message }];

      return errorResponse(res, {
        statusCode: 400,
        message: 'Request validation failed',
        code: 'VALIDATION_ERROR',
        errors: formattedErrors,
      });
    }
  };
};
