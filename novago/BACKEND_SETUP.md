# Backend Setup & Connection Guide

## 🚀 Quick Start

### 1. Start the Backend Server

Open a terminal in the project root and run:

```bash
cd backend
npm install
npm run dev
```

You should see:
```
Server running on port 4000
✓ Server initialized successfully
```

### 2. Test Backend is Running

Open your browser and go to:
```
http://localhost:4000/health
```

You should see:
```json
{"status":"ok","message":"Server is running"}
```

### 3. Configure Flutter App Connection

The app needs to connect to your backend. The URL depends on where you're running the app:

#### **Android Emulator**
✅ Already configured - uses `http://10.0.2.2:4000`
- `10.0.2.2` is a special IP that points to your host machine from Android emulator

#### **iOS Simulator**
Change in `lib/core/config/app_config.dart`:
```dart
return 'http://localhost:4000'; // iOS simulator / Web
```

#### **Physical Android Device**
1. Find your computer's IP address:
   - Windows: `ipconfig` (look for IPv4 Address)
   - Mac/Linux: `ifconfig` or `ip addr`
   - Example: `192.168.1.100`

2. Update `lib/core/config/app_config.dart`:
```dart
return 'http://192.168.1.100:4000'; // Replace with your IP
```

3. Make sure your phone and computer are on the same WiFi network

## 🔧 Troubleshooting

### Connection Refused Error

**Problem**: `Connection refused` or `SocketException`

**Solutions**:
1. ✅ **Check backend is running**: Make sure `npm run dev` is running in the backend folder
2. ✅ **Check port**: Backend should be on port 4000
3. ✅ **Check URL in app**: Make sure `AppConfig.apiBaseUrl` matches your setup:
   - Android Emulator: `http://10.0.2.2:4000`
   - iOS Simulator: `http://localhost:4000`
   - Physical Device: `http://YOUR_IP:4000`
4. ✅ **Check firewall**: Windows/Mac firewall might block port 4000
   - Try disabling firewall temporarily or allow port 4000

### Backend Won't Start

**Problem**: `npm run dev` fails

**Solutions**:
1. Make sure you're in the `backend` folder
2. Run `npm install` first
3. Check Node.js version (should be 18+)
4. Check for port conflicts (something else using port 4000)

### Test API Connection

Use Postman or curl to test:

```bash
# Health check
curl http://localhost:4000/health

# Get restaurants
curl http://localhost:4000/api/restaurants

# Create an order
curl -X POST http://localhost:4000/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "restaurantId": "pizza-palace",
    "customerName": "Test User",
    "deliveryAddress": "123 Test St",
    "items": [{"menuItemId": "margherita-pizza", "quantity": 1}]
  }'
```

## 📱 Platform-Specific Notes

### Android Emulator
- ✅ Use `10.0.2.2` instead of `localhost`
- ✅ Already configured in `app_config.dart`
- ✅ Backend must be running on your computer

### iOS Simulator  
- ✅ Use `localhost` (works directly)
- ⚠️ Change `app_config.dart` if testing on iOS

### Web Browser
- ✅ Use `localhost` 
- ⚠️ Make sure CORS is enabled in backend (already configured)

### Physical Device
- ✅ Use your computer's local IP address
- ✅ Phone and computer must be on same WiFi
- ✅ Make sure firewall allows connections

## 🔍 Verify Connection

After starting backend and app:

1. **Check backend logs**: Should see incoming requests when app loads
2. **Check Flutter console**: Should see API requests (if logging is enabled)
3. **Test in app**: Restaurant list should load from API

If you see restaurants loading in the app, the connection is working! ✅

