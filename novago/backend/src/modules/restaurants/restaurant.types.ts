export interface Restaurant {
  id: string;
  name: string;
  description?: string;
  cuisine: string;
  rating: number;
  reviewCount: number;
  deliveryFee: number;
  deliveryTimeMinutesMin: number;
  deliveryTimeMinutesMax: number;
  currencyCode?: string;
  currencySymbol?: string;
  address: string;
  imageUrl: string;
  phone?: string;
  hours?: string;
  minOrder?: number;
  features?: string[];
  isOpen: boolean;
  isPromoted?: boolean;
  discount?: string;
}


