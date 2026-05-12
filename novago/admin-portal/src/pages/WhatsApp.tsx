/**
 * WhatsApp.tsx
 *
 * All API calls go through the Vite proxy: /api/whatsapp/* → localhost:4000 → wwebjs-api / whatsapp-service
 * Zero direct browser calls to wwebjs-api or whatsapp-service (avoids CORS + port conflicts).
 *
 * Route map (backend whatsapp.routes.ts proxies all of these):
 *   /api/whatsapp/sessions                  → wwebjs-api GET /session/getSessions
 *   /api/whatsapp/session/start/:id         → wwebjs-api GET /session/start/:id
 *   /api/whatsapp/session/status/:id        → wwebjs-api GET /session/status/:id
 *   /api/whatsapp/session/qr/:id            → wwebjs-api GET /session/qr/:id/image  (proxied as image)
 *   /api/whatsapp/session/terminate/:id     → wwebjs-api GET /session/terminate/:id
 *   /api/whatsapp/chats                     → whatsapp-service /api/chats
 *   /api/whatsapp/messages                  → whatsapp-service /api/chats/messages
 *   /api/whatsapp/messages/send             → whatsapp-service /api/chats/send
 *   /api/whatsapp/chats/claim               → whatsapp-service /api/chats/claim
 *   /api/whatsapp/chats/release             → whatsapp-service /api/chats/release
 *   /api/orders?customerPhone=              → novago backend
 */

import { useState, useEffect, useRef, useCallback } from 'react';
import {
  MessageSquare, QrCode, CheckCircle2, XCircle, Loader2,
  RefreshCw, Search, Bot, User, Send, StickyNote, UserCheck,
  Zap, Paperclip, X, ShoppingBag, Clock, Info,
  Wifi, WifiOff, AlertTriangle, Plus, RotateCcw,
} from 'lucide-react';

// All calls go through Vite proxy → NovaGo backend → wwebjs-api / whatsapp-service
// Never call wwebjs-api or whatsapp-service directly from the browser
const BASE = '/api/whatsapp';

// ── Types ─────────────────────────────────────────────────────────────────────

interface WaSession {
  sessionId: string;
  status: 'CONNECTED' | 'DISCONNECTED' | 'QR' | 'INITIALIZING' | 'FAILED';
  qrImageUrl?: string;   // URL to render in <img> — served by backend proxy
  phone?: string;
  pushName?: string;
}

interface Chat {
  id: string;
  identifier: string;
  platform: string;
  contactName: string;
  contactPhone: string;
  lastMessage: string;
  lastMessageTime: string;
  unreadCount: number;
  status: string;
  isGroup: boolean;
  tags: string[];
  assignedTo?: string;
}

interface Message {
  id: string;
  content: string;
  contentType: string;
  timestamp: string;
  sender: { type: 'customer' | 'bot' | 'agent'; name: string };
  isFromMe: boolean;
}

interface Order { id: string; status: string; total: number; }

// ── Helpers ───────────────────────────────────────────────────────────────────

const COLORS = [
  { bg: '#E1F5EE', fg: '#0F6E56' }, { bg: '#ede9fe', fg: '#5b21b6' },
  { bg: '#dbeafe', fg: '#1e40af' }, { bg: '#fef3c7', fg: '#d97706' },
  { bg: '#fce7f3', fg: '#be185d' },
];

function getColor(name: string) {
  return COLORS[Math.abs(name.charCodeAt(0) - 65) % COLORS.length];
}

function getInitials(name: string) {
  return name.split(' ').map(w => w[0] || '').join('').slice(0, 2).toUpperCase() || '??';
}

function timeAgo(ts: string) {
  const s = (Date.now() - new Date(ts).getTime()) / 1000;
  if (s < 60) return 'now';
  if (s < 3600) return `${Math.floor(s / 60)}m`;
  if (s < 86400) return `${Math.floor(s / 3600)}h`;
  return `${Math.floor(s / 86400)}d`;
}

function fmtTime(ts: string) {
  try { return new Date(ts).toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' }); }
  catch { return ''; }
}

// Safe JSON fetch — returns null on error instead of throwing
async function apiFetch<T = any>(path: string, opts: RequestInit = {}): Promise<T | null> {
  try {
    const res = await fetch(path, {
      ...opts,
      headers: { 'Content-Type': 'application/json', ...(opts.headers || {}) },
    });
    if (!res.ok) {
      console.warn(`[WA] ${opts.method || 'GET'} ${path} → ${res.status}`);
      return null;
    }
    return res.json() as Promise<T>;
  } catch (err) {
    console.warn(`[WA] fetch error ${path}:`, err);
    return null;
  }
}

async function novaFetch<T = any>(path: string): Promise<T | null> {
  try {
    const token = localStorage.getItem('novago_token') || '';
    const res = await fetch(path, {
      headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
    });
    if (!res.ok) return null;
    return res.json() as Promise<T>;
  } catch { return null; }
}

const QUICK_REPLIES = [
  { emoji: '🏍️', label: 'Order on its way', text: 'Your order is on the way and will arrive in about 25 minutes!' },
  { emoji: '🙏', label: 'Apologise', text: 'We sincerely apologise for the inconvenience. Let me fix this right away.' },
  { emoji: '💸', label: 'Refund processed', text: 'Your refund has been processed and will reflect within 24 hours.' },
  { emoji: '👍', label: 'Thank customer', text: 'Thank you for ordering with NovaGo! Is there anything else I can help with?' },
  { emoji: '📞', label: 'Escalate', text: 'I am escalating this to our team. You will hear from us within 15 minutes.' },
];

// ── QR Connect Panel ──────────────────────────────────────────────────────────

function QRConnectPanel({ onConnected }: { onConnected: (phone?: string) => void }) {
  const [sessionId, setSessionId] = useState('novago-main');
  const [status, setStatus] = useState<WaSession['status'] | 'IDLE'>('IDLE');
  const [qrUrl, setQrUrl] = useState<string>('');
  const [phone, setPhone] = useState('');
  const [error, setError] = useState('');
  const [starting, setStarting] = useState(false);
  const pollRef = useRef<ReturnType<typeof setInterval>>();
  const qrBusterRef = useRef(0); // cache-busting counter for QR image

  // Poll session status
  const pollStatus = useCallback(async (sid: string) => {
    const data = await apiFetch<any>(`${BASE}/session/status/${sid}`);
    if (!data) return;

    const state: string = (data.state || data.status || '').toUpperCase();

    if (state === 'CONNECTED') {
      clearInterval(pollRef.current);
      setStatus('CONNECTED');
      setPhone(data.phone || data.me?.user || '');
      onConnected(data.phone || data.me?.user || '');
      return;
    }

    if (state === 'SCAN_QR_CODE' || state === 'QR' || state === 'AUTHENTICATING') {
      setStatus('QR');
      // Refresh QR image by busting cache — backend serves it as an image
      qrBusterRef.current += 1;
      setQrUrl(`${BASE}/session/qr/${sid}?t=${qrBusterRef.current}`);
      return;
    }

    if (state === 'STARTING' || state === 'INITIALIZING') {
      setStatus('INITIALIZING');
      return;
    }

    if (state === 'FAILED' || state === 'DISCONNECTED') {
      setStatus('DISCONNECTED');
      clearInterval(pollRef.current);
    }
  }, [onConnected]);

  const startSession = async () => {
    setError('');
    setStarting(true);
    setStatus('INITIALIZING');
    setQrUrl('');

    const data = await apiFetch<any>(`${BASE}/session/start/${sessionId}`);
    setStarting(false);

    if (!data && data !== false) {
      // null = network error / backend not reachable
      setError('Cannot reach WhatsApp service. Make sure wwebjs-api is running on port 3000 or set WA_API_URL environment variable.');
      setStatus('IDLE');
      return;
    }

    if (data?.error) {
      setError(data.error === 'WhatsApp API unavailable' 
        ? `WhatsApp API service unavailable. The backend tried to reach: ${data.url}. Please ensure wwebjs-api is running.`
        : data.error);
      setStatus('IDLE');
      return;
    }

    // Start polling every 3 seconds
    clearInterval(pollRef.current);
    pollRef.current = setInterval(() => pollStatus(sessionId), 3000);
  };

  const restartSession = async () => {
    clearInterval(pollRef.current);
    setStatus('IDLE');
    setQrUrl('');
    setError('');
    await apiFetch(`${BASE}/session/terminate/${sessionId}`);
    await new Promise(r => setTimeout(r, 800));
    await startSession();
  };

  // On mount: check for existing connected session
  useEffect(() => {
    (async () => {
      const sessions = await apiFetch<any[]>(`${BASE}/sessions`);
      if (Array.isArray(sessions) && sessions.length > 0) {
        const s = sessions[0];
        const sid = s.sessionId || s.id || 'novago-main';
        setSessionId(sid);
        const stateVal: string = (s.state || s.status || '').toUpperCase();
        if (stateVal === 'CONNECTED') {
          setStatus('CONNECTED');
          setPhone(s.phone || '');
          onConnected(s.phone || '');
          return;
        }
        // Resume polling for non-connected session
        setStatus('INITIALIZING');
        pollRef.current = setInterval(() => pollStatus(sid), 3000);
      }
    })();
    return () => clearInterval(pollRef.current);
  }, [pollStatus, onConnected]);

  return (
    <div className="flex flex-col items-center justify-center h-full p-8 bg-gray-50">
      <div className="w-full max-w-md">

        {/* Header */}
        <div className="text-center mb-8">
          <div className="w-16 h-16 bg-green-100 rounded-2xl flex items-center justify-center mx-auto mb-4">
            <MessageSquare className="w-8 h-8 text-green-600" />
          </div>
          <h2 className="text-2xl font-bold text-gray-900">Connect WhatsApp</h2>
          <p className="text-gray-500 mt-2 text-sm">
            Link a WhatsApp Business number. The AI will read your restaurant menus and handle customer orders automatically.
          </p>
        </div>

        {/* Card */}
        <div className="bg-white rounded-2xl border border-gray-200 shadow-sm overflow-hidden">

          {/* Session input — only shown when idle */}
          {(status === 'IDLE' || status === 'DISCONNECTED' || status === 'FAILED') && (
            <div className="p-6 border-b border-gray-100">
              <label className="block text-xs font-semibold text-gray-500 mb-2 uppercase tracking-wide">
                Session Name
              </label>
              <div className="flex gap-2">
                <input
                  value={sessionId}
                  onChange={e => setSessionId(e.target.value.replace(/\s/g, '-').toLowerCase())}
                  className="flex-1 px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:border-green-500 focus:ring-1 focus:ring-green-200 transition-colors"
                  placeholder="novago-main"
                />
                <button
                  onClick={startSession}
                  disabled={starting || !sessionId.trim()}
                  className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg text-sm font-semibold hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                >
                  {starting
                    ? <Loader2 className="w-4 h-4 animate-spin" />
                    : <Plus className="w-4 h-4" />
                  }
                  Connect
                </button>
              </div>
              {error && (
                <p className="text-red-600 text-xs mt-2.5 flex items-start gap-1.5">
                  <AlertTriangle className="w-3.5 h-3.5 flex-shrink-0 mt-0.5" />
                  {error}
                </p>
              )}
            </div>
          )}

          {/* Status body */}
          <div className="p-6">
            {status === 'IDLE' && (
              <div className="text-center py-8 text-gray-300">
                <QrCode className="w-12 h-12 mx-auto mb-3" />
                <p className="text-sm text-gray-400">Enter a session name and click Connect</p>
              </div>
            )}

            {status === 'INITIALIZING' && (
              <div className="text-center py-8">
                <Loader2 className="w-10 h-10 animate-spin text-green-600 mx-auto mb-3" />
                <p className="font-semibold text-gray-800">Starting WhatsApp session…</p>
                <p className="text-sm text-gray-400 mt-1">Generating QR code, this takes a few seconds</p>
              </div>
            )}

            {status === 'QR' && (
              <div className="text-center">
                <p className="text-sm font-semibold text-gray-700 mb-4 flex items-center justify-center gap-2">
                  <QrCode className="w-4 h-4 text-amber-500" />
                  Scan this QR code with WhatsApp
                </p>

                {/* QR image served by backend proxy — no CORS issues */}
                {qrUrl ? (
                  <div className="relative inline-block">
                    <img
                      key={qrUrl}
                      src={qrUrl}
                      alt="WhatsApp QR code — scan with your phone"
                      className="w-56 h-56 mx-auto rounded-xl border-4 border-white shadow-lg object-contain bg-white"
                      onError={() => {
                        // If image fails, retry in 3 seconds
                        setTimeout(() => {
                          qrBusterRef.current += 1;
                          setQrUrl(`${BASE}/session/qr/${sessionId}?t=${qrBusterRef.current}`);
                        }, 3000);
                      }}
                    />
                    <div className="absolute -top-2 -right-2 bg-amber-400 text-white text-[10px] font-bold px-2 py-0.5 rounded-full">
                      LIVE
                    </div>
                  </div>
                ) : (
                  <div className="w-56 h-56 mx-auto rounded-xl bg-gray-100 flex flex-col items-center justify-center gap-2">
                    <Loader2 className="w-8 h-8 animate-spin text-gray-300" />
                    <p className="text-xs text-gray-400">Loading QR…</p>
                  </div>
                )}

                <div className="mt-4 bg-amber-50 border border-amber-200 rounded-lg p-3 text-left text-xs text-amber-800 space-y-1">
                  <p className="font-semibold mb-1">How to scan:</p>
                  <p>1. Open WhatsApp on your phone</p>
                  <p>2. Tap ⋮ Menu → <strong>Linked Devices</strong></p>
                  <p>3. Tap <strong>"Link a device"</strong> and scan this code</p>
                </div>

                <button
                  onClick={restartSession}
                  className="mt-3 text-xs text-gray-400 hover:text-gray-600 flex items-center gap-1 mx-auto transition-colors"
                >
                  <RotateCcw className="w-3 h-3" /> Regenerate QR
                </button>
              </div>
            )}

            {status === 'CONNECTED' && (
              <div className="text-center py-4">
                <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-3">
                  <CheckCircle2 className="w-8 h-8 text-green-500" />
                </div>
                <p className="font-bold text-gray-800 text-lg">WhatsApp Connected!</p>
                {phone && (
                  <p className="text-gray-500 text-sm mt-1 font-medium">{phone}</p>
                )}
                <p className="text-xs text-gray-400 mt-1">AI agent is now live and serving customers</p>

                <div className="mt-4 grid grid-cols-2 gap-2 text-left">
                  <div className="bg-green-50 rounded-lg p-3 text-xs">
                    <p className="font-semibold text-green-700 mb-1">✅ AI is reading</p>
                    <p className="text-green-600">Live menus & prices from your restaurants</p>
                  </div>
                  <div className="bg-blue-50 rounded-lg p-3 text-xs">
                    <p className="font-semibold text-blue-700 mb-1">📦 Orders land in</p>
                    <p className="text-blue-600">Your NovaGo dashboard automatically</p>
                  </div>
                </div>

                <button
                  onClick={() => { setStatus('IDLE'); setPhone(''); }}
                  className="mt-4 text-xs text-gray-400 hover:text-red-500 transition-colors"
                >
                  Disconnect / Switch number
                </button>
              </div>
            )}

            {(status === 'DISCONNECTED' || status === 'FAILED') && (
              <div className="text-center py-4">
                <XCircle className="w-12 h-12 text-red-400 mx-auto mb-3" />
                <p className="font-semibold text-gray-800">Session Lost</p>
                <p className="text-sm text-gray-500 mt-1">The WhatsApp session disconnected</p>
                <button
                  onClick={restartSession}
                  className="mt-4 flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg text-sm font-semibold hover:bg-green-700 mx-auto transition-colors"
                >
                  <RefreshCw className="w-4 h-4" /> Reconnect
                </button>
              </div>
            )}
          </div>

          {/* Footer */}
          {status !== 'IDLE' && (
            <div className="px-6 pb-4 flex items-center justify-between text-xs text-gray-400 border-t border-gray-50 pt-3">
              <span>Session: <code className="bg-gray-100 px-1.5 py-0.5 rounded font-mono">{sessionId}</code></span>
              <div className="flex items-center gap-1">
                {status === 'CONNECTED'
                  ? <><Wifi className="w-3 h-3 text-green-500" /><span className="text-green-600 font-medium">Live</span></>
                  : status === 'QR'
                    ? <><span className="w-1.5 h-1.5 rounded-full bg-amber-400 animate-pulse" /><span className="text-amber-600">Awaiting scan</span></>
                    : <><WifiOff className="w-3 h-3 text-red-400" /><span className="text-red-500">{status}</span></>
                }
              </div>
            </div>
          )}
        </div>

        {/* Feature badges */}
        <div className="mt-6 grid grid-cols-3 gap-3">
          {[
            { icon: Bot, label: 'AI Ordering', desc: 'Reads menus & prices live' },
            { icon: MessageSquare, label: 'Live Inbox', desc: 'Admin can take over anytime' },
            { icon: ShoppingBag, label: 'Real Orders', desc: 'Synced to your dashboard' },
          ].map(f => (
            <div key={f.label} className="bg-white rounded-xl border border-gray-100 p-3 text-center shadow-sm">
              <f.icon className="w-5 h-5 text-green-600 mx-auto mb-1.5" />
              <p className="text-xs font-semibold text-gray-700">{f.label}</p>
              <p className="text-[10px] text-gray-400 mt-0.5 leading-tight">{f.desc}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

// ── Inbox Panel ───────────────────────────────────────────────────────────────

function InboxPanel() {
  const [chats, setChats] = useState<Chat[]>([]);
  const [selectedChat, setSelectedChat] = useState<Chat | null>(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const [orders, setOrders] = useState<Order[]>([]);
  const [filter, setFilter] = useState('all');
  const [search, setSearch] = useState('');
  const [inputText, setInputText] = useState('');
  const [inputMode, setInputMode] = useState<'reply' | 'note'>('reply');
  const [isClaimed, setIsClaimed] = useState(false);
  const [claimLoading, setClaimLoading] = useState(false);
  const [quickOpen, setQuickOpen] = useState(false);
  const [loadingMsgs, setLoadingMsgs] = useState(false);
  const [loadingChats, setLoadingChats] = useState(false);
  const msgEndRef = useRef<HTMLDivElement>(null);
  const taRef = useRef<HTMLTextAreaElement>(null);
  const chatPollRef = useRef<ReturnType<typeof setInterval>>();
  const msgPollRef = useRef<ReturnType<typeof setInterval>>();

  // ── Fetch chats ────────────────────────────────────────────────────────────
  const fetchChats = useCallback(async () => {
    setLoadingChats(true);
    const data = await apiFetch<any>(`${BASE}/chats?filter=${filter}&limit=60`);
    if (data) {
      const list: Chat[] = (data.chats || data.data || (Array.isArray(data) ? data : [])).map((c: any) => ({
        id: c.id || c._id || c.identifier,
        identifier: c.identifier,
        platform: c.platform || 'c.us',
        contactName: c.contactName || c.name || c.identifier || 'Unknown',
        contactPhone: c.contactPhone || c.phone || c.identifier || '',
        lastMessage: c.lastMessage || c.preview || '',
        lastMessageTime: c.lastMessageTime || c.updatedAt || new Date().toISOString(),
        unreadCount: c.unreadCount || 0,
        status: c.status || 'open',
        isGroup: !!c.isGroup,
        tags: c.tags || [],
        assignedTo: c.assignedTo,
      }));
      setChats(list);
    }
    setLoadingChats(false);
  }, [filter]);

  useEffect(() => {
    fetchChats();
    chatPollRef.current = setInterval(fetchChats, 8000);
    return () => clearInterval(chatPollRef.current);
  }, [fetchChats]);

  // ── Fetch messages ─────────────────────────────────────────────────────────
  const fetchMessages = useCallback(async (chat: Chat) => {
    setLoadingMsgs(true);
    const data = await apiFetch<any>(`${BASE}/messages?identifier=${encodeURIComponent(chat.identifier)}&platform=${chat.platform}&limit=50`);
    if (data) {
      const list: Message[] = (data.messages || data.data || (Array.isArray(data) ? data : [])).map((m: any) => ({
        id: m.id || m._id || String(Math.random()),
        content: m.content || m.body || m.text || '',
        contentType: m.contentType || 'text',
        timestamp: m.timestamp || m.createdAt || new Date().toISOString(),
        sender: m.sender || { type: m.fromMe ? 'bot' : 'customer', name: m.fromMe ? 'AI' : (chat.contactName || 'Customer') },
        isFromMe: !!m.isFromMe || !!m.fromMe,
      }));
      setMessages(list);
    }
    setLoadingMsgs(false);
    setTimeout(() => msgEndRef.current?.scrollIntoView({ behavior: 'smooth' }), 100);
  }, []);

  // ── Select chat ────────────────────────────────────────────────────────────
  const selectChat = async (chat: Chat) => {
    clearInterval(msgPollRef.current);
    setSelectedChat(chat);
    setIsClaimed(!!chat.assignedTo);
    setMessages([]);
    setOrders([]);
    setInputText('');
    setQuickOpen(false);

    await fetchMessages(chat);

    // Pull recent orders from NovaGo backend
    if (chat.contactPhone) {
      const ords = await novaFetch<any>(`/api/orders?customerPhone=${encodeURIComponent(chat.contactPhone)}`);
      if (ords) setOrders((Array.isArray(ords) ? ords : ords.data || []).slice(0, 3));
    }

    // Poll messages for this chat
    msgPollRef.current = setInterval(() => fetchMessages(chat), 5000);
  };

  useEffect(() => () => clearInterval(msgPollRef.current), []);

  // ── Claim / Release ────────────────────────────────────────────────────────
  const handleTakeover = async () => {
    if (!selectedChat) return;
    setClaimLoading(true);
    const adminId = localStorage.getItem('novago_admin_id') || 'admin';

    if (isClaimed) {
      await apiFetch(`${BASE}/chats/release`, {
        method: 'POST',
        body: JSON.stringify({ identifier: selectedChat.identifier, platform: selectedChat.platform }),
      });
      setIsClaimed(false);
      pushSys('Released back to AI — NovaGo AI has resumed');
    } else {
      const res = await apiFetch(`${BASE}/chats/claim`, {
        method: 'POST',
        body: JSON.stringify({ identifier: selectedChat.identifier, platform: selectedChat.platform, agentId: adminId }),
      });
      if (res) {
        setIsClaimed(true);
        pushSys('You claimed this conversation — AI is paused');
      }
    }

    setClaimLoading(false);
    // Update the chat list to reflect new claimed state
    setChats(prev => prev.map(c =>
      c.identifier === selectedChat.identifier
        ? { ...c, assignedTo: isClaimed ? undefined : adminId }
        : c
    ));
  };

  // ── Send message ───────────────────────────────────────────────────────────
  const handleSend = async () => {
    const text = inputText.trim();
    if (!text || !selectedChat) return;

    if (inputMode === 'note') {
      pushMsg({
        id: `note-${Date.now()}`, content: text, contentType: 'note',
        timestamp: new Date().toISOString(),
        sender: { type: 'agent', name: 'Admin' }, isFromMe: true,
      });
    } else {
      if (!isClaimed) await handleTakeover();

      // Optimistic update
      pushMsg({
        id: `sent-${Date.now()}`, content: text, contentType: 'text',
        timestamp: new Date().toISOString(),
        sender: { type: 'agent', name: 'Admin' }, isFromMe: true,
      });

      await apiFetch(`${BASE}/messages/send`, {
        method: 'POST',
        body: JSON.stringify({
          identifier: selectedChat.identifier,
          platform: selectedChat.platform,
          content: text,
          contentType: 'text',
        }),
      });
    }

    setInputText('');
    if (taRef.current) taRef.current.style.height = 'auto';
    setTimeout(() => msgEndRef.current?.scrollIntoView({ behavior: 'smooth' }), 50);
  };

  const pushMsg = (m: Message) => setMessages(p => [...p, m]);
  const pushSys = (text: string) => pushMsg({
    id: `sys-${Date.now()}`, content: text, contentType: 'system',
    timestamp: new Date().toISOString(),
    sender: { type: 'bot', name: 'System' }, isFromMe: false,
  });

  const filteredChats = chats.filter(c => {
    if (search) {
      const q = search.toLowerCase();
      if (!c.contactName.toLowerCase().includes(q) && !c.contactPhone.includes(q)) return false;
    }
    const adminId = localStorage.getItem('novago_admin_id') || 'admin';
    if (filter === 'pending') return c.status === 'pending';
    if (filter === 'mine') return c.assignedTo === adminId;
    if (filter === 'ai') return !c.assignedTo;
    if (filter === 'groups') return c.isGroup;
    return true;
  });

  return (
    <div className="flex h-full">

      {/* ── Chat list ─────────────────────────────────────────────────────── */}
      <div className="w-72 border-r border-gray-200 flex flex-col bg-white flex-shrink-0">
        {/* Search */}
        <div className="p-3 border-b border-gray-100">
          <div className="flex items-center gap-2 bg-gray-50 border border-gray-200 rounded-lg px-3 py-2">
            <Search className="w-3.5 h-3.5 text-gray-400 flex-shrink-0" />
            <input
              value={search} onChange={e => setSearch(e.target.value)}
              placeholder="Search conversations…"
              className="flex-1 bg-transparent text-sm outline-none text-gray-700 placeholder-gray-400"
            />
            {search && (
              <button onClick={() => setSearch('')}>
                <X className="w-3.5 h-3.5 text-gray-400" />
              </button>
            )}
          </div>
        </div>

        {/* Filters */}
        <div className="flex gap-1.5 px-3 py-2 border-b border-gray-100 overflow-x-auto">
          {['all', 'pending', 'mine', 'ai', 'groups'].map(f => (
            <button
              key={f} onClick={() => setFilter(f)}
              className={`px-2.5 py-1 rounded-full text-[11px] font-medium whitespace-nowrap transition-colors ${
                filter === f
                  ? 'bg-green-100 text-green-700 border border-green-200'
                  : 'border border-gray-200 text-gray-500 hover:text-gray-700'
              }`}
            >
              {f === 'ai' ? 'AI Active' : f.charAt(0).toUpperCase() + f.slice(1)}
            </button>
          ))}
          <button onClick={fetchChats} className="ml-auto p-1 text-gray-400 hover:text-gray-600 flex-shrink-0">
            <RefreshCw className={`w-3.5 h-3.5 ${loadingChats ? 'animate-spin' : ''}`} />
          </button>
        </div>

        {/* Chat items */}
        <div className="flex-1 overflow-y-auto">
          {loadingChats && chats.length === 0 ? (
            <div className="flex items-center justify-center h-20">
              <Loader2 className="w-5 h-5 animate-spin text-gray-300" />
            </div>
          ) : filteredChats.length === 0 ? (
            <div className="flex flex-col items-center justify-center h-32 text-gray-300 gap-2">
              <MessageSquare className="w-8 h-8 opacity-40" />
              <p className="text-xs">No conversations yet</p>
            </div>
          ) : (
            filteredChats.map(chat => {
              const c = getColor(chat.contactName);
              const isSelected = selectedChat?.identifier === chat.identifier;
              const isAI = !chat.assignedTo;
              return (
                <button
                  key={chat.id} onClick={() => selectChat(chat)}
                  className={`w-full flex items-start gap-2.5 p-3 text-left border-b border-gray-50 transition-colors ${
                    isSelected ? 'bg-green-50 border-l-2 border-l-green-600' : 'hover:bg-gray-50'
                  }`}
                >
                  <div className="relative flex-shrink-0">
                    <div
                      className="w-9 h-9 rounded-full flex items-center justify-center text-xs font-bold"
                      style={{ background: c.bg, color: c.fg }}
                    >
                      {getInitials(chat.contactName)}
                    </div>
                    <span className={`absolute bottom-0 right-0 w-2.5 h-2.5 rounded-full border-2 border-white ${isAI ? 'bg-purple-500' : 'bg-blue-500'}`} />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between gap-1">
                      <span className="text-xs font-semibold text-gray-900 truncate">{chat.contactName}</span>
                      <span className="text-[10px] text-gray-400 flex-shrink-0">{timeAgo(chat.lastMessageTime)}</span>
                    </div>
                    <p className="text-xs text-gray-500 truncate mt-0.5">{chat.lastMessage}</p>
                    <div className="flex items-center gap-1 mt-1">
                      <span className={`inline-flex items-center gap-1 px-1.5 py-0.5 rounded-full text-[10px] font-semibold ${isAI ? 'bg-purple-100 text-purple-700' : 'bg-blue-100 text-blue-700'}`}>
                        {isAI ? <><Bot className="w-2.5 h-2.5" />AI</> : <><User className="w-2.5 h-2.5" />Agent</>}
                      </span>
                      {chat.unreadCount > 0 && (
                        <span className="ml-auto bg-green-600 text-white text-[10px] font-bold min-w-[17px] h-[17px] rounded-full flex items-center justify-center px-1">
                          {chat.unreadCount}
                        </span>
                      )}
                    </div>
                  </div>
                </button>
              );
            })
          )}
        </div>
      </div>

      {/* ── Thread ────────────────────────────────────────────────────────── */}
      <div className="flex-1 flex flex-col min-w-0">
        {!selectedChat ? (
          <div className="flex-1 flex flex-col items-center justify-center text-gray-300 gap-3">
            <MessageSquare className="w-14 h-14 opacity-30" />
            <p className="text-sm">Select a conversation to view</p>
          </div>
        ) : (
          <>
            {/* Thread header */}
            <div className="flex items-center gap-3 px-4 py-3 border-b border-gray-200 bg-white flex-shrink-0">
              <div
                className="w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold flex-shrink-0"
                style={{ background: getColor(selectedChat.contactName).bg, color: getColor(selectedChat.contactName).fg }}
              >
                {getInitials(selectedChat.contactName)}
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-semibold text-gray-900">{selectedChat.contactName}</p>
                <p className="text-xs text-gray-500 flex items-center gap-1">
                  {isClaimed
                    ? <><User className="w-3 h-3" />Agent active</>
                    : <><Bot className="w-3 h-3" />AI handling</>
                  }
                  <span className="mx-1">·</span>
                  {selectedChat.contactPhone}
                </p>
              </div>
              <button
                onClick={handleTakeover} disabled={claimLoading}
                className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold transition-colors ${
                  claimLoading ? 'opacity-50 cursor-not-allowed bg-gray-100 text-gray-400'
                  : isClaimed ? 'bg-blue-100 text-blue-700 hover:bg-blue-200'
                  : 'bg-green-600 text-white hover:bg-green-700'
                }`}
              >
                {claimLoading
                  ? <Loader2 className="w-3.5 h-3.5 animate-spin" />
                  : isClaimed
                    ? <><Bot className="w-3.5 h-3.5" />Release to AI</>
                    : <><UserCheck className="w-3.5 h-3.5" />Claim</>
                }
              </button>
            </div>

            {/* Messages */}
            <div className="flex-1 overflow-y-auto px-4 py-3 bg-gray-50 flex flex-col gap-2">
              {loadingMsgs ? (
                <div className="flex justify-center items-center h-20">
                  <Loader2 className="w-5 h-5 animate-spin text-gray-300" />
                </div>
              ) : messages.length === 0 ? (
                <div className="flex flex-col items-center justify-center h-20 text-gray-300 gap-1">
                  <MessageSquare className="w-8 h-8 opacity-30" />
                  <p className="text-xs">No messages yet</p>
                </div>
              ) : (
                messages.map(msg => {
                  if (msg.contentType === 'system') return (
                    <div key={msg.id} className="flex justify-center">
                      <span className="text-[11px] text-gray-500 bg-white border border-gray-200 rounded-full px-3 py-1 inline-flex items-center gap-1.5">
                        {msg.content}
                      </span>
                    </div>
                  );

                  if (msg.contentType === 'note') return (
                    <div key={msg.id} className="flex justify-center">
                      <div className="bg-amber-50 border border-amber-200 rounded-lg px-3 py-2 text-xs text-amber-800 flex items-center gap-2 max-w-xs">
                        <StickyNote className="w-3 h-3 flex-shrink-0" />
                        <span><strong>Note:</strong> {msg.content}</span>
                      </div>
                    </div>
                  );

                  const isOut = msg.isFromMe;
                  const isAgent = msg.sender.type === 'agent';
                  const avatarBg = isOut
                    ? isAgent ? '#2563eb' : '#16a34a'
                    : getColor(selectedChat.contactName).bg;
                  const avatarFg = isOut ? '#fff' : getColor(selectedChat.contactName).fg;

                  return (
                    <div
                      key={msg.id}
                      className={`flex gap-2 max-w-[78%] ${isOut ? 'flex-row-reverse self-end' : 'self-start'}`}
                    >
                      <div
                        className="w-6 h-6 rounded-full flex items-center justify-center text-[9px] font-bold flex-shrink-0 mt-1"
                        style={{ background: avatarBg, color: avatarFg }}
                      >
                        {isOut ? (isAgent ? 'A' : 'AI') : getInitials(selectedChat.contactName)}
                      </div>
                      <div>
                        {isOut && (
                          <p className={`text-[10px] font-semibold mb-1 text-right ${isAgent ? 'text-blue-600' : 'text-green-600'}`}>
                            {isAgent ? msg.sender.name : 'NovaGo AI'}
                          </p>
                        )}
                        <div
                          className={`px-3 py-2 rounded-xl text-sm leading-relaxed ${
                            isOut
                              ? isAgent
                                ? 'bg-blue-600 text-white rounded-tr-sm'
                                : 'bg-green-700 text-white rounded-tr-sm'
                              : 'bg-white text-gray-900 rounded-tl-sm border border-gray-200'
                          }`}
                          style={{ whiteSpace: 'pre-wrap' }}
                        >
                          {msg.content}
                        </div>
                        <p className={`text-[10px] text-gray-400 mt-1 ${isOut ? 'text-right' : ''}`}>
                          {fmtTime(msg.timestamp)}
                        </p>
                      </div>
                    </div>
                  );
                })
              )}
              <div ref={msgEndRef} />
            </div>

            {/* Quick replies dropdown */}
            {quickOpen && (
              <div className="border-t border-gray-200 bg-white px-3 py-2 flex flex-col gap-1 max-h-36 overflow-y-auto">
                <div className="flex items-center justify-between mb-1">
                  <span className="text-xs font-semibold text-gray-500">Quick Replies</span>
                  <button onClick={() => setQuickOpen(false)}>
                    <X className="w-3.5 h-3.5 text-gray-400" />
                  </button>
                </div>
                {QUICK_REPLIES.map(qr => (
                  <button
                    key={qr.label}
                    onClick={() => { setInputText(qr.text); setInputMode('reply'); setQuickOpen(false); taRef.current?.focus(); }}
                    className="flex items-center gap-2 px-2.5 py-2 text-xs text-left rounded-lg border border-gray-200 hover:border-green-300 hover:bg-green-50 hover:text-green-700 transition-colors"
                  >
                    <span>{qr.emoji}</span>
                    <span className="font-semibold">{qr.label}</span>
                    <span className="text-gray-400 truncate">— {qr.text.slice(0, 38)}…</span>
                  </button>
                ))}
              </div>
            )}

            {/* Input area */}
            <div className="border-t border-gray-200 bg-white flex-shrink-0">
              <div className="flex border-b border-gray-100">
                {(['reply', 'note'] as const).map(m => (
                  <button
                    key={m} onClick={() => setInputMode(m)}
                    className={`flex items-center gap-1.5 px-4 py-2 text-xs font-semibold border-b-2 transition-colors ${
                      inputMode === m
                        ? m === 'reply' ? 'text-green-700 border-green-600' : 'text-amber-600 border-amber-500'
                        : 'text-gray-400 border-transparent hover:text-gray-600'
                    }`}
                  >
                    {m === 'reply' ? <><Send className="w-3.5 h-3.5" />Reply</> : <><StickyNote className="w-3.5 h-3.5" />Note</>}
                  </button>
                ))}
                <div className="ml-auto flex items-center gap-1.5 px-3 text-xs text-gray-400">
                  <span className={`w-1.5 h-1.5 rounded-full ${isClaimed ? 'bg-blue-500' : 'bg-green-500 animate-pulse'}`} />
                  {isClaimed ? 'Agent active' : 'AI active'}
                </div>
              </div>

              {inputMode === 'note' && (
                <p className="text-xs text-amber-600 px-3 pt-2 pb-0">Internal note — not sent to customer</p>
              )}

              <div className="flex items-end gap-2 p-3">
                <button
                  onClick={() => setQuickOpen(!quickOpen)} title="Quick replies"
                  className="p-2 rounded-lg hover:bg-gray-100 text-gray-400 hover:text-gray-600 transition-colors"
                >
                  <Zap className="w-4 h-4" />
                </button>
                <button className="p-2 rounded-lg hover:bg-gray-100 text-gray-400 transition-colors" title="Attach">
                  <Paperclip className="w-4 h-4" />
                </button>
                <textarea
                  ref={taRef} rows={1} value={inputText}
                  onChange={e => setInputText(e.target.value)}
                  onKeyDown={e => { if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); handleSend(); } }}
                  onInput={e => {
                    const t = e.target as HTMLTextAreaElement;
                    t.style.height = 'auto';
                    t.style.height = Math.min(t.scrollHeight, 120) + 'px';
                  }}
                  placeholder={
                    inputMode === 'note' ? 'Write an internal note…'
                    : isClaimed ? 'Type your reply…'
                    : 'Claim conversation to reply manually, or AI handles automatically…'
                  }
                  className={`flex-1 text-sm px-3 py-2 rounded-lg resize-none outline-none border transition-colors max-h-28 ${
                    inputMode === 'note'
                      ? 'bg-amber-50 border-amber-200 focus:border-amber-400'
                      : 'bg-gray-50 border-gray-200 focus:border-green-500 focus:bg-white'
                  }`}
                />
                <button
                  onClick={handleSend} disabled={!inputText.trim()}
                  className={`p-2 rounded-lg transition-colors disabled:opacity-40 disabled:cursor-not-allowed ${
                    inputMode === 'note'
                      ? 'bg-amber-100 text-amber-700 hover:bg-amber-200'
                      : 'bg-green-600 text-white hover:bg-green-700'
                  }`}
                >
                  <Send className="w-4 h-4" />
                </button>
              </div>
            </div>
          </>
        )}
      </div>

      {/* ── Right panel ───────────────────────────────────────────────────── */}
      {selectedChat && (
        <div className="w-56 border-l border-gray-200 bg-white flex flex-col overflow-y-auto flex-shrink-0">
          {/* Contact */}
          <div className="p-3 border-b border-gray-100">
            <p className="text-[10px] font-bold uppercase tracking-widest text-gray-400 mb-3">Customer</p>
            <div
              className="w-12 h-12 rounded-full flex items-center justify-center text-base font-bold mx-auto mb-2"
              style={{ background: getColor(selectedChat.contactName).bg, color: getColor(selectedChat.contactName).fg }}
            >
              {getInitials(selectedChat.contactName)}
            </div>
            <p className="text-sm font-semibold text-gray-900 text-center">{selectedChat.contactName}</p>
            <p className="text-xs text-gray-400 text-center">{selectedChat.contactPhone}</p>
          </div>

          {/* Session info */}
          <div className="p-3 border-b border-gray-100">
            <p className="text-[10px] font-bold uppercase tracking-widest text-gray-400 mb-2">Session</p>
            {[
              { icon: Bot,   label: 'Mode',     val: isClaimed ? 'Agent Active' : 'AI Active', cls: isClaimed ? 'text-blue-600' : 'text-green-600' },
              { icon: Clock, label: 'Last seen', val: timeAgo(selectedChat.lastMessageTime) + ' ago', cls: '' },
              { icon: Info,  label: 'Status',   val: selectedChat.status, cls: '' },
            ].map(r => (
              <div key={r.label} className="flex items-center justify-between py-1.5 text-xs border-b border-gray-50 last:border-0">
                <span className="text-gray-400 flex items-center gap-1.5">
                  <r.icon className="w-3 h-3" />{r.label}
                </span>
                <span className={`font-medium truncate max-w-[110px] ${r.cls || 'text-gray-700'}`}>{r.val}</span>
              </div>
            ))}
          </div>

          {/* Recent orders */}
          <div className="p-3 border-b border-gray-100">
            <p className="text-[10px] font-bold uppercase tracking-widest text-gray-400 mb-2">Recent Orders</p>
            {orders.length === 0
              ? <p className="text-xs text-gray-400">No orders found</p>
              : orders.map(o => (
                <div key={o.id} className="bg-gray-50 rounded-lg p-2 mb-1.5 border border-gray-100">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-bold text-gray-700">{o.id}</span>
                    <span className={`text-[10px] font-semibold px-1.5 py-0.5 rounded-full ${
                      o.status === 'delivered' ? 'bg-blue-100 text-blue-700'
                      : o.status === 'preparing' ? 'bg-green-100 text-green-700'
                      : 'bg-amber-100 text-amber-700'
                    }`}>{o.status}</span>
                  </div>
                  <p className="text-[11px] text-gray-400 mt-0.5">KSh {(o.total || 0).toFixed(0)}</p>
                </div>
              ))
            }
          </div>

          {/* Quick replies */}
          <div className="p-3">
            <p className="text-[10px] font-bold uppercase tracking-widest text-gray-400 mb-2">Quick Replies</p>
            {QUICK_REPLIES.map(qr => (
              <button
                key={qr.label}
                onClick={() => { setInputText(qr.text); setInputMode('reply'); taRef.current?.focus(); }}
                className="w-full text-left flex items-center gap-2 px-2 py-1.5 text-xs rounded-lg border border-gray-100 hover:border-green-200 hover:bg-green-50 hover:text-green-700 transition-colors mb-1"
              >
                <span>{qr.emoji}</span>
                <span className="font-medium">{qr.label}</span>
              </button>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}

// ── Root page ─────────────────────────────────────────────────────────────────

export default function WhatsApp() {
  const [tab, setTab] = useState<'connect' | 'inbox'>('connect');
  const [connected, setConnected] = useState(false);
  const [connectedPhone, setConnectedPhone] = useState('');
  const [totalUnread, setTotalUnread] = useState(0);

  // Check for existing session on mount
  useEffect(() => {
    (async () => {
      const sessions = await apiFetch<any[]>(`${BASE}/sessions`);
      if (Array.isArray(sessions) && sessions.length > 0) {
        const s = sessions[0];
        const state = (s.state || s.status || '').toUpperCase();
        if (state === 'CONNECTED') {
          setConnected(true);
          setConnectedPhone(s.phone || '');
          setTab('inbox');
        }
      }
    })();
  }, []);

  const onConnected = (phone?: string) => {
    setConnected(true);
    setConnectedPhone(phone || '');
    setTab('inbox');
  };

  return (
    <div className="h-full flex flex-col">
      {/* Page header */}
      <div className="bg-white border-b border-gray-200 px-6 py-3 flex items-center gap-4 flex-shrink-0">
        <div className="flex items-center gap-2">
          <MessageSquare className="w-5 h-5 text-green-600" />
          <h1 className="text-base font-bold text-gray-900">WhatsApp</h1>
        </div>

        <div className="flex gap-1 ml-2">
          <button
            onClick={() => setTab('connect')}
            className={`px-4 py-1.5 rounded-lg text-sm font-medium transition-colors flex items-center gap-1.5 ${
              tab === 'connect' ? 'bg-green-600 text-white' : 'text-gray-600 hover:bg-gray-100'
            }`}
          >
            {connected
              ? <><CheckCircle2 className="w-3.5 h-3.5" />Connected</>
              : 'Connect WhatsApp'
            }
          </button>

          <button
            onClick={() => setTab('inbox')}
            className={`px-4 py-1.5 rounded-lg text-sm font-medium transition-colors flex items-center gap-1.5 ${
              tab === 'inbox' ? 'bg-green-600 text-white' : 'text-gray-600 hover:bg-gray-100'
            }`}
          >
            Inbox
            {totalUnread > 0 && (
              <span className="bg-red-500 text-white text-[10px] px-1.5 py-0.5 rounded-full font-bold">
                {totalUnread}
              </span>
            )}
          </button>
        </div>

        {connected && (
          <div className="ml-auto flex items-center gap-2 text-xs">
            <span className="w-2 h-2 bg-green-500 rounded-full animate-pulse" />
            <span className="text-green-700 font-semibold">AI Active</span>
            {connectedPhone && <span className="text-gray-400">{connectedPhone}</span>}
          </div>
        )}
      </div>

      {/* Tab content */}
      <div className="flex-1 overflow-hidden">
        {tab === 'connect' ? (
          <QRConnectPanel onConnected={onConnected} />
        ) : (
          <InboxPanel />
        )}
      </div>
    </div>
  );
}
