import mongoose from 'mongoose';
import dotenv from 'dotenv';
import User from '../models/User.js';
import Institution from '../models/Institution.js';
import Equipment from '../models/Equipment.js';
import Request from '../models/Request.js';
import Notification from '../models/Notification.js';

dotenv.config();

export const clearDatabase = async () => {
  const uri = process.env.MONGODB_URI;
  if (!uri) {
    console.error('[Clear DB Error] MONGODB_URI is not set in environment.');
    process.exit(1);
  }

  try {
    console.log('[Clear DB] Connecting to MongoDB Atlas...');
    await mongoose.connect(uri, { serverSelectionTimeoutMS: 8000 });
    console.log(`[Clear DB] Connected: ${mongoose.connection.host}`);

    console.log('[Clear DB] Deleting all records across collections...');
    const [delUsers, delInstitutions, delEquipment, delRequests, delNotifications] = await Promise.all([
      User.deleteMany({}),
      Institution.deleteMany({}),
      Equipment.deleteMany({}),
      Request.deleteMany({}),
      Notification.deleteMany({}),
    ]);

    console.log(`[Clear DB] Completed database wipe:`);
    console.log(`  - Users deleted: ${delUsers.deletedCount}`);
    console.log(`  - Institutions deleted: ${delInstitutions.deletedCount}`);
    console.log(`  - Equipment deleted: ${delEquipment.deletedCount}`);
    console.log(`  - Requests deleted: ${delRequests.deletedCount}`);
    console.log(`  - Notifications deleted: ${delNotifications.deletedCount}`);

    await mongoose.connection.close();
    console.log('[Clear DB] MongoDB connection closed. Database is completely clean.');
  } catch (error) {
    console.error('[Clear DB Error] Failed to clear database:', error.message);
    process.exit(1);
  }
};

clearDatabase();
