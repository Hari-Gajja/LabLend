import crypto from 'crypto';
import User from '../models/User.js';
import Institution from '../models/Institution.js';
import { generateToken } from '../middleware/auth.js';
import { successResponse, errorResponse } from '../utils/apiResponse.js';

export const register = async (req, res, next) => {
  try {
    const {
      fullName,
      email,
      password,
      institutionName,
      institutionType,
      city,
      state,
      contactNumber,
      department,
      title,
    } = req.body;

    const existingUser = await User.findOne({ email: email.toLowerCase() });
    if (existingUser) {
      return errorResponse(res, {
        statusCode: 409,
        message: 'A user with this institutional email already exists',
        code: 'EMAIL_ALREADY_EXISTS',
      });
    }

    // Find or create institution
    let institution = await Institution.findOne({
      name: { $regex: new RegExp(`^${institutionName.trim()}$`, 'i') },
      city: { $regex: new RegExp(`^${city.trim()}$`, 'i') },
    });

    if (!institution) {
      institution = await Institution.create({
        name: institutionName.trim(),
        type: institutionType,
        city: city.trim(),
        state: state.trim(),
        contactEmail: email.toLowerCase(),
        contactNumber: contactNumber || '',
        verificationStatus: 'unverified',
      });
    }

    const passwordHash = await User.hashPassword(password);

    const user = await User.create({
      fullName,
      email: email.toLowerCase(),
      passwordHash,
      contactNumber,
      department,
      title,
      institution: institution._id,
      lastLogin: new Date(),
    });

    const token = generateToken(user._id);
    const populatedUser = await User.findById(user._id).populate('institution');

    return successResponse(res, {
      statusCode: 201,
      message: 'Registration successful',
      data: {
        user: populatedUser,
        token,
      },
    });
  } catch (error) {
    next(error);
  }
};

export const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email: email.toLowerCase() }).populate('institution');
    if (!user) {
      return errorResponse(res, {
        statusCode: 401,
        message: 'Invalid email or password',
        code: 'INVALID_CREDENTIALS',
      });
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return errorResponse(res, {
        statusCode: 401,
        message: 'Invalid email or password',
        code: 'INVALID_CREDENTIALS',
      });
    }

    if (user.accountStatus === 'suspended') {
      return errorResponse(res, {
        statusCode: 403,
        message: 'Your account has been suspended. Please contact support.',
        code: 'ACCOUNT_SUSPENDED',
      });
    }

    user.lastLogin = new Date();
    await user.save();

    const token = generateToken(user._id);

    return successResponse(res, {
      message: 'Login successful',
      data: {
        user,
        token,
      },
    });
  } catch (error) {
    next(error);
  }
};

export const logout = async (req, res) => {
  return successResponse(res, {
    message: 'Logged out successfully',
    data: null,
  });
};

export const getMe = async (req, res) => {
  return successResponse(res, {
    message: 'User profile retrieved',
    data: {
      user: req.user,
    },
  });
};

export const forgotPassword = async (req, res, next) => {
  try {
    const { email } = req.body;
    const user = await User.findOne({ email: email.toLowerCase() });

    if (!user) {
      // Return 200 with generic message for privacy protection
      return successResponse(res, {
        message: 'If that email exists in our records, password reset instructions have been generated.',
        data: null,
      });
    }

    const resetToken = crypto.randomBytes(32).toString('hex');
    const tokenHash = crypto.createHash('sha256').update(resetToken).digest('hex');

    user.resetPasswordToken = tokenHash;
    user.resetPasswordExpires = new Date(Date.now() + 60 * 60 * 1000); // 1 hour
    await user.save();

    console.log(`[Password Reset Simulation] Token for ${user.email}: ${resetToken}`);

    return successResponse(res, {
      message: 'If that email exists in our records, password reset instructions have been generated.',
      data: process.env.NODE_ENV === 'development' ? { resetToken } : null,
    });
  } catch (error) {
    next(error);
  }
};

export const resetPassword = async (req, res, next) => {
  try {
    const { token, newPassword } = req.body;
    const tokenHash = crypto.createHash('sha256').update(token).digest('hex');

    const user = await User.findOne({
      resetPasswordToken: tokenHash,
      resetPasswordExpires: { $gt: new Date() },
    });

    if (!user) {
      return errorResponse(res, {
        statusCode: 400,
        message: 'Password reset token is invalid or has expired',
        code: 'INVALID_RESET_TOKEN',
      });
    }

    user.passwordHash = await User.hashPassword(newPassword);
    user.resetPasswordToken = null;
    user.resetPasswordExpires = null;
    await user.save();

    return successResponse(res, {
      message: 'Password has been successfully updated. You may now log in.',
      data: null,
    });
  } catch (error) {
    next(error);
  }
};
