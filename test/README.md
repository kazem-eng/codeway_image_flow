# Test Suite

This directory contains unit tests for the ImageFlow application.

## Test Structure

```
test/
├── helpers/
│   └── mocks.dart                    # Mock classes and test helpers
├── presentation/                     # ViewModel tests
│   ├── capture/
│   │   └── capture_vm_test.dart
│   ├── detail/
│   │   └── detail_vm_test.dart
│   ├── home/
│   │   └── home_vm_test.dart
│   ├── processing/
│   │   └── processing_vm_test.dart
│   └── result/
│       └── result_vm_test.dart
├── services/                         # Service tests
│   ├── image_picker_service_test.dart
│   ├── image_processing_service_test.dart
│   ├── navigation_service_test.dart
│   └── toast_service_test.dart
└── repositories/                     # Repository tests
    └── processed_image_repository_test.dart
```

## Running Tests

### Run all tests
```bash
flutter test
```

### Run specific test file
```bash
flutter test test/presentation/home/home_vm_test.dart
```

### Run tests with coverage
```bash
flutter test --coverage
```

### Generate coverage report
```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Test Coverage

### ViewModels (Unit Tests)
- ✅ **HomeVM**: History loading, deletion, navigation, PDF opening
- ✅ **CaptureVM**: Image capture from camera/gallery, source selection
- ✅ **ProcessingVM**: Image processing flow, face/document detection, saving
- ✅ **ResultVM**: Image loading, navigation, PDF opening
- ✅ **DetailVM**: Image loading, deletion, PDF opening

### Services (Unit Tests)
- ✅ **NavigationService**: Null-safety and basic navigation methods
- ✅ **ToastService**: Message display handling
- ⚠️ **ImagePickerService**: Basic instantiation (requires integration tests for full coverage)
- ⚠️ **ImageProcessingService**: Basic instantiation (requires ML Kit integration tests)

### Repositories (Integration Tests Recommended)
- ⚠️ **ProcessedImageRepository**: Requires SQLite database setup for full testing

## Testing Best Practices

### Mocking
- Use `Mockito` for creating mocks
- Mock all external dependencies (services, repositories)
- Use `Get.testMode = true` for GetX services

### Test Structure
- Use `setUp()` and `tearDown()` for test initialization
- Group related tests using `group()`
- Follow AAA pattern: Arrange, Act, Assert

### Example Test Structure
```dart
group('FeatureName', () {
  setUp(() {
    // Initialize mocks and dependencies
  });

  tearDown(() {
    // Clean up
  });

  group('methodName', () {
    test('should do something successfully', () async {
      // Arrange
      // Act
      // Assert
    });

    test('should handle error case', () async {
      // Arrange
      // Act
      // Assert
    });
  });
});
```

## Notes

### Services Requiring Integration Tests
Some services require actual device/simulator and external dependencies:
- **ImagePickerService**: Requires camera/gallery permissions
- **ImageProcessingService**: Requires ML Kit initialization
- **FileStorageService**: Requires file system access
- **ProcessedImageRepository**: Requires SQLite database

These are marked with basic instantiation tests. Full integration tests should be added separately.

### Mock Generation
To generate mocks using Mockito annotations:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate mock classes from `@GenerateMocks` annotations in `test/helpers/mocks.dart`.
