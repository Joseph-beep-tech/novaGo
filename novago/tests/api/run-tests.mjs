const BASE_URL = process.env.API_BASE_URL || 'http://localhost:4000';
const state = {};
const results = [];

function log(message) {
  process.stdout.write(message);
}

async function request(path, options = {}) {
  const url = `${BASE_URL}${path}`;
  const mergedOptions = {
    headers: { 'Content-Type': 'application/json', ...(options.headers || {}) },
    ...options,
  };
  const response = await fetch(url, mergedOptions);
  const contentType = response.headers.get('content-type') || '';
  const payload = contentType.includes('application/json')
    ? await response.json()
    : await response.text();

  if (!response.ok) {
    const error = new Error(`Request failed: ${response.status} ${response.statusText}`);
    error.response = { status: response.status, body: payload };
    throw error;
  }

  return payload;
}

async function run(name, fn) {
  const start = Date.now();
  log(`→ ${name}... `);
  try {
    await fn();
    const duration = Date.now() - start;
    log(`ok (${duration}ms)\n`);
    results.push({ name, status: 'passed', duration });
  } catch (error) {
    const duration = Date.now() - start;
    log(`FAILED (${duration}ms)\n`);
    console.error(error.response ?? error);
    results.push({ name, status: 'failed', duration, error });
    throw error;
  }
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main() {
  await run('Health check', async () => {
    const health = await request('/health');
    if (health.status !== 'ok') {
      throw new Error('Health endpoint did not return ok status');
    }
  });

  await run('Fetch restaurants', async () => {
    const restaurants = await request('/api/restaurants');
    if (!restaurants.length) throw new Error('No restaurants available');
    state.restaurant = restaurants[0];
  });

  await run('Fetch menu for restaurant', async () => {
    const menu = await request(`/api/menus/restaurant/${state.restaurant.id}`);
    if (!menu.length) throw new Error('No menu items available for restaurant');
    state.menuItem = menu[0];
  });

  await run('Create order', async () => {
    const orderPayload = {
      restaurantId: state.restaurant.id,
      restaurantLocation: state.restaurant.location,
      customerName: 'Automation Bot',
      customerPhone: '+1 (555) 999-0000',
      deliveryAddress: '123 Automation Way, Test City',
      deliveryLocation: { lat: 40.7128, lng: -74.006, address: '123 Automation Way' },
      items: [
        {
          menuItemId: state.menuItem.id,
          quantity: 1,
        },
      ],
    };

    const order = await request('/api/orders', {
      method: 'POST',
      body: JSON.stringify(orderPayload),
    });

    state.order = order;
  });

  await run('Assign rider', async () => {
    const riders = await request('/api/riders');
    const available = riders.find((rider) => rider.status === 'available');
    if (!available) throw new Error('No available riders to assign');

    const { order } = await request(`/api/orders/${state.order.id}/assign-rider`, {
      method: 'PATCH',
      body: JSON.stringify({ riderId: available.id }),
    });

    state.order = order;
  });

  await run('Advance order status pipeline', async () => {
    const pipeline = ['preparing', 'ready', 'picked_up', 'on_the_way', 'delivered'];
    for (const status of pipeline) {
      await request(`/api/orders/${state.order.id}/status`, {
        method: 'PATCH',
        body: JSON.stringify({ status }),
      });
    }
  });

  await run('Fetch tracking snapshot', async () => {
    const tracking = await request(`/api/orders/${state.order.id}/tracking`);
    if (tracking.status !== 'delivered') {
      throw new Error('Tracking snapshot did not reflect delivered status');
    }
    state.tracking = tracking;
  });

  await run('Verify payment completion', async () => {
    await sleep(2500); // wait for simulated payment completion
    const payment = await request(`/api/payments/order/${state.order.id}`);
    if (payment.status !== 'completed') {
      throw new Error(`Payment status is ${payment.status}`);
    }
    state.payment = payment;
  });

  log('\nSummary:\n');
  results.forEach((result) => {
    log(`- ${result.name}: ${result.status} (${result.duration}ms)\n`);
  });
}

main().catch((error) => {
  console.error('\nAutomation suite failed.');
  process.exit(1);
});

