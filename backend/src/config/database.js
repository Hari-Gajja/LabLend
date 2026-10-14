import mongoose from 'mongoose';

let memoryServer = null;

export const connectDB = async () => {
  if (mongoose.connection.readyState === 1) {
    return mongoose.connection;
  }

  const uri = process.env.MONGODB_URI || 'mongodb://localhost:27017/lablend';
  const forceMemory = process.env.USE_MEMORY_DB === 'true';

  if (!forceMemory) {
    try {
      const conn = await mongoose.connect(uri, {
        serverSelectionTimeoutMS: 8000,
        autoIndex: process.env.NODE_ENV !== 'production',
      });
      console.log(`[Database] MongoDB Connected: ${conn.connection.host}`);
      return conn;
    } catch (error) {
      console.warn(`[Database Warning] External MongoDB unreachable (${error.message}).`);
    }
  }

  // Fallback to In-Memory MongoDB Server
  console.log('[Database] Initializing In-Memory MongoDB Server fallback...');
  try {
    const { MongoMemoryServer } = await import('mongodb-memory-server');
    memoryServer = await MongoMemoryServer.create();
    const memoryUri = memoryServer.getUri();
    const conn = await mongoose.connect(memoryUri, {
      autoIndex: true,
    });
    console.log(`[Database] Connected to In-Memory MongoDB: ${memoryUri}`);

    return conn;
  } catch (memError) {
    console.error(`[Database Error] In-Memory MongoDB initialization failed: ${memError.message}`);
    if (process.env.NODE_ENV === 'production') {
      process.exit(1);
    }
  }
};

export const disconnectDB = async () => {
  try {
    if (mongoose.connection.readyState !== 0) {
      await mongoose.connection.close();
      console.log('[Database] MongoDB connection closed');
    }
    if (memoryServer) {
      await memoryServer.stop();
      console.log('[Database] In-Memory MongoDB stopped');
      memoryServer = null;
    }
  } catch (error) {
    console.error(`[Database Error] Disconnect error: ${error.message}`);
  }
};

