"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.restaurantRouter = void 0;
const express_1 = require("express");
const zod_1 = require("zod");
const prisma_1 = require("../../utils/prisma");
const upload_1 = require("../../utils/upload");
exports.restaurantRouter = (0, express_1.Router)();
// Helper to parse JSON fields from multipart form data
function parseFormField(field) {
    if (!field)
        return undefined;
    try {
        return JSON.parse(field);
    }
    catch {
        return field;
    }
}
// Schemas
const restaurantCreateSchema = zod_1.z.object({
    name: zod_1.z.string().min(1),
    description: zod_1.z.string().optional(),
    cuisine: zod_1.z.string().min(1),
    deliveryFee: zod_1.z.number().nonnegative(),
    deliveryTimeMinutesMin: zod_1.z.number().int().positive(),
    deliveryTimeMinutesMax: zod_1.z.number().int().positive(),
    currencyCode: zod_1.z.string().min(3).max(4).optional(),
    currencySymbol: zod_1.z.string().max(3).optional(),
    address: zod_1.z.string().min(1),
    imageUrl: zod_1.z.string().url().optional(),
    phone: zod_1.z.string().optional(),
    hours: zod_1.z.string().optional(),
    minOrder: zod_1.z.number().nonnegative().optional(),
    features: zod_1.z.union([zod_1.z.array(zod_1.z.string()), zod_1.z.string()]).optional().transform(val => {
        if (typeof val === 'string') {
            try {
                return JSON.parse(val);
            }
            catch {
                return [val];
            }
        }
        return val;
    }),
    isPromoted: zod_1.z.union([zod_1.z.boolean(), zod_1.z.string()]).optional().transform(val => {
        if (typeof val === 'string') {
            return val === 'true' || val === '1';
        }
        return val;
    }),
    discount: zod_1.z.string().optional(),
});
// List restaurants (DB only)
exports.restaurantRouter.get('/', async (_req, res) => {
    try {
        const dbRestaurants = await prisma_1.prisma.restaurant.findMany();
        return res.json(dbRestaurants);
    }
    catch (err) {
        console.error('Error fetching restaurants from DB:', err);
        return res.status(500).json({ message: 'Failed to fetch restaurants' });
    }
});
// Get single restaurant (DB only)
exports.restaurantRouter.get('/:id', async (req, res) => {
    try {
        const restaurant = await prisma_1.prisma.restaurant.findUnique({
            where: { id: req.params.id },
        });
        if (!restaurant) {
            return res.status(404).json({ message: 'Restaurant not found' });
        }
        return res.json(restaurant);
    }
    catch (err) {
        console.error('Error fetching restaurant from DB:', err);
        return res.status(500).json({ message: 'Failed to fetch restaurant' });
    }
});
// Create restaurant (for admin/internal tools)
// Supports both JSON and multipart/form-data (with file upload)
exports.restaurantRouter.post('/', upload_1.upload.single('image'), async (req, res) => {
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
            imageUrl = (0, upload_1.getFileUrl)(req.file.filename);
        }
        else if (!imageUrl) {
            imageUrl = 'https://via.placeholder.com/400x200';
        }
        const created = await prisma_1.prisma.restaurant.create({
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
                features: data.features ?? [],
                isOpen: true,
                isPromoted: data.isPromoted ?? false,
                discount: data.discount ?? null,
            },
        });
        return res.status(201).json(created);
    }
    catch (error) {
        console.error('Error creating restaurant:', error);
        res.status(500).json({ message: error.message || 'Failed to create restaurant' });
    }
});
// Update restaurant (supports file upload)
exports.restaurantRouter.put('/:id', upload_1.upload.single('image'), async (req, res) => {
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
        const existing = await prisma_1.prisma.restaurant.findUnique({ where: { id: req.params.id } });
        if (!existing) {
            return res.status(404).json({ message: 'Restaurant not found' });
        }
        // Handle uploaded file
        let imageUrl = data.imageUrl || existing.imageUrl;
        if (req.file) {
            imageUrl = (0, upload_1.getFileUrl)(req.file.filename);
        }
        const saved = await prisma_1.prisma.restaurant.update({
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
                features: data.features ?? existing.features ?? [],
                isPromoted: data.isPromoted ?? existing.isPromoted,
                discount: data.discount ?? existing.discount,
            },
        });
        return res.json(saved);
    }
    catch (error) {
        console.error('Error updating restaurant:', error);
        res.status(500).json({ message: error.message || 'Failed to update restaurant' });
    }
});
// Delete restaurant
exports.restaurantRouter.delete('/:id', async (req, res) => {
    try {
        await prisma_1.prisma.restaurant.delete({
            where: { id: req.params.id },
        });
        return res.status(204).send();
    }
    catch (err) {
        console.error('Error deleting restaurant from DB:', err);
        if (err.code === 'P2025') {
            return res.status(404).json({ message: 'Restaurant not found' });
        }
        return res.status(500).json({ message: 'Failed to delete restaurant' });
    }
});
