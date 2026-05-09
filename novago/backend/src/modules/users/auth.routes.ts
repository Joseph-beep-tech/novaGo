import { Router } from 'express';
import { z } from 'zod';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import { User } from './user.types';
import { prisma } from '../../utils/prisma';

export const authRouter = Router();

const registerSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1),
  password: z.string().min(6),
  role: z.enum(['customer', 'restaurant', 'admin']).default('customer'),
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
});

function signToken(user: User) {
  const secret = process.env.JWT_SECRET || 'dev-secret';
  return jwt.sign(
    { sub: user.id, email: user.email, role: user.role },
    secret,
    { expiresIn: '7d' },
  );
}

function hashPassword(password: string): string {
  const salt = bcrypt.genSaltSync(10);
  return bcrypt.hashSync(password, salt);
}

function verifyPassword(password: string, hash: string): boolean {
  return bcrypt.compareSync(password, hash);
}

authRouter.post('/register', async (req, res) => {
  const parsed = registerSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ message: 'Invalid payload', errors: parsed.error.flatten() });
  }

  const data = parsed.data;

  try {
    const existingDb = await prisma.user.findUnique({ where: { email: data.email } });
    if (existingDb) {
      return res.status(409).json({ message: 'Email already registered' });
    }
  } catch (err) {
    console.error('Error checking user existence in DB:', err);
    return res.status(500).json({ message: 'Failed to register user' });
  }

  const passwordHash = hashPassword(data.password);

  try {
    const created = await prisma.user.create({
      data: {
        id: `user-${Date.now().toString(36)}`,
        email: data.email,
        name: data.name,
        passwordHash,
        role: data.role,
      },
    });

    const safeUser: User = {
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
  } catch (err) {
    console.error('Error creating user in DB:', err);
    return res.status(500).json({ message: 'Failed to register user' });
  }
});

authRouter.post('/login', async (req, res) => {
  const parsed = loginSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ message: 'Invalid payload', errors: parsed.error.flatten() });
  }

  const data = parsed.data;

  try {
    const dbUser = await prisma.user.findUnique({ where: { email: data.email } });
    if (!dbUser || !verifyPassword(data.password, dbUser.passwordHash)) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    const safeUser: User = {
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
  } catch (err) {
    console.error('Error logging in via DB:', err);
    return res.status(500).json({ message: 'Failed to login' });
  }
});

authRouter.get('/me', (req, res) => {
  const auth = req.headers.authorization;
  if (!auth?.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Missing token' });
  }
  const token = auth.slice(7);
  try {
    const secret = process.env.JWT_SECRET || 'dev-secret';
    const payload = jwt.verify(token, secret);
    res.json({ user: payload });
  } catch {
    res.status(401).json({ message: 'Invalid token' });
  }
});

// Seed demo users (development only)
authRouter.post('/init', async (req, res) => {
  try {
    const demoUsers = [
      {
        email: 'admin@novago.com',
        name: 'Admin User',
        password: 'admin123',
        role: 'admin' as const,
      },
      {
        email: 'restaurant@novago.com',
        name: 'Restaurant Owner',
        password: 'restaurant123',
        role: 'restaurant' as const,
      },
      {
        email: 'customer@novago.com',
        name: 'Test Customer',
        password: 'customer123',
        role: 'customer' as const,
      },
    ];

    const results = [];
    for (const user of demoUsers) {
      // Check if user exists
      const existingUser = await prisma.user.findUnique({ where: { email: user.email } });
      if (existingUser) {
        results.push({ email: user.email, status: 'already_exists' });
        continue;
      }

      const passwordHash = hashPassword(user.password);
      const createdUser = await prisma.user.create({
        data: {
          id: `user-${Date.now().toString(36)}-${Math.random().toString(36).substr(2, 9)}`,
          email: user.email,
          name: user.name,
          passwordHash,
          role: user.role,
        },
      });

      results.push({
        email: createdUser.email,
        status: 'created',
        credentials: { email: user.email, password: user.password },
      });
    }

    res.json({
      message: 'Demo users initialized',
      results,
      credentials: {
        admin: { email: 'admin@novago.com', password: 'admin123' },
        restaurant: { email: 'restaurant@novago.com', password: 'restaurant123' },
        customer: { email: 'customer@novago.com', password: 'customer123' },
      },
    });
  } catch (err) {
    console.error('Error initializing demo users:', err);
    res.status(500).json({ message: 'Failed to initialize demo users', error: err });
  }
});


