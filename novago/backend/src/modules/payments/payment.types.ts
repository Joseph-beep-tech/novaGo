export type PaymentStatus = 'pending' | 'completed' | 'failed' | 'refunded';

export interface Payment {
  id: string;
  orderId: string;
  amount: number;
  method: 'card' | 'cash' | 'wallet' | 'online';
  status: PaymentStatus;
  transactionId?: string;
  paidAt?: string;
  createdAt: string;
  customerName: string;
  restaurantId: string;
}

