"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.orderRouter = void 0;
const express_1 = require("express");
const zod_1 = require("zod");
const payment_routes_1 = require("../payments/payment.routes");
const prisma_1 = require("../../utils/prisma");
exports.orderRouter = (0, express_1.Router)();
const locationSchema = zod_1.z.object({
    lat: zod_1.z.number(),
    lng: zod_1.z.number(),
    address: zod_1.z.string().optional(),
});
const orderCreateSchema = zod_1.z.object({
    restaurantId: zod_1.z.string().min(1),
    restaurantLocation: locationSchema.optional(),
    customerName: zod_1.z.string().min(1),
    customerPhone: zod_1.z.string().optional(),
    deliveryAddress: zod_1.z.string().min(1),
    deliveryLocation: locationSchema.optional(),
    items: zod_1.z.array(zod_1.z.object({
        menuItemId: zod_1.z.string().min(1),
        quantity: zod_1.z.number().int().positive(),
    })).min(1),
});
// Create order (checkout) – DB only
exports.orderRouter.post('/', async (req, res) => {
    const parsed = orderCreateSchema.safeParse(req.body);
    if (!parsed.success) {
        return res.status(400).json({ message: 'Invalid payload', errors: parsed.error.flatten() });
    }
    const data = parsed.data;
    // Resolve menu items from DB
    const detailedItems = await Promise.all(data.items.map(async (i) => {
        const dbMenu = await prisma_1.prisma.menuItem.findUnique({
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
    }));
    const subtotal = detailedItems.reduce((sum, item) => sum + item.price * item.quantity, 0);
    const deliveryFee = 2.99;
    const tax = subtotal * 0.08;
    const total = subtotal + deliveryFee + tax;
    const now = new Date().toISOString();
    const id = `ORD-${Date.now().toString(36).toUpperCase()}`;
    const historyEntry = (status, message) => ({
        id: `${id}-${status}-${Date.now()}`,
        status,
        message,
        timestamp: now,
    });
    const order = {
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
        await prisma_1.prisma.order.create({
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
    }
    catch (err) {
        console.error('Error creating order in DB:', err);
        return res.status(500).json({ message: 'Failed to create order' });
    }
    (0, payment_routes_1.createPaymentForOrder)(order.id, order.total, order.customerName, order.restaurantId);
    res.status(201).json(order);
});
// Helper to map Prisma order + relations to API Order shape (locations currently not persisted)
function mapDbOrder(dbOrder) {
    return {
        id: dbOrder.id,
        restaurantId: dbOrder.restaurantId,
        restaurantLocation: undefined,
        items: (dbOrder.items ?? []).map((item) => ({
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
        statusHistory: (dbOrder.statusHistory ?? []).map((step) => ({
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
exports.orderRouter.get('/', async (_req, res) => {
    try {
        const dbOrders = await prisma_1.prisma.order.findMany({
            include: {
                items: true,
                statusHistory: true,
            },
            orderBy: { createdAt: 'desc' },
        });
        return res.json(dbOrders.map(mapDbOrder));
    }
    catch (err) {
        console.error('Error fetching orders from DB:', err);
        return res.status(500).json({ message: 'Failed to fetch orders' });
    }
});
// Get orders by restaurant – DB only
exports.orderRouter.get('/restaurant/:restaurantId', async (req, res) => {
    try {
        const dbOrders = await prisma_1.prisma.order.findMany({
            where: { restaurantId: req.params.restaurantId },
            include: {
                items: true,
                statusHistory: true,
            },
            orderBy: { createdAt: 'desc' },
        });
        return res.json(dbOrders.map(mapDbOrder));
    }
    catch (err) {
        console.error('Error fetching restaurant orders from DB:', err);
        return res.status(500).json({ message: 'Failed to fetch restaurant orders' });
    }
});
// Get single order – DB only
exports.orderRouter.get('/:id', async (req, res) => {
    try {
        const dbOrder = await prisma_1.prisma.order.findUnique({
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
    }
    catch (err) {
        console.error('Error fetching order from DB:', err);
        return res.status(500).json({ message: 'Failed to fetch order' });
    }
});
// Update order status (for driver/restaurant)
const statusSchema = zod_1.z.object({
    status: zod_1.z.custom((val) => ['pending', 'confirmed', 'preparing', 'ready', 'assigned', 'picked_up', 'on_the_way', 'delivered', 'cancelled']
        .includes(String(val))),
    message: zod_1.z.string().optional(),
});
exports.orderRouter.patch('/:id/status', async (req, res) => {
    const parsed = statusSchema.safeParse(req.body);
    if (!parsed.success) {
        return res.status(400).json({ message: 'Invalid status', errors: parsed.error.flatten() });
    }
    const status = parsed.data.status;
    const message = parsed.data.message ?? `Order marked as ${status.replace('_', ' ')}`;
    const now = new Date().toISOString();
    try {
        const updated = await prisma_1.prisma.order.update({
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
    }
    catch (err) {
        console.error('Error updating order status in DB:', err);
        if (err.code === 'P2025') {
            return res.status(404).json({ message: 'Order not found' });
        }
        return res.status(500).json({ message: 'Failed to update order status' });
    }
});
const assignSchema = zod_1.z.object({
    riderId: zod_1.z.string().min(1),
});
exports.orderRouter.patch('/:id/assign-rider', async (req, res) => {
    const parsed = assignSchema.safeParse(req.body);
    if (!parsed.success) {
        return res.status(400).json({ message: 'Invalid payload', errors: parsed.error.flatten() });
    }
    const { riderId } = parsed.data;
    try {
        const dbRider = await prisma_1.prisma.rider.findUnique({ where: { id: riderId } });
        if (!dbRider) {
            return res.status(404).json({ message: 'Rider not found' });
        }
        if (!dbRider.isActive || dbRider.status === 'busy') {
            return res.status(409).json({ message: 'Rider is not available' });
        }
        const dbOrder = await prisma_1.prisma.order.update({
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
        const updatedRider = await prisma_1.prisma.rider.update({
            where: { id: riderId },
            data: {
                status: 'busy',
                currentOrderId: dbOrder.id,
            },
        });
        return res.json({ order: mapDbOrder(dbOrder), rider: updatedRider });
    }
    catch (err) {
        console.error('Error assigning rider in DB:', err);
        if (err.code === 'P2025') {
            return res.status(404).json({ message: 'Order not found' });
        }
        return res.status(500).json({ message: 'Failed to assign rider' });
    }
});
// Get tracking info snapshot – DB only
exports.orderRouter.get('/:id/tracking', async (req, res) => {
    try {
        const dbOrder = await prisma_1.prisma.order.findUnique({
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
            ? await prisma_1.prisma.rider.findUnique({ where: { id: dbOrder.driverId } })
            : null;
        const snapshot = {
            orderId: dbOrder.id,
            driverId: dbOrder.driverId ?? undefined,
            driverLocation: dbRider && dbRider.currentLat != null && dbRider.currentLng != null
                ? { lat: dbRider.currentLat, lng: dbRider.currentLng }
                : undefined,
            customerLocation: undefined,
            restaurantLocation: undefined,
            status: dbOrder.status,
            etaMinutes: dbOrder.etaMinutes ?? undefined,
            steps: (dbOrder.statusHistory ?? []).map((step) => ({
                id: step.id,
                status: step.status,
                message: step.message,
                timestamp: step.timestamp.toISOString(),
            })),
        };
        return res.json(snapshot);
    }
    catch (err) {
        console.error('Error fetching tracking info from DB:', err);
        return res.status(500).json({ message: 'Failed to fetch tracking info' });
    }
});
