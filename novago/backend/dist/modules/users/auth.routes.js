"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.authRouter = void 0;
const express_1 = require("express");
const zod_1 = require("zod");
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const prisma_1 = require("../../utils/prisma");
exports.authRouter = (0, express_1.Router)();
const registerSchema = zod_1.z.object({
    email: zod_1.z.string().email(),
    name: zod_1.z.string().min(1),
    password: zod_1.z.string().min(6),
    role: zod_1.z.enum(['customer', 'restaurant', 'admin']).default('customer'),
});
const loginSchema = zod_1.z.object({
    email: zod_1.z.string().email(),
    password: zod_1.z.string().min(6),
});
function signToken(user) {
    const secret = process.env.JWT_SECRET || 'dev-secret';
    return jsonwebtoken_1.default.sign({ sub: user.id, email: user.email, role: user.role }, secret, { expiresIn: '7d' });
}
function hashPassword(password) {
    const salt = bcryptjs_1.default.genSaltSync(10);
    return bcryptjs_1.default.hashSync(password, salt);
}
function verifyPassword(password, hash) {
    return bcryptjs_1.default.compareSync(password, hash);
}
exports.authRouter.post('/register', async (req, res) => {
    const parsed = registerSchema.safeParse(req.body);
    if (!parsed.success) {
        return res.status(400).json({ message: 'Invalid payload', errors: parsed.error.flatten() });
    }
    const data = parsed.data;
    try {
        const existingDb = await prisma_1.prisma.user.findUnique({ where: { email: data.email } });
        if (existingDb) {
            return res.status(409).json({ message: 'Email already registered' });
        }
    }
    catch (err) {
        console.error('Error checking user existence in DB:', err);
        return res.status(500).json({ message: 'Failed to register user' });
    }
    const passwordHash = hashPassword(data.password);
    try {
        const created = await prisma_1.prisma.user.create({
            data: {
                id: `user-${Date.now().toString(36)}`,
                email: data.email,
                name: data.name,
                passwordHash,
                role: data.role,
            },
        });
        const safeUser = {
            id: created.id,
            email: created.email,
            name: created.name,
            passwordHash: created.passwordHash,
            role: created.role,
        };
        const token = signToken(safeUser);
        return res.status(201).json({
            user: { id: safeUser.id, email: safeUser.email, name: safeUser.name, role: safeUser.role },
            token,
        });
    }
    catch (err) {
        console.error('Error creating user in DB:', err);
        return res.status(500).json({ message: 'Failed to register user' });
    }
});
exports.authRouter.post('/login', async (req, res) => {
    const parsed = loginSchema.safeParse(req.body);
    if (!parsed.success) {
        return res.status(400).json({ message: 'Invalid payload', errors: parsed.error.flatten() });
    }
    const data = parsed.data;
    try {
        const dbUser = await prisma_1.prisma.user.findUnique({ where: { email: data.email } });
        if (!dbUser || !verifyPassword(data.password, dbUser.passwordHash)) {
            return res.status(401).json({ message: 'Invalid email or password' });
        }
        const safeUser = {
            id: dbUser.id,
            email: dbUser.email,
            name: dbUser.name,
            passwordHash: dbUser.passwordHash,
            role: dbUser.role,
        };
        const token = signToken(safeUser);
        return res.json({
            user: { id: safeUser.id, email: safeUser.email, name: safeUser.name, role: safeUser.role },
            token,
        });
    }
    catch (err) {
        console.error('Error logging in via DB:', err);
        return res.status(500).json({ message: 'Failed to login' });
    }
});
exports.authRouter.get('/me', (req, res) => {
    const auth = req.headers.authorization;
    if (!auth?.startsWith('Bearer ')) {
        return res.status(401).json({ message: 'Missing token' });
    }
    const token = auth.slice(7);
    try {
        const secret = process.env.JWT_SECRET || 'dev-secret';
        const payload = jsonwebtoken_1.default.verify(token, secret);
        res.json({ user: payload });
    }
    catch {
        res.status(401).json({ message: 'Invalid token' });
    }
});
