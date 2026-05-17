/**
 * mock-wwebjs-api.js
 *
 * Development mock of kulemantu/wwebjs-api.
 * Run with:  node mock-wwebjs-api.js
 *
 * Simulates the full session lifecycle:
 *   1. start  → INITIALIZING → SCAN_QR_CODE (after 2s)
 *   2. Status polling returns SCAN_QR_CODE with a real QR PNG
 *   3. After 30s auto-connects (or send GET /session/:id/mock-connect to connect instantly)
 *
 * URL patterns match kulemantu/wwebjs-api:
 *   GET /session/getSessions
 *   GET /session/:sessionId/start
 *   GET /session/:sessionId/status
 *   GET /session/:sessionId/qr          → JSON { success, qr: "data:image/png;base64,..." }
 *   GET /session/:sessionId/qr/image    → PNG binary
 *   GET /session/:sessionId/terminate
 *   GET /session/:sessionId/restart
 *   GET /session/:sessionId/mock-connect  (dev helper — simulate successful scan)
 *   GET /ping
 *   GET /health
 */

const http = require('http');
const url  = require('url');
const PORT = 3000;

// In-memory sessions
const sessions = {};

// ── Minimal real QR PNG (a 21×21 white/black QR-like pattern encoded as PNG) ──
// This is a real 29-byte minimal PNG that browsers can display
function makeQrPng() {
  // We generate a simple 100×100 black-and-white checkerboard PNG
  // as a placeholder that looks like a QR code in the UI
  const width = 100, height = 100;
  const rowSize = width + 1; // 1 filter byte + width pixels
  const raw = Buffer.alloc(rowSize * height);
  for (let y = 0; y < height; y++) {
    raw[y * rowSize] = 0; // filter type None
    for (let x = 0; x < width; x++) {
      // Checkerboard every 5px to simulate QR modules
      const v = ((Math.floor(x / 5) + Math.floor(y / 5)) % 2 === 0) ? 0 : 255;
      raw[y * rowSize + 1 + x] = v;
    }
  }

  // zlib compress using Node's built-in zlib
  const zlib = require('zlib');
  const compressed = zlib.deflateSync(raw, { level: 9 });

  function crc32(buf) {
    const table = [];
    for (let n = 0; n < 256; n++) {
      let c = n;
      for (let k = 0; k < 8; k++) c = (c & 1) ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
      table[n] = c;
    }
    let crc = 0xffffffff;
    for (const byte of buf) crc = table[(crc ^ byte) & 0xff] ^ (crc >>> 8);
    return (crc ^ 0xffffffff) >>> 0;
  }

  function chunk(type, data) {
    const typeBytes = Buffer.from(type);
    const len = Buffer.alloc(4); len.writeUInt32BE(data.length, 0);
    const payload = Buffer.concat([typeBytes, data]);
    const crc = Buffer.alloc(4); crc.writeUInt32BE(crc32(payload), 0);
    return Buffer.concat([len, payload, crc]);
  }

  const sig    = Buffer.from([137,80,78,71,13,10,26,10]);
  const ihdr   = Buffer.alloc(13);
  ihdr.writeUInt32BE(width,  0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8;  // bit depth
  ihdr[9] = 0;  // colour type: greyscale
  const idat   = compressed;
  const iend   = Buffer.alloc(0);

  return Buffer.concat([
    sig,
    chunk('IHDR', ihdr),
    chunk('IDAT', idat),
    chunk('IEND', iend),
  ]);
}

const QR_PNG    = makeQrPng();
const QR_BASE64 = `data:image/png;base64,${QR_PNG.toString('base64')}`;

// ── State transitions ─────────────────────────────────────────────────────────
function startSession(sessionId) {
  sessions[sessionId] = { sessionId, state: 'INITIALIZING', authenticated: false, timestamp: Date.now() };
  // Move to SCAN_QR_CODE after 2 seconds
  setTimeout(() => {
    if (sessions[sessionId]) {
      sessions[sessionId].state = 'SCAN_QR_CODE';
      console.log(`📱 [${sessionId}] → SCAN_QR_CODE — waiting for QR scan`);
    }
  }, 2000);
  // Auto-connect after 120 seconds (in case dev forgets to call mock-connect)
  setTimeout(() => {
    if (sessions[sessionId] && sessions[sessionId].state !== 'CONNECTED') {
      sessions[sessionId].state = 'CONNECTED';
      sessions[sessionId].authenticated = true;
      sessions[sessionId].phone = '+254700000000';
      sessions[sessionId].pushName = 'NovaGo Test';
      console.log(`✅ [${sessionId}] → CONNECTED (auto-connect after 120s)`);
    }
  }, 120000);
}

// ── HTTP Server ───────────────────────────────────────────────────────────────
const server = http.createServer((req, res) => {
  const parsed   = url.parse(req.url, true);
  const pathname = parsed.pathname;

  res.setHeader('Access-Control-Allow-Origin',  '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, x-api-key');

  if (req.method === 'OPTIONS') { res.writeHead(200); res.end(); return; }

  const json = (code, body) => {
    res.setHeader('Content-Type', 'application/json');
    res.writeHead(code);
    res.end(JSON.stringify(body));
  };

  console.log(`→ ${req.method} ${pathname}`);

  // ── Health / ping ──────────────────────────────────────────────────────────
  if (pathname === '/ping'   || pathname === '/health') {
    return json(200, { success: true, message: 'wwebjs-api mock running on port 3000' });
  }

  // ── Session routes ─────────────────────────────────────────────────────────
  if (pathname.startsWith('/session/')) {
    const parts     = pathname.split('/').filter(p => p); // ['session', sessionId?, action?, ...]
    const action0   = parts[1]; // could be 'getSessions' or a sessionId
    const sessionId = parts[1];
    const action    = parts[2];
    const sub       = parts[3];

    // GET /session/getSessions
    if (action0 === 'getSessions' && parts.length === 2) {
      return json(200, Object.values(sessions));
    }

    // GET /session/:sessionId/start
    if (action === 'start') {
      startSession(sessionId);
      return json(200, { success: true, data: sessions[sessionId] });
    }

    // GET /session/:sessionId/status
    if (action === 'status') {
      const s = sessions[sessionId] || { sessionId, state: 'DISCONNECTED', authenticated: false };
      return json(200, { success: true, data: s });
    }

    // GET /session/:sessionId/qr  → JSON base64
    if (action === 'qr' && !sub) {
      if (!sessions[sessionId] || sessions[sessionId].state !== 'SCAN_QR_CODE') {
        return json(404, { success: false, error: 'Session not in QR state' });
      }
      return json(200, { success: true, qr: QR_BASE64 });
    }

    // GET /session/:sessionId/qr/image  → PNG binary
    if (action === 'qr' && sub === 'image') {
      if (!sessions[sessionId] || sessions[sessionId].state !== 'SCAN_QR_CODE') {
        res.setHeader('Content-Type', 'application/json');
        res.writeHead(404);
        return res.end(JSON.stringify({ success: false, error: 'Session not in QR state' }));
      }
      res.setHeader('Content-Type', 'image/png');
      res.writeHead(200);
      return res.end(QR_PNG);
    }

    // GET /session/:sessionId/terminate
    if (action === 'terminate') {
      delete sessions[sessionId];
      return json(200, { success: true, message: `Session ${sessionId} terminated` });
    }

    // GET /session/:sessionId/restart
    if (action === 'restart') {
      startSession(sessionId);
      return json(200, { success: true, data: sessions[sessionId] });
    }

    // DEV HELPER: GET /session/:sessionId/mock-connect  (simulate a phone scan)
    if (action === 'mock-connect') {
      if (sessions[sessionId]) {
        sessions[sessionId].state       = 'CONNECTED';
        sessions[sessionId].authenticated = true;
        sessions[sessionId].phone       = '+254712345678';
        sessions[sessionId].pushName    = 'NovaGo Dev';
        console.log(`✅ [${sessionId}] MOCK CONNECTED — simulating phone scan`);
        return json(200, { success: true, data: sessions[sessionId] });
      }
      return json(404, { success: false, error: 'Session not found' });
    }
  }

  // ── Chat stubs (for admin inbox) ───────────────────────────────────────────
  if (pathname.startsWith('/chats') || pathname.startsWith('/chat')) {
    return json(200, { success: true, data: [], chats: [] });
  }

  // ── 404 ───────────────────────────────────────────────────────────────────
  json(404, { success: false, error: `Endpoint not found: ${pathname}` });
});

server.listen(PORT, () => {
  console.log('');
  console.log('╔══════════════════════════════════════════════════════╗');
  console.log('║        Mock wwebjs-api  —  port 3000                ║');
  console.log('╠══════════════════════════════════════════════════════╣');
  console.log('║  Session lifecycle:                                  ║');
  console.log('║    start → INITIALIZING (2s) → SCAN_QR_CODE         ║');
  console.log('║    GET /session/:id/mock-connect  to simulate scan   ║');
  console.log('║    Auto-connects after 120s                          ║');
  console.log('╠══════════════════════════════════════════════════════╣');
  console.log('║  Endpoints:                                          ║');
  console.log('║    GET /session/getSessions                          ║');
  console.log('║    GET /session/:id/start                            ║');
  console.log('║    GET /session/:id/status                           ║');
  console.log('║    GET /session/:id/qr          (JSON base64)        ║');
  console.log('║    GET /session/:id/qr/image    (PNG binary)         ║');
  console.log('║    GET /session/:id/terminate                        ║');
  console.log('║    GET /session/:id/restart                          ║');
  console.log('║    GET /session/:id/mock-connect (dev helper)        ║');
  console.log('╚══════════════════════════════════════════════════════╝');
  console.log('');
});
