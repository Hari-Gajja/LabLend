import Notification from '../models/Notification.js';
import { successResponse, errorResponse } from '../utils/apiResponse.js';

export const getNotifications = async (req, res, next) => {
  try {
    const [notifications, unreadCount] = await Promise.all([
      Notification.find({ recipientUser: req.user._id })
        .sort({ createdAt: -1 })
        .limit(50),
      Notification.countDocuments({
        recipientUser: req.user._id,
        isRead: false,
      }),
    ]);

    return successResponse(res, {
      message: 'Notifications retrieved successfully',
      data: {
        notifications,
        unreadCount,
      },
    });
  } catch (error) {
    next(error);
  }
};

export const markAsRead = async (req, res, next) => {
  try {
    const notification = await Notification.findOne({
      _id: req.params.id,
      recipientUser: req.user._id,
    });

    if (!notification) {
      return errorResponse(res, {
        statusCode: 404,
        message: 'Notification not found',
        code: 'NOT_FOUND',
      });
    }

    notification.isRead = true;
    await notification.save();

    return successResponse(res, {
      message: 'Notification marked as read',
      data: { notification },
    });
  } catch (error) {
    next(error);
  }
};

export const markAllAsRead = async (req, res, next) => {
  try {
    await Notification.updateMany(
      { recipientUser: req.user._id, isRead: false },
      { $set: { isRead: true } }
    );

    return successResponse(res, {
      message: 'All notifications marked as read',
      data: null,
    });
  } catch (error) {
    next(error);
  }
};
