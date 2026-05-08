export interface MenuItem {
  id: string;
  restaurantId: string;
  name: string;
  description?: string;
  price: number;
  imageUrl: string;
  category: string;
  isAvailable: boolean;
  isVegetarian?: boolean;
  rating?: number;
  prepTimeMinutes?: number;
}


