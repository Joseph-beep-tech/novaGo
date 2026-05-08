# NovaGo Flutter App Setup Guide

## Prerequisites

### 1. Install Flutter SDK

#### Windows:
1. Download Flutter SDK from [https://flutter.dev/docs/get-started/install/windows](https://flutter.dev/docs/get-started/install/windows)
2. Extract the zip file to `C:\flutter`
3. Add `C:\flutter\bin` to your system PATH
4. Open Command Prompt or PowerShell and run:
   ```bash
   flutter doctor
   ```

#### macOS:
1. Download Flutter SDK from [https://flutter.dev/docs/get-started/install/macos](https://flutter.dev/docs/get-started/install/macos)
2. Extract the zip file to your desired location
3. Add Flutter to your PATH in `~/.zshrc` or `~/.bash_profile`:
   ```bash
   export PATH="$PATH:[PATH_TO_FLUTTER_GIT_DIRECTORY]/flutter/bin"
   ```
4. Run:
   ```bash
   flutter doctor
   ```

#### Linux:
1. Download Flutter SDK from [https://flutter.dev/docs/get-started/install/linux](https://flutter.dev/docs/get-started/install/linux)
2. Extract the tar file to your desired location
3. Add Flutter to your PATH in `~/.bashrc`:
   ```bash
   export PATH="$PATH:[PATH_TO_FLUTTER_GIT_DIRECTORY]/flutter/bin"
   ```
4. Run:
   ```bash
   flutter doctor
   ```

### 2. Install Required Tools

#### Android Studio (for Android development):
1. Download from [https://developer.android.com/studio](https://developer.android.com/studio)
2. Install Android SDK, Android SDK Command-line Tools, and Android SDK Build-Tools
3. Accept all licenses

#### Xcode (for iOS development - macOS only):
1. Install from Mac App Store
2. Install Xcode Command Line Tools:
   ```bash
   xcode-select --install
   ```

#### VS Code (Recommended IDE):
1. Download from [https://code.visualstudio.com/](https://code.visualstudio.com/)
2. Install Flutter and Dart extensions

### 3. Configure Flutter
Run the following commands to ensure everything is set up correctly:

```bash
flutter doctor
flutter doctor --android-licenses  # Accept all licenses
flutter config --enable-web        # Enable web support (optional)
flutter config --enable-windows-desktop  # Enable Windows desktop (optional)
flutter config --enable-macos-desktop    # Enable macOS desktop (optional)
flutter config --enable-linux-desktop    # Enable Linux desktop (optional)
```

## Project Setup

### 1. Navigate to Project Directory
```bash
cd novago
```

### 2. Get Dependencies
```bash
flutter pub get
```

### 3. Generate Code (if needed)
```bash
flutter packages pub run build_runner build
```

### 4. Run the App

#### Android:
```bash
flutter run
# or
flutter run -d android
```

#### iOS:
```bash
flutter run -d ios
```

#### Web:
```bash
flutter run -d web
```

#### Desktop:
```bash
flutter run -d windows  # Windows
flutter run -d macos    # macOS
flutter run -d linux    # Linux
```

## Firebase Setup (Optional)

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable Authentication, Firestore, and Cloud Messaging

### 2. Configure Firebase for Flutter
1. Install Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```

2. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

3. Configure Firebase:
   ```bash
   flutterfire configure
   ```

### 3. Update Firebase Options
The `lib/firebase_options.dart` file will be automatically generated with your project configuration.

## Troubleshooting

### Common Issues:

#### 1. Flutter not recognized
- Ensure Flutter is added to your system PATH
- Restart your terminal/IDE after adding to PATH

#### 2. Android license issues
```bash
flutter doctor --android-licenses
```

#### 3. iOS simulator issues (macOS)
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

#### 4. Gradle build issues
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### 5. Pod install issues (iOS)
```bash
cd ios
pod install --repo-update
cd ..
```

### Performance Tips:
1. Use `flutter run --release` for production builds
2. Use `flutter build apk --split-per-abi` for smaller APK files
3. Enable R8/ProGuard for Android release builds

## Development Workflow

### 1. Hot Reload
- Press `r` in the terminal while the app is running
- Or use `Ctrl+S` (VS Code) to save and trigger hot reload

### 2. Hot Restart
- Press `R` in the terminal while the app is running

### 3. Debug Mode
- Use `flutter run --debug` for debugging
- Use VS Code debugger or Android Studio debugger

### 4. Release Build
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## Project Structure

```
novago/
├── lib/
│   ├── core/           # Core functionality
│   │   ├── config/     # App configuration
│   │   ├── router/     # Navigation
│   │   └── services/   # Core services
│   ├── features/       # Feature modules
│   │   ├── auth/       # Authentication
│   │   ├── home/       # Home screen
│   │   ├── food/       # Food delivery
│   │   ├── ride/       # Ride hailing
│   │   ├── wallet/     # Wallet & payments
│   │   └── ...         # Other features
│   └── main.dart       # App entry point
├── assets/             # Images, icons, fonts
├── android/            # Android-specific code
├── ios/                # iOS-specific code
├── web/                # Web-specific code
└── test/               # Tests
```

## Next Steps

1. Set up your development environment following this guide
2. Run `flutter doctor` to verify everything is working
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app
5. Begin customizing the app for your specific needs

## Support

If you encounter any issues:
1. Check the [Flutter documentation](https://flutter.dev/docs)
2. Search [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
3. Join the [Flutter Discord](https://discord.gg/flutter)
4. Check the [Flutter GitHub issues](https://github.com/flutter/flutter/issues)

