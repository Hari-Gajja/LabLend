import Notification from '../models/Notification.js';

export const createNotification = async ({
  recipientUser,
  eventType,
  title,
  message,
  relatedRequest = null,
  relatedEquipment = null,
}) => {
  try {
    const notification = await Notification.create({
      recipientUser,
      eventType,
      title,
      message,
      relatedRequest,
      relatedEquipment,
    });
    return notification;
  } catch (error) {
    console.error('[Notification Service Error] Failed to create notification:', error.message);
    // Non-blocking error: notification failure should not abort primary request
    return null;
  }
};
