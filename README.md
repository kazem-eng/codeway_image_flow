# ImageFlow - Image Processing & Analysis App

A Flutter application for image processing and analysis using Google ML Kit. The app can detect faces, process documents, and create PDFs from images with a clean, modern UI.

## 📋 Table of Contents

- [Features](#-features)
- [Architecture](#️-architecture)
- [Folder Structure](#-folder-structure)
- [Prerequisites](#️-prerequisites)
- [Installation & Setup](#-installation--setup)
- [How to Run](#-how-to-run)
- [Dependencies](#-dependencies)
- [Architecture Details](#️-architecture-details)
- [Testing](#-testing)
- [Code Style](#-code-style)
- [Development Guidelines](#-development-guidelines)
- [Troubleshooting](#-troubleshooting)

## 📱 Features

- **Face Detection & Processing**: Detect and process faces in images using Google ML Kit
- **Document Processing**: Automatically detect and crop documents from images
- **PDF Generation**: Convert processed documents to PDF format
- **Image History**: View and manage your processed images
- **Before/After Comparison**: View original and processed images side-by-side
- **Camera & Gallery Support**: Capture images from camera or select from gallery
- **File Management**: Organize and delete processed images

## 🏗️ Architecture

This project follows **MVVM (Model-View-ViewModel)** architecture pattern with clean architecture principles:

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  (Views, ViewModels, Models, Widgets)                   │
└─────────────────────────────────────────────────────────┘
                         ↕
┌─────────────────────────────────────────────────────────┐
│                     Domain Layer                         │
│              (Entities, Business Logic)                 │
└─────────────────────────────────────────────────────────┘
                         ↕
┌─────────────────────────────────────────────────────────┐
│                      Data Layer                          │
│         (Repositories, Data Models, Services)           │
└─────────────────────────────────────────────────────────┘
```

### Key Architectural Principles

- **Separation of Concerns**: Clear boundaries between presentation, domain, and data layers
- **Dependency Injection**: Using GetX for service locator pattern
- **Reactive State Management**: GetX observables for reactive UI updates
- **Service-Oriented**: Core functionality abstracted into services
- **Type Safety**: Strong typing throughout the codebase

## 📁 Folder Structure

```
lib/
├── app.dart                    # Root app widget
├── main.dart                   # Application entry point
│
├── base/                       # Base classes and utilities
│   ├── base_exception.dart     # Base exception classes
│   ├── database_helper.dart    # SQLite database helper
│   ├── mvvm_base/              # MVVM base classes
│   │   ├── base.dart           # Base exports
│   │   ├── base_state.dart     # State wrapper (loading/success/error)
│   │   ├── base_view.dart      # Base view widget
│   │   └── base_vm.dart        # Base ViewModel class
│   └── services/               # Core services
│       ├── file_storage_service/    # File I/O operations
│       ├── image_picker_service/    # Camera & gallery access
│       ├── image_processing_service/# ML Kit integration
│       ├── navigation_service/     # App navigation
│       └── toast_service/          # User notifications
│
├── features/                   # Feature modules
│   └── image_processing/
│       ├── data/               # Data layer
│       │   ├── models/         # Data models (DB mapping)
│       │   └── repositories/   # Data repositories
│       ├── domain/             # Domain layer
│       │   └── entities/       # Business entities
│       └── presentation/       # Presentation layer
│           ├── capture/        # Image capture screen
│           ├── detail/         # Image detail screen
│           ├── home/           # Home/history screen
│           ├── processing/    # Processing screen
│           └── result/         # Result display screen
│
├── setup/                      # App setup & configuration
│   └── locator.dart            # Dependency injection setup
│
└── ui_kit/                     # Reusable UI components
    ├── components/             # UI widgets (buttons, dialogs, etc.)
    ├── strings/                # App strings/localization
    ├── styles/                 # Colors, decorations, text styles
    ├── theme/                  # App theme configuration
    └── utils/                  # UI utilities (formatters, etc.)
```

## 🛠️ Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK**: Version 3.10.7 or higher
- **Dart SDK**: Included with Flutter
- **Android Studio** / **VS Code** with Flutter extensions
- **Xcode** (for iOS development on macOS)
- **CocoaPods** (for iOS dependencies)

## 📦 Installation & Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd codeway_image_processing
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **iOS Setup** (macOS only)
   ```bash
   cd ios
   pod install
   cd ..
   ```

4. **Android Setup**
   - Ensure Android SDK is installed
   - No additional setup required

## 🚀 How to Run

### Run on iOS Simulator
```bash
flutter run -d ios
```

Or use the provided script:
```bash
./run_ios.sh
```

### Run on Android Emulator/Device
```bash
flutter run -d android
```

### Run on macOS
```bash
flutter run -d macos
```

### Run on Web
```bash
flutter run -d chrome
```

### Build for Production

**iOS:**
```bash
flutter build ios --release
```

**Android:**
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

## 📚 Dependencies

### Core Dependencies

- **get** (^4.6.6): State management and dependency injection
- **sqflite** (^2.3.0): SQLite database for local storage
- **path_provider** (^2.1.1): File system path utilities

### ML Kit Dependencies

- **google_mlkit_face_detection** (^0.11.0): Face detection
- **google_mlkit_text_recognition** (^0.13.1): Text recognition

### Image Processing

- **image** (^4.1.7): Image manipulation
- **pdf** (^3.11.1): PDF generation
- **printing** (^5.12.0): PDF printing support

### Camera & Media

- **camera** (^0.11.0+2): Camera access
- **image_picker** (^1.1.2): Image picker from gallery

### Utilities

- **permission_handler** (^11.3.1): Runtime permissions
- **path** (^1.9.0): Path manipulation
- **intl** (^0.20.2): Internationalization
- **uuid** (^4.5.1): UUID generation
- **open_filex** (^4.4.0): File opening utilities

## 🏛️ Architecture Details

### MVVM Pattern

Each feature follows the MVVM pattern:

- **View**: Stateless widget that displays UI (`*_view.dart`)
- **ViewModel**: Business logic and state management (`*_vm.dart`)
- **Model**: Data structure for the screen (`*_model.dart`)

### State Management

The app uses a custom `BaseState` wrapper with three states:
- `loading`: Operation in progress
- `success`: Operation completed successfully
- `error`: Operation failed

### Dependency Injection

Services are registered in `setup/locator.dart` using GetX service locator pattern:

```dart
void setupLocator({required GlobalKey<NavigatorState> navigatorKey}) {
  // Register services
  Get.put<INavigationService>(NavigationService(navigatorKey: navigatorKey));
  Get.put<IFileStorageService>(FileStorageService());
  // ... more services
}
```

### Navigation

- Uses named routes with `RoutesHandler.onGenerateRoute`
- Navigation service abstracts Navigator API
- Route arguments passed via props classes

### File Storage

- Images stored in app documents directory
- Organized by type: `faces/`, `documents/`, `thumbnails/`
- SQLite database tracks metadata

## 🧪 Testing

### Running Tests

Run all tests:
```bash
flutter test
```

Run specific test file:
```bash
flutter test test/presentation/home/home_vm_test.dart
```

Run tests with coverage:
```bash
flutter test --coverage
```

Generate coverage report:
```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Test Coverage

The project includes comprehensive unit tests for:

**ViewModels:**
- ✅ `HomeVM` - History loading, deletion, navigation, PDF operations
- ✅ `CaptureVM` - Image capture from camera/gallery
- ✅ `ProcessingVM` - Image processing flow, face/document detection
- ✅ `ResultVM` - Result display, image loading, navigation
- ✅ `DetailVM` - Detail view, image loading, deletion

**Services:**
- ✅ `NavigationService` - Navigation methods and null-safety
- ✅ `ToastService` - Toast message display
- ⚠️ `ImagePickerService` - Basic tests (requires integration tests for full coverage)
- ⚠️ `ImageProcessingService` - Basic tests (requires ML Kit integration)

**Repositories:**
- ⚠️ `ProcessedImageRepository` - Basic structure (requires SQLite integration tests)

See `test/README.md` for detailed test documentation.

## 📝 Code Style

The project follows Flutter/Dart style guidelines:
- Uses `flutter_lints` package
- Follows Dart style guide
- Private members prefixed with `_`
- Widget files prefixed with `_` are private to their feature

## 🔧 Development Guidelines

### Adding a New Feature

1. Create feature folder under `lib/features/`
2. Structure: `data/`, `domain/`, `presentation/`
3. Create ViewModel extending base classes
4. Register services in `setup/locator.dart`
5. Add routes in `routes.dart` and `routes_handler.dart`

### Adding a New Service

1. Create interface in `base/services/[service_name]/i_[service_name].dart`
2. Implement in `base/services/[service_name]/[service_name].dart`
3. Register in `setup/locator.dart`
4. Export in `services_export.dart`

### State Management Best Practices

- Use `BaseState` wrapper for all ViewModel states
- Handle loading, success, and error states
- Preserve model data in error states for retry
- Use `maybeWhen` for reactive UI updates

## 🐛 Troubleshooting

### iOS Build Issues
- Run `pod install` in `ios/` directory
- Clean build: `flutter clean && flutter pub get`
- Check Xcode version compatibility

### Android Build Issues
- Ensure Android SDK is properly configured
- Check `android/app/build.gradle` for correct SDK versions
- Clean build: `flutter clean && flutter pub get`

### Permission Issues
- Check `Info.plist` (iOS) and `AndroidManifest.xml` (Android)
- Ensure permissions are requested at runtime

## 📄 License

This project is private and proprietary.

## 👥 Contributing

This is a private project. For questions or issues, please contact the project maintainers.

## 📞 Support

For issues or questions, please refer to the project documentation or contact the development team.

---

**Built with Flutter** 💙
