import { Router } from 'express';
import { z } from 'zod';
import { Order, OrderStatus, OrderTrackingSnapshot } from './order.types';
import { createPaymentForOrder } from '../payments/payment.routes';
import { prisma } from '../../utils/prisma';

export const orderRouter = Router();

const locationSchema = z.object({
  lat: z.number(),
  lng: z.number(),
  address: z.string().optional(),
});

const orderCreateSchema = z.object({
  restaurantId: z.string().min(1),
  restaurantLocation: locationSchema.optional(),
  customerName: z.string().min(1),
  customerPhone: z.string().optional(),
  deliveryAddress: z.string().min(1),
  deliveryLocation: locationSchema.optional(),
  items: z.array(
    z.object({
      menuItemId: z.string().min(1),
      quantity: z.number().int().positive(),
    }),
  ).min(1),
});

// Create order (checkout) – DB only
orderRouter.post('/', async (req, res) => {
  const parsed = orderCreateSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ message: 'Invalid payload', errors: parsed.error.flatten() });
  }

  const data = parsed.data;

  // Resolve menu items from DB
  const detailedItems = await Promise.all(
    data.items.map(async (i) => {
      const dbMenu = await prisma.menuItem.findUnique({
        where: { id: i.menuItemId },
      });
      if (!dbMenu) {
        throw new Error(`Menu item not found: ${i.menuItemId}`);
      }
      return {
        menuItemId: dbMenu.id,
        name: dbMenu.name,
        price: dbMenu.price,
        quantity: i.quantity,
      };
    }),
  );

  const subtotal = detailedItems.reduce((sum, item) => sum + item.price * item.quantity, 0);
  const deliveryFee = 2.99;
  const tax = subtotal * 0.08;
  const total = subtotal + deliveryFee + tax;

  const now = new Date().toISOString();
  const id = `ORD-${Date.now().toString(36).toUpperCase()}`;

  const historyEntry = (status: OrderStatus, message: string) => ({
    id: `${id}-${status}-${Date.now()}`,
    status,
    message,
    timestamp: now,
  });

  const order: Order = {
    id,
    restaurantId: data.restaurantId,
    restaurantLocation: data.restaurantLocation,
    items: detailedItems,
    subtotal,
    deliveryFee,
    tax,
    total,
    status: 'pending',
    customerName: data.customerName,
    customerPhone: data.customerPhone,
    deliveryAddress: data.deliveryAddress,
    deliveryLocation: data.deliveryLocation,
    etaMinutes: 30,
    statusHistory: [
      historyEntry('pending', 'Order placed'),
      historyEntry('pending', 'Waiting for restaurant confirmation'),
    ],
    createdAt: now,
    updatedAt: now,
  };

  try {
    await prisma.order.create({
      data: {
        id: order.id,
        restaurantId: order.restaurantId,
        subtotal: order.subtotal,
        deliveryFee: order.deliveryFee,
        tax: order.tax,
        total: order.total,
        status: order.status,
        customerName: order.customerName,
        customerPhone: order.customerPhone ?? null,
        deliveryAddress: order.deliveryAddress,
        driverId: order.driverId ?? null,
        etaMinutes: order.etaMinutes ?? null,
        items: {
          create: order.items.map((item) => ({
            menuItemId: item.menuItemId,
            name: item.name,
            price: item.price,
            quantity: item.quantity,
          })),
        },
        statusHistory: {
          create: order.statusHistory.map((step) => ({
            id: step.id,
            status: step.status,
            message: step.message,
            timestamp: new Date(step.timestamp),
          })),
        },
      },
    });
  } catch (err) {
    console.error('Error creating order in DB:', err);
    return res.status(500).json({ message: 'Failed to create order' });
  }

  createPaymentForOrder(order.id, order.total, order.customerName, order.restaurantId);
  res.status(201).json(order);
});

// Helper to map Prisma order + relations to API Order shape (locations currently not persisted)
function mapDbOrder(dbOrder: any): Order {
  return {
    id: dbOrder.id,
    restaurantId: dbOrder.restaurantId,
    restaurantLocation: undefined,
    items: (dbOrder.items ?? []).map((item: any) => ({
      menuItemId: item.menuItemId,
      name: item.name,
      price: item.price,
      quantity: item.quantity,
    })),
    subtotal: dbOrder.subtotal,
    deliveryFee: dbOrder.deliveryFee,
    tax: dbOrder.tax,
    total: dbOrder.total,
    status: dbOrder.status,
    customerName: dbOrder.customerName,
    customerPhone: dbOrder.customerPhone ?? undefined,
    deliveryAddress: dbOrder.deliveryAddress,
    deliveryLocation: undefined,
    driverId: dbOrder.driverId ?? undefined,
    etaMinutes: dbOrder.etaMinutes ?? undefined,
    statusHistory: (dbOrder.statusHistory ?? []).map((step: any) => ({
      id: step.id,
      status: step.status,
      message: step.message,
      timestamp: step.timestamp.toISOString(),
    })),
    createdAt: dbOrder.createdAt.toISOString(),
    updatedAt: dbOrder.updatedAt.toISOString(),
  };
}

// List orders (simple, no auth yet) – DB only
orderRouter.get('/', async (_req, res) => {
  try {
    const dbOrders = await prisma.order.findMany({
      include: {
        items: true,
        statusHistory: true,
      },
      orderBy: { createdAt: 'desc' },
    });
    return res.json(dbOrders.map(mapDbOrder));
  } catch (err) {
    console.error('Error fetching orders from DB:', err);
    return res.status(500).json({ message: 'Failed to fetch orders' });
  }
});

// Get orders by restaurant – DB only
orderRouter.get('/restaurant/:restaurantId', async (req, res) => {
  try {
    const dbOrders = await prisma.order.findMany({
      where: { restaurantId: req.params.restaurantId },
      include: {
        items: true,
        statusHistory: true,
      },
      orderBy: { createdAt: 'desc' },
    });
    return res.json(dbOrders.map(mapDbOrder));
  } catch (err) {
    console.error('Error fetching restaurant orders from DB:', err);
    return res.status(500).json({ message: 'Failed to fetch restaurant orders' });
  }
});

// Get single order – DB only
orderRouter.get('/:id', async (req, res) => {
  try {
    const dbOrder = await prisma.order.findUnique({
      where: { id: req.params.id },
      include: {
        items: true,
        statusHistory: true,
      },
    });
    if (!dbOrder) {
      return res.status(404).json({ message: 'Order not found' });
    }
    return res.json(mapDbOrder(dbOrder));
  } catch (err) {
    console.error('Error fetching order from DB:', err);
    return res.status(500).json({ message: 'Failed to fetch order' });
  }
});

// Update order status (for driver/restaurant)
const statusSchema = z.object({
  status: z.custom<OrderStatus>((val) =>
    ['pending','confirmed','preparing','ready','assigned','picked_up','on_the_way','delivered','cancelled']
      .includes(String(val)),
  ),
  message: z.string().optional(),
});

orderRouter.patch('/:id/status', async (req, res) => {
  const parsed = statusSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ message: 'Invalid status', errors: parsed.error.flatten() });
  }

  const status = parsed.data.status as OrderStatus;
  const message = parsed.data.message ?? `Order marked as ${status.replace('_', ' ')}`;
  const now = new Date().toISOString();

  try {
    const updated = await prisma.order.update({
      where: { id: req.params.id },
      data: {
        status,
        updatedAt: new Date(now),
        statusHistory: {
          create: {
            id: `${req.params.id}-${status}-${Date.now()}`,
            status,
            message,
            timestamp: new Date(now),
          },
        },
      },
      include: {
        items: true,
        statusHistory: true,
      },
    });
    return res.json(mapDbOrder(updated));
  } catch (err: any) {
    console.error('Error updating order status in DB:', err);
    if (err.code === 'P2025') {
      return res.status(404).json({ message: 'Order not found' });
    }
    return res.status(500).json({ message: 'Failed to update order status' });
  }
});

const assignSchema = z.object({
  riderId: z.string().min(1),
});

orderRouter.patch('/:id/assign-rider', async (req, res) => {
  const parsed = assignSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ message: 'Invalid payload', errors: parsed.error.flatten() });
  }

  const { riderId } = parsed.data;

  try {
    const dbRider = await prisma.rider.findUnique({ where: { id: riderId } });
    if (!dbRider) {
      return res.status(404).json({ message: 'Rider not found' });
    }

    if (!dbRider.isActive || dbRider.status === 'busy') {
      return res.status(409).json({ message: 'Rider is not available' });
    }

    const dbOrder = await prisma.order.update({
      where: { id: req.params.id },
      data: {
        driverId: riderId,
        status: 'assigned',
        statusHistory: {
          create: {
            id: `${req.params.id}-assigned-${Date.now()}`,
            status: 'assigned',
            message: `Rider ${dbRider.name} assigned`,
            timestamp: new Date(),
          },
        },
      },
      include: { items: true, statusHistory: true },
    });

    const updatedRider = await prisma.rider.update({
      where: { id: riderId },
      data: {
        status: 'busy',
        currentOrderId: dbOrder.id,
      },
    });

    return res.json({ order: mapDbOrder(dbOrder), rider: updatedRider });
  } catch (err: any) {
    console.error('Error assigning rider in DB:', err);
    if (err.code === 'P2025') {
      return res.status(404).json({ message: 'Order not found' });
    }
    return res.status(500).json({ message: 'Failed to assign rider' });
  }
});

// Get tracking info snapshot – DB only
orderRouter.get('/:id/tracking', async (req, res) => {
  try {
    const dbOrder = await prisma.order.findUnique({
      where: { id: req.params.id },
      include: {
        statusHistory: true,
      },
    });

    if (!dbOrder) {
      return res.status(404).json({ message: 'Order not found' });
    }

    // Rider location is currently stored only on Rider, not on Order
    const dbRider = dbOrder.driverId
      ? await prisma.rider.findUnique({ where: { id: dbOrder.driverId } })
      : null;

    const snapshot: OrderTrackingSnapshot = {
      orderId: dbOrder.id,
      driverId: dbOrder.driverId ?? undefined,
      driverLocation:
        dbRider && dbRider.currentLat != null && dbRider.currentLng != null
          ? { lat: dbRider.currentLat, lng: dbRider.currentLng }
          : undefined,
      customerLocation: undefined,
      restaurantLocation: undefined,
      status: dbOrder.status,
      etaMinutes: dbOrder.etaMinutes ?? undefined,
      steps: (dbOrder.statusHistory ?? []).map((step: any) => ({
        id: step.id,
        status: step.status,
        message: step.message,
        timestamp: step.timestamp.toISOString(),
      })),
    };

    return res.json(snapshot);
  } catch (err) {
    console.error('Error fetching tracking info from DB:', err);
    return res.status(500).json({ message: 'Failed to fetch tracking info' });
  }
});


