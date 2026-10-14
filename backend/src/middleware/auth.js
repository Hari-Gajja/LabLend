import jwt from 'jsonwebtoken';
import User from '../models/User.js';
import { errorResponse } from '../utils/apiResponse.js';

export const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return errorResponse(res, {
        statusCode: 401,
        message: 'Authentication token is required',
        code: 'UNAUTHORIZED',
      });
    }

    const token = authHeader.split(' ')[1];
    const secret = process.env.JWT_ACCESS_SECRET || 'lablend_default_secret_key_change_in_production';

    // Verify token signature; ignoreExpiration allows persistent sessions until explicit sign-out
    const decoded = jwt.verify(token, secret, { ignoreExpiration: true });
    const user = await User.findById(decoded.userId).populate('institution');

    if (!user) {
      return errorResponse(res, {
        statusCode: 401,
        message: 'User belonging to this token no longer exists',
        code: 'USER_NOT_FOUND',
      });
    }

    if (user.accountStatus === 'suspended') {
      return errorResponse(res, {
        statusCode: 403,
        message: 'Your account has been suspended. Please contact support.',
        code: 'ACCOUNT_SUSPENDED',
      });
    }

    req.user = user;
    next();
  } catch (error) {
    return errorResponse(res, {
      statusCode: 401,
      message: 'Invalid authentication token',
      code: 'INVALID_TOKEN',
    });
  }
};

export const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.split(' ')[1];
      const secret = process.env.JWT_ACCESS_SECRET || 'lablend_default_secret_key_change_in_production';
      const decoded = jwt.verify(token, secret, { ignoreExpiration: true });
      const user = await User.findById(decoded.userId).populate('institution');
      if (user && user.accountStatus !== 'suspended') {
        req.user = user;
      }
    }
  } catch {
    // Silently continue for optional auth
  }
  next();
};

export const generateToken = (userId) => {
  const secret = process.env.JWT_ACCESS_SECRET || 'lablend_default_secret_key_change_in_production';
  // Persistent session: token stays valid indefinitely until user explicitly logs out/signs out in the app
  return jwt.sign({ userId }, secret);
};
