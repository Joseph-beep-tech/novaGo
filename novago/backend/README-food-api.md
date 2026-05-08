## NovaGo Food Delivery API (Backend)

Base URL (dev): `http://localhost:4000`

### Auth

- **POST `/api/auth/register`**
  - Body: `{ "email", "name", "password", "role": "customer|restaurant|admin" }`
  - Returns: `{ user, token }`

- **POST `/api/auth/login`**
  - Body: `{ "email", "password" }`
  - Returns: `{ user, token }`

- **GET `/api/auth/me`**
  - Header: `Authorization: Bearer <token>`
  - Returns: decoded JWT payload.

### Restaurants

- **GET `/api/restaurants`** – list restaurants  
- **GET `/api/restaurants/:id`** – restaurant details  
- **POST `/api/restaurants`** – create restaurant (admin)  
- **PUT `/api/restaurants/:id`** – update restaurant  
- **DELETE `/api/restaurants/:id`** – delete restaurant  

#### Create/Update Restaurant

**Option 1: JSON Body** (without file upload)

```json
{
  "name": "Pizza Palace",
  "description": "Authentic Italian pizza",
  "cuisine": "Italian",
  "deliveryFee": 2.99,
  "deliveryTimeMinutesMin": 25,
  "deliveryTimeMinutesMax": 35,
  "address": "123 Main St, New York, NY 10001",
  "imageUrl": "https://example.com/image.jpg",
  "phone": "+1 (555) 123-4567",
  "hours": "Mon-Sun: 11:00 AM - 11:00 PM",
  "minOrder": 15.00,
  "features": ["Free Delivery", "Vegetarian Options"],
  "isPromoted": false,
  "discount": "20% OFF"
}
```

**Option 2: Multipart Form-Data** (with file upload)

- Content-Type: `multipart/form-data`
- Form fields:
  - `name`: string
  - `description`: string (optional)
  - `cuisine`: string
  - `deliveryFee`: number
  - `deliveryTimeMinutesMin`: number
  - `deliveryTimeMinutesMax`: number
  - `address`: string
  - `image`: file (image or video - optional)
  - `phone`: string (optional)
  - `hours`: string (optional)
  - `minOrder`: number (optional)
  - `features`: JSON array string (optional)
  - `isPromoted`: boolean string (optional)
  - `discount`: string (optional)

**Example (using the request body you specified):**

```json
{
  "name": "pale fruits",
  "description": "fresh fruits",
  "cuisine": "Fast Food",
  "deliveryFee": 2.99,
  "deliveryTimeMinutesMin": 15,
  "deliveryTimeMinutesMax": 25,
  "address": "456 Food Street"
}
```

You can add an `image` file field to upload an image/video. The uploaded file will be saved to `/uploads/restaurants/` and its URL will be automatically set as the `imageUrl`.

**Supported file types:**
- Images: JPEG, JPG, PNG, GIF, WEBP
- Videos: MP4, MPEG, QuickTime, AVI, WEBM
- Max file size: 50MB

### Menus

- **GET `/api/menus/restaurant/:restaurantId`** – list menu items for restaurant  
- **GET `/api/menus/:id`** – single menu item  
- **POST `/api/menus`** – create menu item  
- **PUT `/api/menus/:id`** – update menu item  
- **DELETE `/api/menus/:id`** – delete menu item  

Menu payload:

```json
{
  "restaurantId": "pizza-palace",
  "name": "Margherita Pizza",
  "description": "Fresh mozzarella, tomato sauce, basil",
  "price": 12.99,
  "imageUrl": "https://...",
  "category": "Popular"
}
```

### Orders & Tracking

- **POST `/api/orders`** – create order (checkout)

```json
{
  "restaurantId": "pizza-palace",
  "customerName": "John Doe",
  "deliveryAddress": "123 Main St, NY",
  "items": [{ "menuItemId": "margherita-pizza", "quantity": 1 }]
}
```

Response includes: `id`, `subtotal`, `deliveryFee`, `tax`, `total`, `status`.

- **GET `/api/orders`** – list all orders  
- **GET `/api/orders/:id`** – order details  

- **PATCH `/api/orders/:id/status`**

```json
{ "status": "pending|confirmed|preparing|ready|picked_up|on_the_way|delivered|cancelled" }
```

- **GET `/api/orders/:id/tracking`** – tracking stub for journey map

Returns:

```json
{
  "orderId": "ORD-001",
  "status": "on_the_way",
  "estimatedDelivery": "15-25 min",
  "driver": {
    "id": "driver-001",
    "name": "Mike Johnson",
    "vehicle": "Honda Civic - ABC123",
    "location": { "lat": 40.7128, "lng": -74.006 }
  }
}
```

All data is currently in-memory; swap the `*.data.ts` modules for real database access when ready.


