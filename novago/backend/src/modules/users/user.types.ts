export interface User {
  id: string;
  email: string;
  name: string;
  passwordHash: string; // TODO: replace with real hashing in production
  role: 'customer' | 'restaurant' | 'admin';
}


