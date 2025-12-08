import express from 'express';
import { createServer } from 'http';
import { Server } from 'socket.io';
import cors from 'cors';
import dotenv from 'dotenv';

// Routes
import authRoutes from './routes/auth.js';
import assetsRoutes from './routes/assets.js';
import nokRoutes from './routes/nok.js';
import deathRoutes from './routes/death.js';

// Socket handlers
import { setupSocketHandlers } from './socket/handlers.js';

// Load environment variables
dotenv.config();

const app = express();
const httpServer = createServer(app);

// Socket.IO setup with CORS
const io = new Server(httpServer, {
  cors: {
    origin: '*', // For hackathon - allow all origins
    methods: ['GET', 'POST']
  }
});

// Middleware
app.use(cors());
app.use(express.json({ limit: '10mb' })); // Increased limit for base64 death certificates
app.use(express.urlencoded({ extended: true }));

// Request logging middleware
app.use((req, res, next) => {
  console.log(`📥 ${req.method} ${req.path}`);
  next();
});

// Health check
app.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'Sunset backend is running',
    timestamp: new Date().toISOString()
  });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/assets', assetsRoutes);
app.use('/api/nok', nokRoutes);
app.use('/api/death', deathRoutes);

// Root route
app.get('/', (req, res) => {
  res.json({
    name: 'Sunset API',
    version: '1.0.0',
    description: 'Post-demise financial asset management system',
    endpoints: {
      health: '/health',
      auth: '/api/auth/*',
      assets: '/api/assets/*',
      nok: '/api/nok/*',
      death: '/api/death/*'
    },
    websocket: {
      status: 'Socket.IO enabled',
      events: [
        'authenticate',
        'nok:designate',
        'nok:accept',
        'nok:reject',
        'death:certificate:uploaded',
        'death:verified:notify'
      ]
    }
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint not found'
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// Setup Socket.IO handlers
setupSocketHandlers(io);

// Make io accessible to routes (if needed)
app.set('io', io);

// Start server
const PORT = process.env.PORT || 3000;

httpServer.listen(PORT, () => {
  console.log(`
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║   🌅 Sunset Backend Server                                ║
║                                                            ║
║   Status: ✅ Running                                       ║
║   Port: ${PORT}                                            ║
║   Environment: ${process.env.NODE_ENV || 'development'}                                 ║
║                                                            ║
║   🔗 HTTP Server: http://localhost:${PORT}                  ║
║   🔌 WebSocket: ws://localhost:${PORT}                      ║
║                                                            ║
║   📡 API Endpoints:                                        ║
║      /health                                               ║
║      /api/auth/*                                           ║
║      /api/assets/*                                         ║
║      /api/nok/*                                            ║
║      /api/death/*                                          ║
║                                                            ║
║   💾 Storage: In-Memory (resets on restart)                ║
║   🔐 Mock OTP: ${process.env.MOCK_OTP || '123456'}                                       ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
  `);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, closing server...');
  httpServer.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('\nSIGINT received, closing server...');
  httpServer.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});

export default app;
