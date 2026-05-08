# NovaGo API Automation Tests

This lightweight test harness exercises the critical restaurant → order → rider → payment workflow directly against the backend REST API.

## Prerequisites

1. Backend running locally (default `http://localhost:4000`).  
   ```bash
   cd backend
   npm install
   npm run dev
   ```

2. Node.js 18+ (the script uses the built-in `fetch` API).

## Running the suite

```bash
cd tests/api
npm install        # first run only
npm test
```

You can point to another environment by setting `API_BASE_URL`:

```bash
API_BASE_URL=https://staging.novago.com npm test
```

## What it validates

1. `/health` responds with `status: ok`.
2. Restaurants and menus can be fetched.
3. An order can be created against the first restaurant/menu item.
4. A rider can be assigned to the order.
5. The order status pipeline advances through preparing → delivered.
6. Tracking snapshot reflects the final state.
7. The payment record transitions to `completed`.

The script logs each step with timing information and fails fast if any assertion does not hold. Use it in CI/CD or before releases to ensure the critical delivery flow stays healthy.

