export type RiderStatus = 'available' | 'busy' | 'offline';

export interface Rider {
  id: string;
  name: string;
  email: string;
  phone: string;
  vehicle: string;
  vehicleNumber: string;
  status: RiderStatus;
  currentLocation?: {
    lat: number;
    lng: number;
  };
  currentOrderId?: string;
  rating: number;
  totalDeliveries: number;
  isActive: boolean;
  createdAt: string;
}

