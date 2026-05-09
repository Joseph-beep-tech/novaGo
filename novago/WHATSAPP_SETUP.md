# NovaGo WhatsApp AI Integration Setup

## Architecture

```
Customer (WhatsApp)
      │
wwebjs-api (port 3000)   ← generates QR, receives messages, sends replies
      │  webhook
whatsapp-service (3001)  ← AI brain: reads NovaGo menus, manages conversations
      │  REST
NovaGo Backend (4000)    ← orders, menus, restaurants, payments
      │
Admin Portal (5173)      ← Connect tab (QR scan) + Inbox tab (chat with customers)
```

## Step 1 — Backend env vars

Add to `novago/backend/.env`:
```
WA_API_URL=http://localhost:3000
WA_SVC_URL=http://localhost:3001
WA_API_KEY=your-shared-api-key
```

## Step 2 — Admin portal env vars

Add to `novago/admin-portal/.env`:
```
VITE_WA_API_URL=http://localhost:3000
VITE_WA_SVC_URL=http://localhost:3001
VITE_WA_API_KEY=your-shared-api-key
```

## Step 3 — Wire wwebjs-api webhook to NovaGo

In wwebjs-api `.env`, set:
```
BASE_WEBHOOK_URL=http://localhost:4000/api/whatsapp/webhook
API_KEY=your-shared-api-key
```

## Step 4 — Connect WhatsApp

1. Start all services
2. Open Admin Portal → click **WhatsApp** in sidebar
3. Click **Connect WhatsApp** tab
4. Enter a session name (e.g. `novago-main`) → click **Connect**
5. QR code appears → scan with your WhatsApp Business phone
6. Status changes to **Connected** → AI is now live

## Step 5 — Admin can chat manually

- Go to **Inbox** tab
- See all customer conversations (AI-handled shown with 🟣 purple dot)
- Click any conversation
- Click **Claim** to pause AI and type replies yourself
- Click **Release to AI** to hand back to the AI agent
- Use **Note** tab for internal notes (not sent to customer)
- Use ⚡ Quick Replies for common responses

## How the AI reads restaurant data

The whatsapp-service AI handler calls:
```
GET http://localhost:4000/api/restaurants          ← list restaurants
GET http://localhost:4000/api/menus/restaurant/:id ← menu items + prices
POST http://localhost:4000/api/orders              ← place order
```

All menus and prices come live from the NovaGo database — no duplication.
