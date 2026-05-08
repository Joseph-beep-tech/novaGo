# NovaGo - The Ultimate Lifestyle Super App

NovaGo is a comprehensive Flutter-based super app that combines food delivery, ride-hailing, digital payments, and essential services into a single, intuitive platform. Built with modern Flutter architecture and inspired by Grab's design patterns.

## 🚀 Features

### Core Modules
- **🍕 Food Delivery**: Browse restaurants, order food, track delivery
- **🚗 Ride Hailing**: Book rides, track drivers, multiple vehicle types
- **💳 Digital Wallet**: NovaPay wallet with multiple payment methods
- **📦 Courier Services**: Package pickup and delivery
- **🧾 Bill Payments**: Utilities, mobile, internet payments
- **🎁 Loyalty Program**: Points, rewards, and exclusive offers

### Key Features
- **Modern UI/UX**: Material Design 3 with Grab-inspired interface
- **Real-time Tracking**: Live order and ride tracking
- **Multi-platform**: iOS, Android, and Web support
- **Offline Support**: Local storage with Hive
- **Push Notifications**: Firebase Cloud Messaging
- **Maps Integration**: Google Maps for location services
- **Social Login**: Google and Apple Sign-In
- **QR Code Support**: Payment and restaurant features

## 📱 Screenshots

The app features a modern, clean interface with:
- Grab-inspired green color scheme (#00B14F)
- Intuitive navigation with bottom tab bar
- Service grid for quick access to features
- Promotional banners and offers
- Real-time order tracking
- Comprehensive wallet management

## 🛠 Technology Stack

### Frontend
- **Framework**: Flutter 3.16+
- **Language**: Dart
- **State Management**: Provider / Riverpod
- **Navigation**: GoRouter
- **UI**: Material Design 3 + Custom Components

### Backend Integration
- **HTTP Client**: Dio
- **API**: RESTful APIs with Retrofit
- **Authentication**: JWT + OAuth 2.0
- **Real-time**: WebSockets

### Storage & Caching
- **Local Storage**: Hive
- **Preferences**: SharedPreferences
- **Caching**: Custom cache layer

### Maps & Location
- **Maps**: Google Maps Flutter Plugin
- **Location**: Geolocator
- **Geocoding**: Geocoding package

### Notifications & Analytics
- **Push Notifications**: Firebase Cloud Messaging
- **Analytics**: Firebase Analytics
- **Local Notifications**: Flutter Local Notifications

### Payments
- **Payment Gateway**: Stripe
- **QR Codes**: QR Flutter
- **Social Login**: Google Sign-In, Apple Sign-In

## 📋 Prerequisites

Before running the app, make sure you have:

1. **Flutter SDK** (3.16.0 or higher)
   ```bash
   flutter --version
   ```

2. **Dart SDK** (3.0.0 or higher)
   ```bash
   dart --version
   ```

3. **Android Studio** or **VS Code** with Flutter extensions

4. **Xcode** (for iOS development on macOS)

5. **Firebase Project** (for authentication, notifications, analytics)

6. **Google Maps API Key** (for maps and location services)

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/novago.git
cd novago
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project named "NovaGo"
3. Enable Authentication, Firestore, and Cloud Messaging

#### Configure Firebase for Flutter
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

### 4. Google Maps Setup

#### Get API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable Maps SDK for Android and iOS
4. Create API credentials

#### Configure API Key

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>GMSApiKey</key>
<string>YOUR_GOOGLE_MAPS_API_KEY</string>
```

### 5. Environment Configuration

Create a `.env` file in the root directory:
```env
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key
API_BASE_URL=https://api.novago.com
```

### 6. Run the App

#### Debug Mode
```bash
flutter run
```

#### Release Mode
```bash
flutter run --release
```

#### Specific Platform
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d web
```

## 📁 Project Structure

```
lib/
├── core/                    # Core functionality
│   ├── config/             # App configuration
│   ├── router/             # Navigation routing
│   └── services/           # Core services
├── features/               # Feature modules
│   ├── auth/              # Authentication
│   ├── food/              # Food delivery
│   ├── ride/              # Ride hailing
│   ├── wallet/            # Digital wallet
│   ├── profile/           # User profile
│   ├── home/              # Home screen
│   ├── onboarding/        # Onboarding flow
│   └── splash/            # Splash screen
├── shared/                # Shared components
│   ├── widgets/           # Reusable widgets
│   ├── models/            # Data models
│   └── utils/             # Utility functions
└── main.dart              # App entry point
```

## 🎨 Design System

### Color Palette
- **Primary**: #00B14F (Grab Green)
- **Secondary**: #FF6B35 (Orange)
- **Accent**: #4A90E2 (Blue)
- **Background**: #F5F5F5
- **Text**: #333333

### Typography
- **Font Family**: Inter
- **Headings**: Bold, 18-32px
- **Body**: Regular, 14-16px
- **Captions**: Medium, 10-12px

### Components
- **Cards**: Rounded corners (12px), subtle shadows
- **Buttons**: Primary (filled), Secondary (outlined)
- **Input Fields**: Rounded, with icons
- **Navigation**: Bottom tab bar with 5 tabs

## 🔧 Development

### Code Generation
```bash
# Generate code for models, APIs, and storage
flutter packages pub run build_runner build

# Watch for changes
flutter packages pub run build_runner watch
```

### Testing
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

### Linting
```bash
# Check code style
flutter analyze

# Fix code style issues
dart fix --apply
```

## 📦 Building for Production

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### iOS
```bash
# Build iOS app
flutter build ios --release

# Archive for App Store
flutter build ipa --release
```

### Web
```bash
# Build web app
flutter build web --release
```

## 🚀 Deployment

### Android (Google Play Store)
1. Build app bundle: `flutter build appbundle --release`
2. Upload to Google Play Console
3. Configure store listing and pricing
4. Submit for review

### iOS (App Store)
1. Build iOS app: `flutter build ios --release`
2. Archive in Xcode
3. Upload to App Store Connect
4. Configure app information and pricing
5. Submit for review

### Web (Firebase Hosting)
```bash
# Build web app
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

## 🔐 Security

### API Security
- JWT token authentication
- API rate limiting
- Input validation and sanitization
- HTTPS encryption

### Data Protection
- Local data encryption with Hive
- Secure storage of sensitive information
- GDPR compliance
- User privacy controls

### Payment Security
- PCI DSS compliant payment processing
- Tokenized payment methods
- Secure wallet implementation

## 📊 Analytics & Monitoring

### Firebase Analytics
- User engagement tracking
- Feature usage analytics
- Conversion funnel analysis
- Custom event tracking

### Crashlytics
- Crash reporting
- Performance monitoring
- User session tracking

### Custom Analytics
- Order completion rates
- User retention metrics
- Revenue tracking
- Driver performance metrics

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Code Style
- Follow Dart/Flutter style guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Write unit tests for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Maps Documentation](https://developers.google.com/maps/documentation)

### Community
- [Flutter Community](https://flutter.dev/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- [Discord](https://discord.gg/flutter)

### Issues
If you encounter any issues, please:
1. Check existing issues in the repository
2. Create a new issue with detailed description
3. Include device information and error logs

## 🗺 Roadmap

### Phase 1: MVP (Months 1-3)
- [x] Basic app structure
- [x] Authentication system
- [x] Food delivery module
- [x] Ride hailing module
- [x] Basic wallet functionality
- [ ] Admin dashboard

### Phase 2: Enhancement (Months 4-6)
- [ ] Advanced search and filtering
- [ ] Multi-restaurant ordering
- [ ] Ride scheduling
- [ ] Enhanced wallet features
- [ ] Loyalty program basics
- [ ] Improved analytics

### Phase 3: Super App (Months 7-12)
- [ ] Courier services
- [ ] Bill payments
- [ ] Advanced loyalty program
- [ ] Social features
- [ ] Merchant tools
- [ ] Driver incentives

### Phase 4: Scale (Months 13-18)
- [ ] Financial services
- [ ] Marketplace features
- [ ] International expansion
- [ ] Advanced personalization
- [ ] Enterprise solutions

## 📞 Contact

- **Email**: support@novago.com
- **Website**: https://novago.com
- **Twitter**: @NovaGoApp
- **LinkedIn**: NovaGo

---

**NovaGo** - The Ultimate Lifestyle Super App 🚀
