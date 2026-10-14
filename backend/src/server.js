import app from './app.js';
import { connectDB, disconnectDB } from './config/database.js';

const PORT = process.env.PORT || 5000;

// Connect to MongoDB before accepting traffic
await connectDB();

const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`===============================================`);
  console.log(`  🔬 LabLend REST API Service`);
  console.log(`  🚀 Server listening on http://0.0.0.0:${PORT}`);
  console.log(`  🌐 Health check: http://localhost:${PORT}/api/v1/health`);
  console.log(`===============================================`);
});

// Graceful shutdown handling
const handleShutdown = async (signal) => {
  console.log(`\n[Server] Received ${signal}. Starting graceful shutdown...`);
  server.close(async () => {
    console.log('[Server] HTTP server closed.');
    await disconnectDB();
    process.exit(0);
  });

  // Force shutdown if taking too long
  setTimeout(() => {
    console.error('[Server] Forced shutdown after timeout');
    process.exit(1);
  }, 10000);
};

process.on('SIGTERM', () => handleShutdown('SIGTERM'));
process.on('SIGINT', () => handleShutdown('SIGINT'));
