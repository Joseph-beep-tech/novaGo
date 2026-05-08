# API Integration Guide

## ✅ Completed Integrations

1. **API Client Setup** - `lib/core/api/api_client.dart`
   - Dio configured with base URL (localhost:4000 for dev)
   - Auth token interceptor
   - Error handling

2. **Data Models** - `lib/core/models/`
   - `restaurant.dart` - Restaurant model
   - `menu_item.dart` - MenuItem model  
   - `order.dart` - Order, OrderTracking, Driver models

3. **API Services** - `lib/core/api/services/`
   - `restaurant_service.dart` - Restaurant CRUD
   - `menu_service.dart` - Menu CRUD
   - `order_service.dart` - Order creation, tracking
   - `auth_service.dart` - Register, login, auth state

4. **Restaurant List Page** - ✅ Fully integrated
   - Fetches restaurants from API
   - Loading/error states
   - Refresh on pull-down
   - Filtering/sorting works

## 📝 Remaining Integrations

### 1. Restaurant Detail Page (`restaurant_detail_page.dart`)
- Load menu items using `MenuService.getRestaurantMenu(restaurantId)`
- Display menu items from API instead of hardcoded data

### 2. Cart Page (`cart_page.dart`)  
- Currently uses local cart state
- Can optionally save/load cart from API (or keep local for now)
- "Proceed to Checkout" button already navigates correctly

### 3. Checkout Page (`checkout_page.dart`)
- Create order using `OrderService.createOrder()`
- Pass cart items as `items: [{ menuItemId: '...', quantity: 2 }]`
- On success, navigate to order tracking page

### 4. Order Tracking Page (`order_tracking_page.dart`)
- Load tracking data using `OrderService.getOrderTracking(orderId)`
- Display real-time order status and driver location

## 🔧 Usage Examples

### Loading Restaurants
```dart
final restaurantService = RestaurantService();
final restaurants = await restaurantService.getRestaurants();
```

### Loading Menu
```dart
final menuService = MenuService();
final menuItems = await menuService.getRestaurantMenu('pizza-palace');
```

### Creating Order
```dart
final orderService = OrderService();
final order = await orderService.createOrder(
  restaurantId: 'pizza-palace',
  customerName: 'John Doe',
  deliveryAddress: '123 Main St',
  items: [
    {'menuItemId': 'margherita-pizza', 'quantity': 2},
  ],
);
```

### Getting Order Tracking
```dart
final tracking = await orderService.getOrderTracking('ORD-001');
// Use tracking.status, tracking.driver, tracking.steps
```

## 🚀 Next Steps

1. Start backend: `cd backend && npm run dev`
2. Test in Postman to verify endpoints work
3. Run Flutter app - restaurant list should now load from API
4. Complete remaining page integrations as needed

