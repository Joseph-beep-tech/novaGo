/**
 * whatsapp.routes.ts
 * 
 * Handles two responsibilities:
 * 1. Incoming webhooks from wwebjs-api (customer → AI → NovaGo)
 * 2. Admin proxy routes so the admin portal can reach wwebjs-api + whatsapp-service
 *    without CORS issues.
 *
 * Mount in app.ts:
 *   app.use('/api/whatsapp', whatsappRouter);
 */

import { Router, Request, Response } from 'express';
import { prisma } from '../../utils/prisma';

export const whatsappRouter = Router();

const WA_API_URL = process.env.WA_API_URL  || 'http://localhost:3000'; // wwebjs-api
const WA_SVC_URL = process.env.WA_SVC_URL  || 'http://localhost:3001'; // whatsapp-service
const WA_API_KEY = process.env.WA_API_KEY  || '';

// ── Internal fetch helpers ────────────────────────────────────────────────────

async function waApi(path: string, opts: RequestInit = {}) {
  const res = await fetch(`${WA_API_URL}${path}`, {
    ...opts,
    headers: { 'x-api-key': WA_API_KEY, 'Content-Type': 'application/json', ...(opts.headers || {}) },
  });
  const body = await res.json().catch(() => ({}));
  return { status: res.status, body };
}

async function waSvc(path: string, opts: RequestInit = {}) {
  const res = await fetch(`${WA_SVC_URL}${path}`, {
    ...opts,
    headers: { 'x-api-key': WA_API_KEY, 'Content-Type': 'application/json', ...(opts.headers || {}) },
  });
  const body = await res.json().catch(() => ({}));
  return { status: res.status, body };
}

// ── Proxy: session management (for admin portal QR connect) ───────────────────

// GET /api/whatsapp/sessions — list all wwebjs sessions
whatsappRouter.get('/sessions', async (_req: Request, res: Response) => {
  try {
    const { status, body } = await waApi('/session/getSessions');
    res.status(status).json(body);
  } catch (err) {
    res.status(503).json({ error: 'WhatsApp API unavailable', detail: String(err) });
  }
});

// GET /api/whatsapp/session/start/:sessionId
whatsappRouter.get('/session/start/:sessionId', async (req: Request, res: Response) => {
  try {
    const { status, body } = await waApi(`/session/start/${req.params.sessionId}`);
    res.status(status).json(body);
  } catch (err) {
    res.status(503).json({ error: 'WhatsApp API unavailable' });
  }
});

// GET /api/whatsapp/session/status/:sessionId
whatsappRouter.get('/session/status/:sessionId', async (req: Request, res: Response) => {
  try {
    const { status, body } = await waApi(`/session/status/${req.params.sessionId}`);
    res.status(status).json(body);
  } catch (err) {
    res.status(503).json({ error: 'WhatsApp API unavailable' });
  }
});

// GET /api/whatsapp/session/qr/:sessionId — proxy QR image
whatsappRouter.get('/session/qr/:sessionId', async (req: Request, res: Response) => {
  try {
    const upstream = await fetch(`${WA_API_URL}/session/qr/${req.params.sessionId}`, {
      headers: { 'x-api-key': WA_API_KEY },
    });
    if (!upstream.ok) return res.status(upstream.status).json({ error: 'QR not ready' });
    const buf = Buffer.from(await upstream.arrayBuffer());
    res.set('Content-Type', upstream.headers.get('content-type') || 'image/png');
    res.send(buf);
  } catch (err) {
    res.status(503).json({ error: 'WhatsApp API unavailable' });
  }
});

// GET /api/whatsapp/session/terminate/:sessionId
whatsappRouter.get('/session/terminate/:sessionId', async (req: Request, res: Response) => {
  try {
    const { status, body } = await waApi(`/session/terminate/${req.params.sessionId}`);
    res.status(status).json(body);
  } catch (err) {
    res.status(503).json({ error: 'WhatsApp API unavailable' });
  }
});

// GET /api/whatsapp/session/restart/:sessionId
whatsappRouter.get('/session/restart/:sessionId', async (req: Request, res: Response) => {
  try {
    const { status, body } = await waApi(`/session/restart/${req.params.sessionId}`);
    res.status(status).json(body);
  } catch (err) {
    res.status(503).json({ error: 'WhatsApp API unavailable' });
  }
});

// ── Proxy: chats + messages (for admin inbox) ─────────────────────────────────

// GET /api/whatsapp/chats
whatsappRouter.get('/chats', async (req: Request, res: Response) => {
  try {
    const qs = new URLSearchParams(req.query as Record<string, string>).toString();
    const { status, body } = await waSvc(`/api/chats${qs ? '?' + qs : ''}`);
    res.status(status).json(body);
  } catch {
    res.status(503).json({ error: 'WhatsApp service unavailable' });
  }
});

// GET /api/whatsapp/messages
whatsappRouter.get('/messages', async (req: Request, res: Response) => {
  try {
    const qs = new URLSearchParams(req.query as Record<string, string>).toString();
    const { status, body } = await waSvc(`/api/messages${qs ? '?' + qs : ''}`);
    res.status(status).json(body);
  } catch {
    res.status(503).json({ error: 'WhatsApp service unavailable' });
  }
});

// POST /api/whatsapp/messages/send
whatsappRouter.post('/messages/send', async (req: Request, res: Response) => {
  try {
    const { status, body } = await waSvc('/api/messages/send', {
      method: 'POST', body: JSON.stringify(req.body),
    });
    res.status(status).json(body);
  } catch {
    res.status(503).json({ error: 'WhatsApp service unavailable' });
  }
});

// POST /api/whatsapp/chats/claim
whatsappRouter.post('/chats/claim', async (req: Request, res: Response) => {
  try {
    const { status, body } = await waSvc('/api/chats/claim', {
      method: 'POST', body: JSON.stringify(req.body),
    });
    res.status(status).json(body);
  } catch {
    res.status(503).json({ error: 'WhatsApp service unavailable' });
  }
});

// POST /api/whatsapp/chats/release
whatsappRouter.post('/chats/release', async (req: Request, res: Response) => {
  try {
    const { status, body } = await waSvc('/api/chats/release', {
      method: 'POST', body: JSON.stringify(req.body),
    });
    res.status(status).json(body);
  } catch {
    res.status(503).json({ error: 'WhatsApp service unavailable' });
  }
});

// GET /api/whatsapp/chats/context
whatsappRouter.get('/chats/context', async (req: Request, res: Response) => {
  try {
    const qs = new URLSearchParams(req.query as Record<string, string>).toString();
    const { status, body } = await waSvc(`/api/chats/context?${qs}`);
    res.status(status).json(body);
  } catch {
    res.status(503).json({ error: 'WhatsApp service unavailable' });
  }
});

// ── Incoming webhook from wwebjs-api (AI ordering flow) ──────────────────────
// This is the URL you set as BASE_WEBHOOK_URL in wwebjs-api's .env

whatsappRouter.post('/webhook', async (req: Request, res: Response) => {
  // Respond 200 immediately so wwebjs-api doesn't retry
  res.status(200).json({ received: true });

  try {
    const event = req.body;
    const dataType: string = event.dataType || event.type || '';
    const sessionId: string = event.sessionId || '';
    const data = event.data || event;

    if (dataType !== 'message') return; // Only process incoming messages

    const msg = data;
    const from: string = msg.from || '';
    const body: string = msg.body || msg.text || '';
    const isGroup: boolean = from.includes('@g.us');

    if (!from || !body || msg.fromMe) return; // Ignore outgoing / empty
    if (isGroup) return; // Skip group messages for now

    console.log(`[WA Webhook] ${sessionId} | ${from}: ${body.slice(0, 60)}`);

    // Forward to whatsapp-service for AI processing
    await fetch(`${WA_SVC_URL}/api/webhook/incoming`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'x-api-key': WA_API_KEY },
      body: JSON.stringify({ sessionId, from, body: body, message: msg }),
    }).catch(() => null);

  } catch (err) {
    console.error('[WA Webhook] Error:', err);
  }
});

// ── AI reads restaurant data endpoint (called by whatsapp-service AI handler) ─

// GET /api/whatsapp/restaurant-data?phone=:phone
// Given a customer's WhatsApp number, returns the restaurant they're ordering from
// (or all restaurants if no session context)
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
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch restaurant data' });
  }
});

// ── Health check ──────────────────────────────────────────────────────────────

whatsappRouter.get('/health', async (_req: Request, res: Response) => {
  const [waApiOk, waSvcOk] = await Promise.all([
    fetch(`${WA_API_URL}/ping`, { headers: { 'x-api-key': WA_API_KEY } }).then(r => r.ok).catch(() => false),
    fetch(`${WA_SVC_URL}/health`).then(r => r.ok).catch(() => false),
  ]);
  res.json({
    status: 'ok',
    waApi: waApiOk ? 'up' : 'down',
    waService: waSvcOk ? 'up' : 'down',
    waApiUrl: WA_API_URL,
    waSvcUrl: WA_SVC_URL,
  });
});
