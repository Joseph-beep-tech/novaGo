import { Router, Request, Response } from 'express';
import { prisma } from '../../utils/prisma';

export const whatsappRouter = Router();

const WA_API_URL = process.env.WA_API_URL || 'http://localhost:3000';
const WA_SVC_URL = process.env.WA_SVC_URL || 'http://localhost:3001';
const WA_API_KEY = process.env.WA_API_KEY || '';

const waHeaders = () => ({
  'x-api-key': WA_API_KEY,
  'Content-Type': 'application/json',
});

async function waApi(path: string, opts: RequestInit = {}) {
  const res = await fetch(`${WA_API_URL}${path}`, {
    ...opts,
    headers: { ...waHeaders(), ...(opts.headers as Record<string, string> || {}) },
  });
  const body = await res.json().catch(() => ({}));
  return { status: res.status, body };
}

async function waSvc(path: string, opts: RequestInit = {}) {
  const res = await fetch(`${WA_SVC_URL}${path}`, {
    ...opts,
    headers: { ...waHeaders(), ...(opts.headers as Record<string, string> || {}) },
  });
  const body = await res.json().catch(() => ({}));
  return { status: res.status, body };
}

// ── Session management (admin portal QR connect) ──────────────────────────────

// GET /api/whatsapp/sessions
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
    res.status(503).json({ error: 'WhatsApp API unavailable', detail: String(err) });
  }
});

// GET /api/whatsapp/session/status/:sessionId
whatsappRouter.get('/session/status/:sessionId', async (req: Request, res: Response) => {
  try {
    const { status, body } = await waApi(`/session/status/${req.params.sessionId}`);
    res.status(status).json(body);
  } catch (err) {
    res.status(503).json({ error: 'WhatsApp API unavailable', detail: String(err) });
  }
});

// GET /api/whatsapp/session/qr/:sessionId
// Proxies the QR image from wwebjs-api and returns it as a PNG
// wwebjs-api serves the QR at: GET /session/qr/:id/image
whatsappRouter.get('/session/qr/:sessionId', async (req: Request, res: Response) => {
  try {
    // Try /image endpoint first (standard wwebjs-api)
    const upstream = await fetch(`${WA_API_URL}/session/qr/${req.params.sessionId}/image`, {
      headers: { 'x-api-key': WA_API_KEY },
    });

    if (!upstream.ok) {
      // Some versions serve base64 JSON instead — try that
      const { body } = await waApi(`/session/qr/${req.params.sessionId}`);
      if (body?.qr) {
        // body.qr is a data URI: "data:image/png;base64,..."
        const base64 = body.qr.replace(/^data:image\/\w+;base64,/, '');
        const buf = Buffer.from(base64, 'base64');
        res.set('Content-Type', 'image/png');
        res.set('Cache-Control', 'no-cache, no-store, must-revalidate');
        return res.send(buf);
      }
      return res.status(upstream.status).json({ error: 'QR not ready yet — still initializing' });
    }

    const contentType = upstream.headers.get('content-type') || 'image/png';
    const buf = Buffer.from(await upstream.arrayBuffer());
    res.set('Content-Type', contentType);
    res.set('Cache-Control', 'no-cache, no-store, must-revalidate');
    res.send(buf);
  } catch (err) {
    res.status(503).json({ error: 'WhatsApp API unavailable', detail: String(err) });
  }
});

// GET /api/whatsapp/session/terminate/:sessionId
whatsappRouter.get('/session/terminate/:sessionId', async (req: Request, res: Response) => {
  try {
    const { status, body } = await waApi(`/session/terminate/${req.params.sessionId}`);
    res.status(status).json(body);
  } catch (err) {
    res.status(503).json({ error: 'WhatsApp API unavailable', detail: String(err) });
  }
});

// GET /api/whatsapp/session/restart/:sessionId
whatsappRouter.get('/session/restart/:sessionId', async (req: Request, res: Response) => {
  try {
    const { status, body } = await waApi(`/session/restart/${req.params.sessionId}`);
    res.status(status).json(body);
  } catch (err) {
    res.status(503).json({ error: 'WhatsApp API unavailable', detail: String(err) });
  }
});

// ── Chat + message proxy (admin inbox) ────────────────────────────────────────

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
// whatsapp-service uses /api/chats/messages  
whatsappRouter.get('/messages', async (req: Request, res: Response) => {
  try {
    const qs = new URLSearchParams(req.query as Record<string, string>).toString();
    const { status, body } = await waSvc(`/api/chats/messages${qs ? '?' + qs : ''}`);
    res.status(status).json(body);
  } catch {
    res.status(503).json({ error: 'WhatsApp service unavailable' });
  }
});

// POST /api/whatsapp/messages/send
// whatsapp-service uses /api/chats/send
whatsappRouter.post('/messages/send', async (req: Request, res: Response) => {
  try {
    const { status, body } = await waSvc('/api/chats/send', {
      method: 'POST',
      body: JSON.stringify(req.body),
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
      method: 'POST',
      body: JSON.stringify(req.body),
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
      method: 'POST',
      body: JSON.stringify(req.body),
    });
    res.status(status).json(body);
  } catch {
    res.status(503).json({ error: 'WhatsApp service unavailable' });
  }
});

// ── Incoming webhook from wwebjs-api ──────────────────────────────────────────

whatsappRouter.post('/webhook', async (req: Request, res: Response) => {
  res.status(200).json({ received: true });
  try {
    const event = req.body;
    const dataType: string = event.dataType || event.type || '';
    if (dataType !== 'message') return;

    const msg = event.data || event;
    const from: string = msg.from || '';
    const body: string = msg.body || msg.text || '';
    if (!from || !body || msg.fromMe || from.includes('@g.us')) return;

    await fetch(`${WA_SVC_URL}/api/webhook/incoming`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'x-api-key': WA_API_KEY },
      body: JSON.stringify({ sessionId: event.sessionId, from, body, message: msg }),
    }).catch(() => null);
  } catch (err) {
    console.error('[WA Webhook]', err);
  }
});

// ── AI restaurant data endpoint ───────────────────────────────────────────────

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

// ── Health ────────────────────────────────────────────────────────────────────

whatsappRouter.get('/health', async (_req: Request, res: Response) => {
  const [waApiOk, waSvcOk] = await Promise.all([
    fetch(`${WA_API_URL}/ping`, { headers: { 'x-api-key': WA_API_KEY } }).then(r => r.ok).catch(() => false),
    fetch(`${WA_SVC_URL}/health`).then(r => r.ok).catch(() => false),
  ]);
  res.json({
    status: 'ok',
    waApi:    waApiOk ? 'up' : 'down',
    waService: waSvcOk ? 'up' : 'down',
    waApiUrl: WA_API_URL,
    waSvcUrl: WA_SVC_URL,
  });
});
