import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../../utils/prisma';
import { upload, getFileUrl } from '../../utils/upload';

export const restaurantRouter = Router();

// Helper to parse JSON fields from multipart form data
function parseFormField(field: string | undefined): any {
  if (!field) return undefined;
  try {
    return JSON.parse(field);
  } catch {
    return field;
  }
}

// Schemas
const restaurantCreateSchema = z.object({
  name: z.string().min(1),
  description: z.string().optional(),
  cuisine: z.string().min(1),
  deliveryFee: z.number().nonnegative(),
  deliveryTimeMinutesMin: z.number().int().positive(),
  deliveryTimeMinutesMax: z.number().int().positive(),
  currencyCode: z.string().min(3).max(4).optional(),
  currencySymbol: z.string().max(3).optional(),
  address: z.string().min(1),
  imageUrl: z.string().url().optional(),
  phone: z.string().optional(),
  hours: z.string().optional(),
  minOrder: z.number().nonnegative().optional(),
  features: z.union([z.array(z.string()), z.string()]).optional().transform(val => {
    if (typeof val === 'string') {
      try {
        return JSON.parse(val);
      } catch {
        return [val];
      }
    }
    return val;
  }),
  isPromoted: z.union([z.boolean(), z.string()]).optional().transform(val => {
    if (typeof val === 'string') {
      return val === 'true' || val === '1';
    }
    return val;
  }),
  discount: z.string().optional(),
});

// List restaurants (DB only)
restaurantRouter.get('/', async (_req, res) => {
  try {
    const dbRestaurants = await prisma.restaurant.findMany();
    return res.json(dbRestaurants);
  } catch (err) {
    console.error('Error fetching restaurants from DB:', err);
    return res.status(500).json({ message: 'Failed to fetch restaurants' });
  }
});

// Get single restaurant (DB only)
restaurantRouter.get('/:id', async (req, res) => {
  try {
    const restaurant = await prisma.restaurant.findUnique({
      where: { id: req.params.id },
    });
    if (!restaurant) {
      return res.status(404).json({ message: 'Restaurant not found' });
    }
    return res.json(restaurant);
  } catch (err) {
    console.error('Error fetching restaurant from DB:', err);
    return res.status(500).json({ message: 'Failed to fetch restaurant' });
  }
});

// Create restaurant (for admin/internal tools)
// Supports both JSON and multipart/form-data (with file upload)
restaurantRouter.post('/', upload.single('image'), async (req, res) => {
  try {
    // Handle both JSON and form-data
    let body = req.body;
    
    // If it's form-data, parse string fields to proper types
    if (req.headers['content-type']?.includes('multipart/form-data')) {
      body = {
        name: body.name,
        description: body.description,
        cuisine: body.cuisine,
        deliveryFee: parseFloat(body.deliveryFee) || 0,
        deliveryTimeMinutesMin: parseInt(body.deliveryTimeMinutesMin) || 15,
        deliveryTimeMinutesMax: parseInt(body.deliveryTimeMinutesMax) || 25,
        currencyCode: body.currencyCode,
        currencySymbol: body.currencySymbol,
        address: body.address,
        phone: body.phone,
        hours: body.hours,
        minOrder: body.minOrder ? parseFloat(body.minOrder) : undefined,
        features: parseFormField(body.features),
        isPromoted: body.isPromoted === 'true' || body.isPromoted === true,
        discount: body.discount,
      };
    }

    const parsed = restaurantCreateSchema.safeParse(body);
    if (!parsed.success) {
      return res.status(400).json({ message: 'Invalid payload', errors: parsed.error.flatten() });
    }

    const data = parsed.data;
    const id = data.name.toLowerCase().replace(/\s+/g, '-');

    // Handle uploaded file
    let imageUrl = data.imageUrl;
    if (req.file) {
      imageUrl = getFileUrl(req.file.filename);
    } else if (!imageUrl) {
      imageUrl = 'https://via.placeholder.com/400x200';
    }

    const created = await prisma.restaurant.create({
      data: {
        id,
        name: data.name,
        description: data.description ?? null,
        cuisine: data.cuisine,
        rating: 0,
        reviewCount: 0,
        deliveryFee: data.deliveryFee,
        deliveryTimeMinutesMin: data.deliveryTimeMinutesMin,
        deliveryTimeMinutesMax: data.deliveryTimeMinutesMax,
        currencyCode: data.currencyCode || 'KES',
        currencySymbol: data.currencySymbol || 'KSh',
        address: data.address,
        imageUrl,
        phone: data.phone ?? null,
        hours: data.hours ?? null,
        minOrder: data.minOrder ?? null,
        features: (data.features as string[] | undefined) ?? [],
        isOpen: true,
        isPromoted: data.isPromoted ?? false,
        discount: data.discount ?? null,
      },
    });

    return res.status(201).json(created);
  } catch (error: any) {
    console.error('Error creating restaurant:', error);
    res.status(500).json({ message: error.message || 'Failed to create restaurant' });
  }
});

// Update restaurant (supports file upload)
restaurantRouter.put('/:id', upload.single('image'), async (req, res) => {
  try {
    // Handle both JSON and form-data
    let body = req.body;
    
    // If it's form-data, parse string fields to proper types
    if (req.headers['content-type']?.includes('multipart/form-data')) {
      body = {
        name: body.name,
        description: body.description,
        cuisine: body.cuisine,
        deliveryFee: parseFloat(body.deliveryFee) || 0,
        deliveryTimeMinutesMin: parseInt(body.deliveryTimeMinutesMin) || 15,
        deliveryTimeMinutesMax: parseInt(body.deliveryTimeMinutesMax) || 25,
        currencyCode: body.currencyCode,
        currencySymbol: body.currencySymbol,
        address: body.address,
        phone: body.phone,
        hours: body.hours,
        minOrder: body.minOrder ? parseFloat(body.minOrder) : undefined,
        features: parseFormField(body.features),
        isPromoted: body.isPromoted === 'true' || body.isPromoted === true,
        discount: body.discount,
      };
    }

    const parsed = restaurantCreateSchema.safeParse(body);
    if (!parsed.success) {
      return res.status(400).json({ message: 'Invalid payload', errors: parsed.error.flatten() });
    }

    const data = parsed.data;

    // First fetch existing restaurant
    const existing = await prisma.restaurant.findUnique({ where: { id: req.params.id } });
    if (!existing) {
      return res.status(404).json({ message: 'Restaurant not found' });
    }

    // Handle uploaded file
    let imageUrl = data.imageUrl || existing.imageUrl;
    if (req.file) {
      imageUrl = getFileUrl(req.file.filename);
    }
    
    const saved = await prisma.restaurant.update({
      where: { id: req.params.id },
      data: {
        name: data.name,
        description: data.description ?? null,
        cuisine: data.cuisine,
        deliveryFee: data.deliveryFee,
        deliveryTimeMinutesMin: data.deliveryTimeMinutesMin,
        deliveryTimeMinutesMax: data.deliveryTimeMinutesMax,
        currencyCode: data.currencyCode || existing.currencyCode || 'KES',
        currencySymbol: data.currencySymbol || existing.currencySymbol || 'KSh',
        address: data.address,
        imageUrl,
        phone: data.phone ?? existing.phone,
        hours: data.hours ?? existing.hours,
        minOrder: data.minOrder ?? existing.minOrder,
        features: (data.features as string[] | undefined) ?? existing.features ?? [],
        isPromoted: data.isPromoted ?? existing.isPromoted,
        discount: data.discount ?? existing.discount,
      },
    });

    return res.json(saved);
  } catch (error: any) {
    console.error('Error updating restaurant:', error);
    res.status(500).json({ message: error.message || 'Failed to update restaurant' });
  }
});

// Delete restaurant
restaurantRouter.delete('/:id', async (req, res) => {
  try {
    await prisma.restaurant.delete({
      where: { id: req.params.id },
    });
    return res.status(204).send();
  } catch (err: any) {
    console.error('Error deleting restaurant from DB:', err);
    if (err.code === 'P2025') {
      return res.status(404).json({ message: 'Restaurant not found' });
    }
    return res.status(500).json({ message: 'Failed to delete restaurant' });
  }
});



