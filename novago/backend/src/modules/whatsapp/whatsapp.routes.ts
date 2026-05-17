/**
 * whatsapp.routes.ts
 *
 * Proxy between the NovaGo admin portal and:
 *   wwebjs-api (WA_API_URL, default :3000) — QR / session management
 *   whatsapp-service (WA_SVC_URL, default :3001) — chats / messages / AI
 *
 * wwebjs-api URL patterns (kulemantu/wwebjs-api):
 *   GET /session/getSessions
 *   GET /session/:sessionId/start
 *   GET /session/:sessionId/status
 *   GET /session/:sessionId/qr          → JSON { success, qr: "data:image/png;base64,..." }
 *   GET /session/:sessionId/qr/image    → PNG binary
 *   GET /session/:sessionId/terminate
 *   GET /session/:sessionId/restart
 *   GET /ping
 */

import { Router, Request, Response } from 'express';
import { prisma } from '../../utils/prisma';

export const whatsappRouter = Router();

const WA_API_URL = (process.env.WA_API_URL || 'http://localhost:3000').replace(/\/$/, '');
const WA_SVC_URL = (process.env.WA_SVC_URL || 'http://localhost:3001').replace(/\/$/, '');
const WA_API_KEY = process.env.WA_API_KEY || '';

// ── Shared request headers ────────────────────────────────────────────────────
function waHeaders(): Record<string, string> {
  return {
    'Content-Type': 'application/json',
    ...(WA_API_KEY ? { 'x-api-key': WA_API_KEY } : {}),
  };
}

// ── Generic JSON proxy ────────────────────────────────────────────────────────
async function proxyJson(res: Response, url: string, opts: RequestInit = {}): Promise<void> {
  try {
    const upstream = await fetch(url, {
      ...opts,
      headers: { ...waHeaders(), ...(opts.headers as Record<string, string> || {}) },
    });
    const body = await upstream.json().catch(() => ({}));
    res.status(upstream.status).json(body);
  } catch (err: any) {
    res.status(503).json({
      success: false,
      error: `Service unavailable: ${err.message}`,
      hint: 'Make sure wwebjs-api is running and WA_API_URL is set in the backend .env',
    });
  }
}

// ── Binary image proxy ────────────────────────────────────────────────────────
async function proxyImage(res: Response, url: string): Promise<void> {
  try {
    const upstream = await fetch(url, { headers: waHeaders() });
    if (!upstream.ok) {
      return res.status(upstream.status).json({ success: false, error: 'QR not available yet' }) as any;
    }
    const contentType = upstream.headers.get('content-type') || 'image/png';
    const buf = await upstream.arrayBuffer();
    res.setHeader('Content-Type', contentType);
    res.send(Buffer.from(buf));
  } catch (err: any) {
    res.status(503).json({ success: false, error: `Image proxy error: ${err.message}` });
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SESSION MANAGEMENT — wwebjs-api
// Pattern: /session/:sessionId/action  (sessionId BEFORE action)
// ══════════════════════════════════════════════════════════════════════════════

/**
 * GET /api/whatsapp/sessions
 * Lists all wwebjs sessions → GET /session/getSessions
 */
whatsappRouter.get('/sessions', async (_req: Request, res: Response) => {
  try {
    const upstream = await fetch(`${WA_API_URL}/session/getSessions`, { headers: waHeaders() });
    if (!upstream.ok) {
      return res.status(upstream.status).json({ success: false, data: [], error: 'Could not fetch sessions' });
    }
    const raw = await upstream.json();
    // wwebjs-api returns an array directly
    const sessions = Array.isArray(raw) ? raw : (raw.data || raw.sessions || []);
    res.json({ success: true, data: sessions });
  } catch (err: any) {
    // If wwebjs-api is down, return empty list (not an error — just not configured yet)
    res.json({ success: true, data: [], hint: err.message });
  }
});

/**
 * GET /api/whatsapp/session/start/:sessionId
 * → GET /session/:sessionId/start
 */
whatsappRouter.get('/session/start/:sessionId', async (req: Request, res: Response) => {
  await proxyJson(res, `${WA_API_URL}/session/${req.params.sessionId}/start`);
});

/**
 * GET /api/whatsapp/session/status/:sessionId
 * → GET /session/:sessionId/status
 * Normalises to { success, data: { sessionId, state, authenticated, phone?, pushName? } }
 */
whatsappRouter.get('/session/status/:sessionId', async (req: Request, res: Response) => {
  const { sessionId } = req.params;
  try {
    const upstream = await fetch(`${WA_API_URL}/session/${sessionId}/status`, { headers: waHeaders() });
    if (!upstream.ok) {
      return res.json({ success: true, data: { sessionId, state: 'DISCONNECTED', authenticated: false } });
    }
    const raw = await upstream.json();
    // wwebjs-api shape: { success, data: { sessionId, state, ... } }
    const inner = raw?.data ?? raw;
    res.json({
      success: true,
      data: {
        sessionId,
        state: inner?.state || inner?.status || 'DISCONNECTED',
        authenticated: !!(inner?.state === 'CONNECTED' || inner?.authenticated),
        phone: inner?.phone || inner?.phoneNumber,
        pushName: inner?.pushName,
      },
    });
  } catch {
    res.json({ success: true, data: { sessionId, state: 'DISCONNECTED', authenticated: false } });
  }
});

/**
 * GET /api/whatsapp/session/qr/:sessionId
 * Proxies PNG image → GET /session/:sessionId/qr/image
 */
whatsappRouter.get('/session/qr/:sessionId', async (req: Request, res: Response) => {
  await proxyImage(res, `${WA_API_URL}/session/${req.params.sessionId}/qr/image`);
});

/**
 * GET /api/whatsapp/session/terminate/:sessionId
 * → GET /session/:sessionId/terminate
 */
whatsappRouter.get('/session/terminate/:sessionId', async (req: Request, res: Response) => {
  await proxyJson(res, `${WA_API_URL}/session/${req.params.sessionId}/terminate`);
});

/**
 * GET /api/whatsapp/session/restart/:sessionId
 * → GET /session/:sessionId/restart
 */
whatsappRouter.get('/session/restart/:sessionId', async (req: Request, res: Response) => {
  await proxyJson(res, `${WA_API_URL}/session/${req.params.sessionId}/restart`);
});

// ══════════════════════════════════════════════════════════════════════════════
// CHATS & MESSAGES — whatsapp-service
// ══════════════════════════════════════════════════════════════════════════════

whatsappRouter.get('/chats', async (req: Request, res: Response) => {
  const qs = new URLSearchParams(req.query as Record<string, string>).toString();
  await proxyJson(res, `${WA_SVC_URL}/chats${qs ? '?' + qs : ''}`);
});

whatsappRouter.get('/messages', async (req: Request, res: Response) => {
  const qs = new URLSearchParams(req.query as Record<string, string>).toString();
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
// AI RESTAURANT DATA — reads live menus from NovaGo DB
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
// INCOMING WEBHOOK — wwebjs-api → NovaGo → whatsapp-service AI
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
// HEALTH CHECK
// ══════════════════════════════════════════════════════════════════════════════

whatsappRouter.get('/health', async (_req: Request, res: Response) => {
  const [waApiOk, waSvcOk] = await Promise.all([
    fetch(`${WA_API_URL}/ping`, { headers: waHeaders() }).then(r => r.ok).catch(() => false),
    fetch(`${WA_SVC_URL}/health`).then(r => r.ok).catch(() => false),
  ]);
  res.json({
    success: true,
    waApi: waApiOk ? 'up' : 'down',
    waService: waSvcOk ? 'up' : 'down',
    waApiUrl: WA_API_URL,
    waSvcUrl: WA_SVC_URL,
  });
});
