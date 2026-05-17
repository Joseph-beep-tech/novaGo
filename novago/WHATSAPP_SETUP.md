# NovaGo WhatsApp Setup

## Start everything (3 terminals)

### Terminal 1 — Mock WhatsApp API (wwebjs-api replacement for development)
```bash
cd novago
node mock-wwebjs-api.js
# Runs on http://localhost:3000
```

### Terminal 2 — NovaGo Backend
```bash
cd novago/backend
npm run dev
# Runs on http://localhost:4000
# .env already has WA_API_URL=http://localhost:3000
```

### Terminal 3 — Admin Portal
```bash
cd novago/admin-portal
npm run dev
# Runs on http://localhost:5173
```

## Connect WhatsApp
1. Open http://localhost:5173
2. Login → click WhatsApp in sidebar
3. Session name: `novago-main` → click **Connect**
4. Wait 2–3 seconds → QR code appears
5. In Terminal 1, you'll see: `📱 [novago-main] → SCAN_QR_CODE`

## Simulate a phone scan (dev only)
Instead of scanning with a real phone, open this URL in your browser:
```
http://localhost:3000/session/novago-main/mock-connect
```
The admin portal will automatically show "WhatsApp Connected!" and switch to the Inbox tab.

## Production (real WhatsApp)
- Replace the mock with the real wwebjs-api: https://github.com/kulemantu/wwebjs-api
- Start it on port 3000
- The backend .env WA_API_URL=http://localhost:3000 already points to it
- No code changes needed
