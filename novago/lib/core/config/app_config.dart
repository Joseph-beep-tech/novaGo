class AppConfig {
  static const String appName = 'NovaGo';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'The Ultimate Lifestyle Super App';
  
  // API Configuration
  static const String baseUrl = 'http://localhost:4000';
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Development/Production Toggle
  static const bool isDevelopment = true; // Set to false for production
  
  // Get the correct API base URL based on platform
  // Android Emulator: use 10.0.2.2 to access host machine
  // iOS Simulator/Web: use localhost
  // Physical Device: use your computer's IP address (e.g., http://192.168.1.100:4000)
  static String get apiBaseUrl {
    if (!isDevelopment) {
      return 'https://api.novago.com';
    }
    
    // Check if we're on Android (you'll need to import dart:io or use a package)
    // For now, use 10.0.2.2 which works for Android emulator
    // On iOS simulator or web, localhost works fine
    // Change this to your computer's IP if testing on physical device
    return 'http://10.0.2.2:4000'; // Android emulator
    // return 'http://localhost:4000'; // iOS simulator / Web
    // return 'http://192.168.1.XXX:4000'; // Physical device (replace XXX with your IP)
  }
  
  // App Colors (Grab-inspired)
  static const String primaryColor = '#00B14F';
  static const String secondaryColor = '#FF6B35';
  static const String accentColor = '#4A90E2';
  static const String backgroundColor = '#F5F5F5';
  static const String textColor = '#333333';
  
  // Map Configuration
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  static const double defaultLatitude = 1.3521; // Singapore
  static const double defaultLongitude = 103.8198;
  static const double defaultZoom = 12;
  
  // Payment Configuration
  static const String stripePublishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';
  
  // Firebase Configuration
  static const String firebaseProjectId = 'novago-app';
  
  // Feature Flags
  static const bool enableFoodDelivery = true;
  static const bool enableRideHailing = true;
  static const bool enableWallet = true;
  static const bool enableCourier = true;
  static const bool enableBillPayments = false; // Phase 2
  static const bool enableLoyaltyProgram = false; // Phase 2
  
  // App Settings
  static const int maxRetryAttempts = 3;
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
}