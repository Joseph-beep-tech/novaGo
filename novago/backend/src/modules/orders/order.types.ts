export type OrderStatus =
  | 'pending'
  | 'confirmed'
  | 'preparing'
  | 'ready'
  | 'assigned'
  | 'picked_up'
  | 'on_the_way'
  | 'delivered'
  | 'cancelled';

export interface OrderItemInput {
  menuItemId: string;
  quantity: number;
}

export interface OrderLocation {
  lat: number;
  lng: number;
  address?: string;
}

export interface TrackingStep {
  id: string;
  status: OrderStatus;
  message: string;
  timestamp: string;
}

export interface Order {
  id: string;
  restaurantId: string;
  restaurantLocation?: OrderLocation;
  items: {
    menuItemId: string;
    name: string;
    price: number;
    quantity: number;
  }[];
  subtotal: number;
  deliveryFee: number;
  tax: number;
  total: number;
  status: OrderStatus;
  customerName: string;
  customerPhone?: string;
  deliveryAddress: string;
  deliveryLocation?: OrderLocation;
  driverId?: string;
  etaMinutes?: number;
  statusHistory: TrackingStep[];
  createdAt: string;
  updatedAt: string;
}

export interface OrderTrackingSnapshot {
  orderId: string;
  driverId?: string;
  driverLocation?: OrderLocation;
  customerLocation?: OrderLocation;
  restaurantLocation?: OrderLocation;
  status: OrderStatus;
  etaMinutes?: number;
  steps: TrackingStep[];
}


