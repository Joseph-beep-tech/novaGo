/**
 * whatsapp.routes.ts
 *
 * Single proxy between NovaGo admin portal and the wa.dt.wrld-main services.
 * All session + chat + message calls from the frontend go through here,
 * avoiding CORS and keeping credentials server-side.
 *
 * wwebjs-api     (WA_API_URL  default: http://localhost:3000) — QR / session mgmt
 * whatsapp-service (WA_SVC_URL default: http://localhost:3001) — chats / messages / AI
 *
 * Exact wwebjs-api endpoints used:
 *   GET  /session/start/:id
 *   GET  /session/status/:id      → returns { success, data: { state, ... } }
 *   GET  /session/qr/:id/image    → returns PNG image
 *   GET  /session/getSessions     → returns array of sessions
 *   GET  /session/terminate/:id
 *   GET  /session/restart/:id
 *
 * whatsapp-service endpoints:
 *   GET  /session/status/:id      → proxied from wwebjs-api, normalised
 *   GET  /session/qr/:id/image    → proxied from wwebjs-api
 *   GET  /chats
 *   GET  /chats/messages
 *   POST /chats/send
 *   POST /chats/claim
 *   POST /chats/release
 *   GET  /chats/context
 */

import { Router, Request, Response } from 'express';
import { prisma } from '../../utils/prisma';

export const whatsappRouter = Router();

const WA_API_URL = process.env.WA_API_URL  || 'http://localhost:3000';   // wwebjs-api
const WA_SVC_URL = process.env.WA_SVC_URL  || 'http://localhost:3001';   // whatsapp-service
const WA_API_KEY = process.env.WA_API_KEY  || '';

// ── Shared headers ────────────────────────────────────────────────────────────

function waHeaders() {
  return {
    'Content-Type': 'application/json',
    ...(WA_API_KEY ? { 'x-api-key': WA_API_KEY } : {}),
  };
}

// ── Generic JSON proxy helpers ────────────────────────────────────────────────

async function proxyJson(
  res: Response,
  url: string,
  opts: RequestInit = {}
): Promise<void> {
  try {
    const upstream = await fetch(url, {
      ...opts,
      headers: { ...waHeaders(), ...(opts.headers as Record<string, string> || {}) },
    });
    const body = await upstream.json().catch(() => ({}));
    res.status(upstream.status).json(body);
  } catch (err: any) {
    res.status(503).json({ success: false, error: `Service unavailable: ${err.message}` });
  }
}

async function proxyImage(res: Response, url: string): Promise<void> {
  try {
    const upstream = await fetch(url, { headers: waHeaders() });
    if (!upstream.ok) {
      res.status(upstream.status).json({ success: false, error: 'QR not available yet' });
      return;
    }
    const contentType = upstream.headers.get('content-type') || 'image/png';
    const buf = await upstream.arrayBuffer();
    res.setHeader('Content-Type', contentType);
    res.send(Buffer.from(buf));
  } catch (err: any) {
    res.status(503).json({ success: false, error: `Service unavailable: ${err.message}` });
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SESSION MANAGEMENT  (calls wwebjs-api directly)
// ══════════════════════════════════════════════════════════════════════════════

/**
 * GET /api/whatsapp/sessions
 * List all wwebjs sessions → returns { success, data: SessionStatus[] }
 */
whatsappRouter.get('/sessions', async (_req: Request, res: Response) => {
  try {
    const upstream = await fetch(`${WA_API_URL}/session/getSessions`, {
      headers: waHeaders(),
    });
    if (!upstream.ok) {
      return res.status(upstream.status).json({ success: false, error: 'Could not fetch sessions' });
    }
    const data = await upstream.json();
    // wwebjs-api returns an array; wrap it for consistency
    const sessions = Array.isArray(data) ? data : (data.data || data.sessions || []);
    res.json({ success: true, data: sessions });
  } catch (err: any) {
    res.status(503).json({ success: false, error: err.message });
  }
});

/**
 * GET /api/whatsapp/session/start/:sessionId
 * Start a new wwebjs session. Returns immediately; poll /status for QR / CONNECTED.
 */
whatsappRouter.get('/session/start/:sessionId', async (req: Request, res: Response) => {
  await proxyJson(res, `${WA_API_URL}/session/start/${req.params.sessionId}`);
});

/**
 * GET /api/whatsapp/session/status/:sessionId
 * Returns normalised status:
 *   { success: true, data: { sessionId, state, authenticated, phone?, pushName?, qrCode? } }
 *
 * Possible `state` values from wwebjs-api:
 *   SCAN_QR_CODE | CONNECTED | DISCONNECTED | INITIALIZING | FAILED
 */
whatsappRouter.get('/session/status/:sessionId', async (req: Request, res: Response) => {
  const { sessionId } = req.params;
  try {
    const upstream = await fetch(`${WA_API_URL}/session/status/${sessionId}`, {
      headers: waHeaders(),
    });

    if (!upstream.ok) {
      // Session not found — return disconnected
      return res.json({
        success: true,
        data: { sessionId, state: 'DISCONNECTED', authenticated: false },
      });
    }

    const raw = await upstream.json();
    // wwebjs-api shape: { success, data: { state, ... } }  OR  { state, ... }
    const inner = raw?.data ?? raw;
    const state: string = inner?.state || inner?.status || 'DISCONNECTED';

    // Also fetch QR code data if in QR state (as base64 string, not image)
    let qrCode: string | undefined;
    if (state === 'SCAN_QR_CODE') {
      try {
        const qrRes = await fetch(`${WA_API_URL}/session/qr/${sessionId}`, {
          headers: waHeaders(),
        });
        if (qrRes.ok) {
          const qrData = await qrRes.json();
          qrCode = qrData?.data?.qr || qrData?.qr;
        }
      } catch { /* ignore */ }
    }

    res.json({
      success: true,
      data: {
        sessionId,
        state,
        authenticated: state === 'CONNECTED',
        phone: inner?.phone || inner?.phoneNumber,
        pushName: inner?.pushName,
        ...(qrCode ? { qrCode } : {}),
      },
    });
  } catch (err: any) {
    res.json({
      success: true,
      data: { sessionId, state: 'DISCONNECTED', authenticated: false },
    });
  }
});

/**
 * GET /api/whatsapp/session/qr/:sessionId
 * Proxies the QR PNG image from wwebjs-api → browser.
 * wwebjs-api endpoint: GET /session/qr/:sessionId/image
 */
whatsappRouter.get('/session/qr/:sessionId', async (req: Request, res: Response) => {
  await proxyImage(res, `${WA_API_URL}/session/qr/${req.params.sessionId}/image`);
});

/**
 * GET /api/whatsapp/session/terminate/:sessionId
 */
whatsappRouter.get('/session/terminate/:sessionId', async (req: Request, res: Response) => {
  await proxyJson(res, `${WA_API_URL}/session/terminate/${req.params.sessionId}`);
});

/**
 * GET /api/whatsapp/session/restart/:sessionId
 */
whatsappRouter.get('/session/restart/:sessionId', async (req: Request, res: Response) => {
  await proxyJson(res, `${WA_API_URL}/session/restart/${req.params.sessionId}`);
});

// ══════════════════════════════════════════════════════════════════════════════
// CHATS  (calls whatsapp-service)
// ══════════════════════════════════════════════════════════════════════════════

whatsappRouter.get('/chats', async (req: Request, res: Response) => {
  const qs = new URLSearchParams(req.query as Record<string, string>).toString();
  await proxyJson(res, `${WA_SVC_URL}/chats${qs ? '?' + qs : ''}`);
});

whatsappRouter.get('/messages', async (req: Request, res: Response) => {
  const qs = new URLSearchParams(req.query as Record<string, string>).toString();
  // whatsapp-service stores messages under /chats/messages
  await proxyJson(res, `${WA_SVC_URL}/chats/messages${qs ? '?' + qs : ''}`);
});

whatsappRouter.post('/messages/send', async (req: Request, res: Response) => {
  await proxyJson(res, `${WA_SVC_URL}/chats/send`, {
    method: 'POST',
    body: JSON.stringify(req.body),
  });
});

whatsappRouter.post('/chats/claim', async (req: Request, res: Response) => {
  await proxyJson(res, `${WA_SVC_URL}/chats/claim`, {
    method: 'POST',
    body: JSON.stringify(req.body),
  });
});

whatsappRouter.post('/chats/release', async (req: Request, res: Response) => {
  await proxyJson(res, `${WA_SVC_URL}/chats/release`, {
    method: 'POST',
    body: JSON.stringify(req.body),
  });
});

whatsappRouter.get('/chats/context', async (req: Request, res: Response) => {
  const qs = new URLSearchParams(req.query as Record<string, string>).toString();
  await proxyJson(res, `${WA_SVC_URL}/chats/context${qs ? '?' + qs : ''}`);
});

// ══════════════════════════════════════════════════════════════════════════════
// AI RESTAURANT DATA  (AI reads live menus from NovaGo DB)
// ══════════════════════════════════════════════════════════════════════════════

whatsappRouter.get('/restaurant-data', async (req: Request, res: Response) => {
  try {
    const { restaurantId } = req.query;
    if (restaurantId) {
      const restaurant = await prisma.restaurant.findUnique({
        where: { id: String(restaurantId) },
        include: { menuItems: { where: { isAvailable: true } } },
      });
      return res.json(restaurant);
    }
    const restaurants = await prisma.restaurant.findMany({
      where: { isOpen: true },
      include: { menuItems: { where: { isAvailable: true } } },
    });
    res.json(restaurants);
  } catch (err: any) {
    res.status(500).json({ error: 'Failed to fetch restaurant data', detail: err.message });
  }
});

// ══════════════════════════════════════════════════════════════════════════════
// INCOMING WEBHOOK  (wwebjs-api → NovaGo → whatsapp-service AI)
// ══════════════════════════════════════════════════════════════════════════════

whatsappRouter.post('/webhook', async (req: Request, res: Response) => {
  res.status(200).json({ received: true });
  try {
    const event = req.body;
    const dataType: string = event.dataType || event.type || '';
    if (dataType !== 'message') return;
    const msg = event.data || event;
    if (!msg.from || !msg.body || msg.fromMe) return;
    if ((msg.from as string).includes('@g.us')) return;

    await fetch(`${WA_SVC_URL}/webhook/incoming`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', ...(WA_API_KEY ? { 'x-api-key': WA_API_KEY } : {}) },
      body: JSON.stringify({ sessionId: event.sessionId, from: msg.from, body: msg.body, message: msg }),
    }).catch(() => null);
  } catch (err) {
    console.error('[WA Webhook] Error:', err);
  }
});

// ══════════════════════════════════════════════════════════════════════════════
// HEALTH
// ══════════════════════════════════════════════════════════════════════════════

whatsappRouter.get('/health', async (_req: Request, res: Response) => {
  const [waApiOk, waSvcOk] = await Promise.all([
    fetch(`${WA_API_URL}/ping`, { headers: waHeaders() }).then(r => r.ok).catch(() => false),
    fetch(`${WA_SVC_URL}/health`).then(r => r.ok).catch(() => false),
  ]);
  res.json({
    success: true,
    waApi:    waApiOk ? 'up' : 'down',
    waService: waSvcOk ? 'up' : 'down',
    waApiUrl:  WA_API_URL,
    waSvcUrl:  WA_SVC_URL,
  });
});
