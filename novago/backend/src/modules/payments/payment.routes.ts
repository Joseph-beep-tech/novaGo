import { Router } from 'express';
import { Payment, PaymentStatus } from './payment.types';
import { prisma } from '../../utils/prisma';

export const paymentRouter = Router();

// Helper to map DB payment to API Payment
function mapDbPayment(dbPayment: any): Payment {
  return {
    id: dbPayment.id,
    orderId: dbPayment.orderId,
    amount: dbPayment.amount,
    method: dbPayment.method,
    status: dbPayment.status,
    transactionId: dbPayment.transactionId ?? undefined,
    paidAt: dbPayment.paidAt ? dbPayment.paidAt.toISOString() : undefined,
    createdAt: dbPayment.createdAt.toISOString(),
    customerName: dbPayment.customerName,
    restaurantId: dbPayment.restaurantId,
  };
}

// Get all payments (DB only)
paymentRouter.get('/', async (_req, res) => {
  try {
    const dbPayments = await prisma.payment.findMany({
      orderBy: { createdAt: 'desc' },
    });
    return res.json(dbPayments.map(mapDbPayment));
  } catch (err) {
    console.error('Error fetching payments from DB:', err);
    return res.status(500).json({ message: 'Failed to fetch payments' });
  }
});

// Get payments by restaurant (DB only)
paymentRouter.get('/restaurant/:restaurantId', async (req, res) => {
  try {
    const dbPayments = await prisma.payment.findMany({
      where: { restaurantId: req.params.restaurantId },
      orderBy: { createdAt: 'desc' },
    });
    return res.json(dbPayments.map(mapDbPayment));
  } catch (err) {
    console.error('Error fetching restaurant payments from DB:', err);
    return res.status(500).json({ message: 'Failed to fetch restaurant payments' });
  }
});

// Get payment by order ID (DB only)
paymentRouter.get('/order/:orderId', async (req, res) => {
  try {
    const dbPayment = await prisma.payment.findUnique({
      where: { orderId: req.params.orderId },
    });
    if (!dbPayment) {
      return res.status(404).json({ message: 'Payment not found' });
    }
    return res.json(mapDbPayment(dbPayment));
  } catch (err) {
    console.error('Error fetching payment by order from DB:', err);
    return res.status(500).json({ message: 'Failed to fetch payment' });
  }
});

// Get payment by ID (DB only)
paymentRouter.get('/:id', async (req, res) => {
  try {
    const dbPayment = await prisma.payment.findUnique({
      where: { id: req.params.id },
    });
    if (!dbPayment) {
      return res.status(404).json({ message: 'Payment not found' });
    }
    return res.json(mapDbPayment(dbPayment));
  } catch (err) {
    console.error('Error fetching payment from DB:', err);
    return res.status(500).json({ message: 'Failed to fetch payment' });
  }
});

// Update payment status (DB only)
paymentRouter.patch('/:id/status', async (req, res) => {
  const { status } = req.body;
  if (!['pending', 'completed', 'failed', 'refunded'].includes(status)) {
    return res.status(400).json({ message: 'Invalid payment status' });
  }

  const nowIso = new Date().toISOString();

  try {
    const updated = await prisma.payment.update({
      where: { id: req.params.id },
      data: {
        status: status as PaymentStatus,
        paidAt: status === 'completed' ? new Date(nowIso) : null,
      },
    });
    return res.json(mapDbPayment(updated));
  } catch (err: any) {
    console.error('Error updating payment status in DB:', err);
    if (err.code === 'P2025') {
      return res.status(404).json({ message: 'Payment not found' });
    }
    return res.status(500).json({ message: 'Failed to update payment status' });
  }
});

// Auto-create payment when order is created (simulate, DB only)
export async function createPaymentForOrder(
  orderId: string,
  orderTotal: number,
  customerName: string,
  restaurantId: string,
) {
  const createdAt = new Date();

  let payment: Payment;

  try {
    const dbPayment = await prisma.payment.create({
      data: {
        id: `PAY-${Date.now()}`,
        orderId,
        amount: orderTotal,
        method: 'card',
        status: 'pending',
        createdAt,
        customerName,
        restaurantId,
      },
    });

    payment = mapDbPayment(dbPayment);

    // Simulate payment completion after 2 seconds (non-blocking)
    setTimeout(async () => {
      const paidAt = new Date();
      try {
        const updated = await prisma.payment.update({
          where: { id: dbPayment.id },
          data: {
            status: 'completed',
            paidAt,
            transactionId: `TXN-${Date.now()}`,
          },
        });
        // Update local copy for any logs/inspection
        payment = mapDbPayment(updated);
      } catch (err) {
        console.error('Error marking payment as completed in DB:', err);
      }
    }, 2000);
  } catch (err) {
    console.error('Error creating payment in DB:', err);
    throw err;
  }

  return payment;
}

