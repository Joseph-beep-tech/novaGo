/**
 * Mock wwebjs-api Server for Development
 * Provides all endpoints needed for NovaGo backend to communicate
 * Based on wa.dt.wrld-main wwebjs-api expected responses
 */

const http = require('http');
const url = require('url');
const PORT = 3000;

// In-memory session store
const sessions = {};

// Generate a simple PNG QR code placeholder (1x1 pixel)
const qrCodePNG = Buffer.from([
  0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x0d, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53,
  0xde, 0x00, 0x00, 0x00, 0x0c, 0x49, 0x44, 0x41, 0x54, 0x08, 0x99, 0x01, 0x01, 0x00, 0x00, 0xfe,
  0xff, 0x00, 0x00, 0x00, 0x02, 0x00, 0x01, 0x22, 0xb6, 0xee, 0x56, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82
]);

const server = http.createServer((req, res) => {
  const parsedUrl = url.parse(req.url, true);
  const pathname = parsedUrl.pathname;

  // Enable CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, x-api-key');
  
  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  // Health check
  if (pathname === '/health' && req.method === 'GET') {
    res.setHeader('Content-Type', 'application/json');
    res.writeHead(200);
    res.end(JSON.stringify({ success: true, message: 'wwebjs-api mock running' }));
    return;
  }

  // Ping endpoint
  if (pathname === '/ping' && req.method === 'GET') {
    res.setHeader('Content-Type', 'application/json');
    res.writeHead(200);
    res.end(JSON.stringify({ success: true }));
    return;
  }

  // Session endpoints
  if (pathname.startsWith('/session/')) {
    const parts = pathname.split('/').filter(p => p);
    const sessionId = parts[1];

    // GET /session/start/:sessionId - START a new session
    if (parts.length === 3 && parts[2] === 'start' && req.method === 'GET') {
      sessions[sessionId] = {
        sessionId,
        state: 'SCAN_QR_CODE',
        authenticated: false,
        timestamp: Date.now()
      };
      res.setHeader('Content-Type', 'application/json');
      res.writeHead(200);
      res.end(JSON.stringify({
        success: true,
        data: {
          sessionId,
          state: 'SCAN_QR_CODE',
          authenticated: false
        }
      }));
      console.log(`📱 Session ${sessionId} started - waiting for QR scan`);
      return;
    }

    // GET /session/status/:sessionId - GET session status
    if (parts.length === 3 && parts[2] === 'status' && req.method === 'GET') {
      const session = sessions[sessionId] || { state: 'DISCONNECTED', authenticated: false };
      res.setHeader('Content-Type', 'application/json');
      res.writeHead(200);
      res.end(JSON.stringify({
        success: true,
        data: session
      }));
      return;
    }

    // GET /session/getSessions - LIST all sessions
    if (parts.length === 2 && parts[1] === 'getSessions' && req.method === 'GET') {
      res.setHeader('Content-Type', 'application/json');
      res.writeHead(200);
      res.end(JSON.stringify(Object.values(sessions)));
      console.log(`📋 Listed ${Object.keys(sessions).length} sessions`);
      return;
    }

    // GET /session/:sessionId/qr - GET QR code as base64 data
    if (parts.length === 3 && parts[2] === 'qr' && req.method === 'GET') {
      res.setHeader('Content-Type', 'application/json');
      res.writeHead(200);
      res.end(JSON.stringify({
        success: true,
        qr: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=='
      }));
      return;
    }

    // GET /session/:sessionId/qr/image - GET QR code as PNG image
    if (parts.length === 4 && parts[2] === 'qr' && parts[3] === 'image' && req.method === 'GET') {
      res.setHeader('Content-Type', 'image/png');
      res.writeHead(200);
      res.end(qrCodePNG);
      console.log(`🖼️  QR image requested for session ${sessionId}`);
      return;
    }

    // GET /session/:sessionId/terminate - TERMINATE session
    if (parts.length === 3 && parts[2] === 'terminate' && req.method === 'GET') {
      delete sessions[sessionId];
      res.setHeader('Content-Type', 'application/json');
      res.writeHead(200);
      res.end(JSON.stringify({
        success: true,
        message: `Session ${sessionId} terminated`
      }));
      console.log(`❌ Session ${sessionId} terminated`);
      return;
    }

    // GET /session/:sessionId/restart - RESTART session
    if (parts.length === 3 && parts[2] === 'restart' && req.method === 'GET') {
      sessions[sessionId] = {
        sessionId,
        state: 'SCAN_QR_CODE',
        authenticated: false,
        timestamp: Date.now()
      };
      res.setHeader('Content-Type', 'application/json');
      res.writeHead(200);
      res.end(JSON.stringify({
        success: true,
        data: { sessionId, state: 'SCAN_QR_CODE', authenticated: false }
      }));
      console.log(`🔄 Session ${sessionId} restarted`);
      return;
    }
  }

  // Chat endpoints
  if (pathname.startsWith('/chats')) {
    res.setHeader('Content-Type', 'application/json');
    res.writeHead(200);
    res.end(JSON.stringify({ success: true, data: [] }));
    return;
  }

  // Default 404
  res.setHeader('Content-Type', 'application/json');
  res.writeHead(404);
  res.end(JSON.stringify({ success: false, error: 'Endpoint not found' }));
});

server.listen(PORT, () => {
  console.log(`✅ Mock wwebjs-api server listening on http://localhost:${PORT}`);
  console.log(`📌 Development mode - endpoints:`);
  console.log(`   GET  /health`);
  console.log(`   GET  /ping`);
  console.log(`   GET  /session/start/:sessionId`);
  console.log(`   GET  /session/status/:sessionId`);
  console.log(`   GET  /session/getSessions`);
  console.log(`   GET  /session/:sessionId/qr`);
  console.log(`   GET  /session/:sessionId/qr/image`);
  console.log(`   GET  /session/:sessionId/terminate`);
  console.log(`   GET  /session/:sessionId/restart`);
});
