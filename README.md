# ImageFlow - Image Processing & Analysis App

A Flutter application for image processing and analysis using Google ML Kit. The app can detect faces, process documents, and create PDFs from images with a clean, modern UI.

## 🎥 Feature Videos

Short recordings from key flows in the app.

- [Feature video 1](https://drive.google.com/file/d/13WfJmpz85Yzp8nDg0RPsfTSIG8DytBm7/view?usp=drive_link)
- [Feature video 2](https://drive.google.com/file/d/1rG6LqEZJ1EXoMoAgTo-p2K54Az_WtfNO/view?usp=drive_link)
- [Feature video 3](https://drive.google.com/file/d/1PF56AfUd_ue474D6QeqFrlad_mptoPG-/view?usp=drive_link)
- [Feature video 4](https://drive.google.com/file/d/1rDVcQK1fHGSUp4aeCeWA1jUzW-WkNcSr/view?usp=drive_link)
- [Feature video 5](https://drive.google.com/file/d/1-P100vNHnls53xgtTE3aaxuvcbil2RWw/view?usp=drive_link)
- [Feature video 6](https://drive.google.com/file/d/1DD7wa2TVCHkCDzvueHR9qZbumiVYAmdS/view?usp=drive_link)

## 📋 Table of Contents

- [Feature Videos](#-feature-videos)
- [Features](#-features)
- [Architecture](#️-architecture)
- [Folder Structure](#-folder-structure)
- [Prerequisites](#️-prerequisites)
- [Installation & Setup](#-installation--setup)
- [How to Run](#-how-to-run)
- [Dependencies](#-dependencies)
- [Architecture Details](#️-architecture-details)
- [Testing](#-testing)
- [Troubleshooting](#-troubleshooting)

## 📱 Features

- **Face Detection & Processing**: Detect faces with ML Kit and apply grayscale filtering
- **Document Processing**: Native document pipeline on iOS/Android with a Dart fallback
- **PDF Generation**: Convert processed documents to PDF format
- **Batch Processing**: Select multiple images from gallery and process in a queue
- **Multi-page Documents**: Reorder/delete pages before exporting a single PDF
- **Mixed Review**: Review documents and faces in separate tabs before finalizing
- **Image History**: View and manage processed items, including grouped face batches
- **Before/After Comparison**: Quick visual comparison for face results
- **Camera & Gallery Support**: Capture from camera or multi-select from gallery
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
│       ├── file_open_service/       # File opening (PDF, images)
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
│       ├── utils/              # Shared feature utilities
│       └── presentation/       # Presentation layer
│           ├── detail/         # Image detail screen
│           ├── document/       # Document builder (multi-page)
│           ├── home/           # Home/history screen
│           ├── mixed_review/   # Mixed review tabs (docs + faces)
│           ├── processing/     # Processing screen
│           ├── source_selector_dialog/ # Source selector dialog
│           └── summary/        # Summary screen
│
├── setup/                      # App setup & configuration
│   └── locator.dart            # Dependency injection setup
│
└── ui_kit/                     # Reusable UI components
    ├── components/             # UI widgets (buttons, dialogs, etc.)
    ├── strings/                # App strings/localization
    ├── styles/                 # Colors, decorations, text styles
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

From the project root:
```bash
flutter pub get
flutter run
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

### Native + Dart Processing

- Face detection/processing runs in Flutter via ML Kit.
- Document processing uses native platform code on iOS/Android through a `MethodChannel`, with a Dart fallback.

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
- ✅ `ProcessingVM` - Image processing flow, face/document detection
- ✅ `DetailVM` - Detail view, image loading, deletion
- ✅ `DocumentVM` - Multi-page document editing and export
- ✅ `SummaryVM` - Summary view and face batch management
- ✅ `SourceSelectorDialogVM` - Camera/gallery selection and batch launch

**Services:**
- ✅ `NavigationService` - Navigation methods and null-safety
- ✅ `ToastService` - Toast message display
- ⚠️ `ImagePickerService` - Basic tests (requires integration tests for full coverage)
- ⚠️ `ImageProcessingService` - Basic tests (requires ML Kit integration)

**Repositories:**
- ⚠️ `ProcessedImageRepository` - Basic structure (requires SQLite integration tests)

See `test/README.md` for detailed test documentation.

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
---

**Built with Flutter** 💙
