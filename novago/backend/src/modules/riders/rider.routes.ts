import { Router } from 'express';
import { z } from 'zod';
import { RiderStatus, Rider } from './rider.types';
import { prisma } from '../../utils/prisma';

export const riderRouter = Router();

function mapDbRider(dbRider: any): Rider {
  return {
    id: dbRider.id,
    name: dbRider.name,
    email: dbRider.email,
    phone: dbRider.phone,
    vehicle: dbRider.vehicle,
    vehicleNumber: dbRider.vehicleNumber,
    status: dbRider.status,
    currentLocation:
      dbRider.currentLat != null && dbRider.currentLng != null
        ? { lat: dbRider.currentLat, lng: dbRider.currentLng }
        : undefined,
    currentOrderId: dbRider.currentOrderId ?? undefined,
    rating: dbRider.rating,
    totalDeliveries: dbRider.totalDeliveries,
    isActive: dbRider.isActive,
    createdAt: dbRider.createdAt.toISOString(),
  };
}

riderRouter.get('/', async (_req, res) => {
  try {
    const dbRiders = await prisma.rider.findMany();
    return res.json(dbRiders.map(mapDbRider));
  } catch (err) {
    console.error('Error fetching riders from DB:', err);
    return res.status(500).json({ message: 'Failed to fetch riders' });
  }
});

riderRouter.get('/:id', async (req, res) => {
  try {
    const dbRider = await prisma.rider.findUnique({ where: { id: req.params.id } });
    if (!dbRider) {
      return res.status(404).json({ message: 'Rider not found' });
    }
    return res.json(mapDbRider(dbRider));
  } catch (err) {
    console.error('Error fetching rider from DB:', err);
    return res.status(500).json({ message: 'Failed to fetch rider' });
  }
});

riderRouter.get('/:id/orders', async (req, res) => {
  try {
    const dbOrders = await prisma.order.findMany({
      where: { driverId: req.params.id },
      include: { items: true, statusHistory: true },
      orderBy: { createdAt: 'desc' },
    });

    return res.json(
      dbOrders.map((o: any) => ({
        ...o,
        createdAt: o.createdAt.toISOString(),
        updatedAt: o.updatedAt.toISOString(),
        statusHistory: (o.statusHistory ?? []).map((s: any) => ({
          ...s,
          timestamp: s.timestamp.toISOString(),
        })),
      })),
    );
  } catch (err) {
    console.error('Error fetching rider orders from DB:', err);
    return res.status(500).json({ message: 'Failed to fetch rider orders' });
  }
});

const statusSchema = z.object({
  status: z.custom<RiderStatus>((val) => ['available', 'busy', 'offline'].includes(String(val))),
});

riderRouter.patch('/:id/status', async (req, res) => {
  const parsed = statusSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ message: 'Invalid status', errors: parsed.error.flatten() });
  }

  const status = parsed.data.status as RiderStatus;

  try {
    const dbRider = await prisma.rider.update({
      where: { id: req.params.id },
      data: {
        status,
        currentOrderId: status === 'busy' ? undefined : null,
      },
    });
    return res.json(mapDbRider(dbRider));
  } catch (err: any) {
    console.error('Error updating rider status in DB:', err);
    if (err.code === 'P2025') {
      return res.status(404).json({ message: 'Rider not found' });
    }
    return res.status(500).json({ message: 'Failed to update rider status' });
  }
});

const locationSchema = z.object({
  lat: z.number(),
  lng: z.number(),
});

riderRouter.patch('/:id/location', async (req, res) => {
  const parsed = locationSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ message: 'Invalid location', errors: parsed.error.flatten() });
  }

  const { lat, lng } = parsed.data;

  try {
    const dbRider = await prisma.rider.update({
      where: { id: req.params.id },
      data: {
        currentLat: lat,
        currentLng: lng,
      },
    });
    return res.json(mapDbRider(dbRider));
  } catch (err: any) {
    console.error('Error updating rider location in DB:', err);
    if (err.code === 'P2025') {
      return res.status(404).json({ message: 'Rider not found' });
    }
    return res.status(500).json({ message: 'Failed to update rider location' });
  }
});
