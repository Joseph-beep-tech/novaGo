"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.menuRouter = void 0;
const express_1 = require("express");
const zod_1 = require("zod");
const prisma_1 = require("../../utils/prisma");
const menu_upload_1 = require("../../utils/menu-upload");
exports.menuRouter = (0, express_1.Router)();
// Get menu for a restaurant (DB only)
exports.menuRouter.get('/restaurant/:restaurantId', async (req, res) => {
    try {
        const items = await prisma_1.prisma.menuItem.findMany({
            where: { restaurantId: req.params.restaurantId },
        });
        return res.json(items);
    }
    catch (err) {
        console.error('Error fetching menu from DB:', err);
        return res.status(500).json({ message: 'Failed to fetch menu' });
    }
});
// Get single menu item (DB only)
exports.menuRouter.get('/:id', async (req, res) => {
    try {
        const item = await prisma_1.prisma.menuItem.findUnique({
            where: { id: req.params.id },
        });
        if (!item) {
            return res.status(404).json({ message: 'Menu item not found' });
        }
        return res.json(item);
    }
    catch (err) {
        console.error('Error fetching menu item from DB:', err);
        return res.status(500).json({ message: 'Failed to fetch menu item' });
    }
});
const menuCreateSchema = zod_1.z.object({
    restaurantId: zod_1.z.string().min(1),
    name: zod_1.z.string().min(1),
    description: zod_1.z.string().optional(),
    price: zod_1.z.number().positive(),
    imageUrl: zod_1.z.string().url().optional(),
    category: zod_1.z.string().min(1),
    isVegetarian: zod_1.z.boolean().optional(),
    rating: zod_1.z.number().nonnegative().optional(),
    prepTimeMinutes: zod_1.z.number().int().positive().optional(),
});
// Helper to parse form fields
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
// Create a menu item (supports file upload, DB only)
exports.menuRouter.post('/', menu_upload_1.menuUpload.single('image'), async (req, res) => {
    try {
        // Handle both JSON and form-data
        let body = req.body;
        // If it's form-data, parse string fields to proper types
        if (req.headers['content-type']?.includes('multipart/form-data')) {
            body = {
                restaurantId: body.restaurantId,
                name: body.name,
                description: body.description,
                price: parseFloat(body.price) || 0,
                category: body.category,
                isVegetarian: body.isVegetarian === 'true' || body.isVegetarian === true,
                rating: body.rating ? parseFloat(body.rating) : undefined,
                prepTimeMinutes: body.prepTimeMinutes ? parseInt(body.prepTimeMinutes) : undefined,
            };
        }
        const parsed = menuCreateSchema.safeParse(body);
        if (!parsed.success) {
            return res.status(400).json({ message: 'Invalid payload', errors: parsed.error.flatten() });
        }
        const data = parsed.data;
        const id = `${data.restaurantId}-${data.name.toLowerCase().replace(/\s+/g, '-')}`;
        // Handle uploaded file
        let imageUrl = data.imageUrl || '';
        if (req.file) {
            imageUrl = (0, menu_upload_1.getMenuFileUrl)(req.file.filename);
        }
        if (!imageUrl) {
            imageUrl = 'https://via.placeholder.com/400x300';
        }
        const created = await prisma_1.prisma.menuItem.create({
            data: {
                id,
                restaurantId: data.restaurantId,
                name: data.name,
                description: data.description ?? null,
                price: data.price,
                imageUrl,
                category: data.category,
                isAvailable: true,
                isVegetarian: data.isVegetarian ?? null,
                rating: data.rating ?? null,
                prepTimeMinutes: data.prepTimeMinutes ?? null,
            },
        });
        return res.status(201).json(created);
    }
    catch (error) {
        console.error('Error creating menu item:', error);
        res.status(500).json({ message: error.message || 'Failed to create menu item' });
    }
});
// Update menu item (supports file upload, DB only)
exports.menuRouter.put('/:id', menu_upload_1.menuUpload.single('image'), async (req, res) => {
    try {
        // Handle both JSON and form-data
        let body = req.body;
        if (req.headers['content-type']?.includes('multipart/form-data')) {
            body = {
                restaurantId: body.restaurantId,
                name: body.name,
                description: body.description,
                price: parseFloat(body.price) || 0,
                category: body.category,
                isVegetarian: body.isVegetarian === 'true' || body.isVegetarian === true,
                rating: body.rating ? parseFloat(body.rating) : undefined,
                prepTimeMinutes: body.prepTimeMinutes ? parseInt(body.prepTimeMinutes) : undefined,
            };
        }
        const parsed = menuCreateSchema
            .partial()
            .extend({
            price: zod_1.z.number().positive().optional(),
        })
            .safeParse(body);
        if (!parsed.success) {
            return res.status(400).json({ message: 'Invalid payload', errors: parsed.error.flatten() });
        }
        const data = parsed.data;
        const existing = await prisma_1.prisma.menuItem.findUnique({ where: { id: req.params.id } });
        if (!existing) {
            return res.status(404).json({ message: 'Menu item not found' });
        }
        // Handle uploaded file
        let imageUrl = data.imageUrl ?? existing.imageUrl;
        if (req.file) {
            imageUrl = (0, menu_upload_1.getMenuFileUrl)(req.file.filename);
        }
        const saved = await prisma_1.prisma.menuItem.update({
            where: { id: req.params.id },
            data: {
                restaurantId: data.restaurantId ?? existing.restaurantId,
                name: data.name ?? existing.name,
                description: data.description ?? existing.description,
                price: data.price ?? existing.price,
                imageUrl,
                category: data.category ?? existing.category,
                isAvailable: existing.isAvailable,
                isVegetarian: data.isVegetarian ?? existing.isVegetarian,
                rating: data.rating ?? existing.rating,
                prepTimeMinutes: data.prepTimeMinutes ?? existing.prepTimeMinutes,
            },
        });
        return res.json(saved);
    }
    catch (error) {
        console.error('Error updating menu item:', error);
        res.status(500).json({ message: error.message || 'Failed to update menu item' });
    }
});
// Delete menu item (DB only)
exports.menuRouter.delete('/:id', async (req, res) => {
    try {
        await prisma_1.prisma.menuItem.delete({
            where: { id: req.params.id },
        });
        return res.status(204).send();
    }
    catch (err) {
        console.error('Error deleting menu item from DB:', err);
        if (err.code === 'P2025') {
            return res.status(404).json({ message: 'Menu item not found' });
        }
        return res.status(500).json({ message: 'Failed to delete menu item' });
    }
});
