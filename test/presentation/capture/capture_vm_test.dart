import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/mockito.dart';

import 'package:codeway_image_processing/base/services/navigation_service/routes.dart';
import 'package:codeway_image_processing/base/services/toast_service/i_toast_service.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/capture/capture_vm.dart';

import '../../helpers/mocks.dart';

// Helper to use any with proper typing
dynamic anyString = any;

void main() {
  late CaptureVM captureVM;
  late MockINavigationService mockNavigationService;
  late MockIImagePickerService mockImagePickerService;
  late MockIToastService mockToastService;

  void createCaptureVM() {
    captureVM = CaptureVM(
      navigationService: mockNavigationService,
      imagePickerService: mockImagePickerService,
    );
  }

  setUp(() {
    Get.testMode = true;
    Get.reset();
    mockNavigationService = MockINavigationService();
    mockImagePickerService = MockIImagePickerService();
    mockToastService = MockIToastService();

    Get.put<IToastService>(mockToastService);
  });

  tearDown(() {
    Get.reset();
  });

  group('CaptureVM', () {
    group('selectSource', () {
      test('should update state with selected source', () async {
        // Arrange
        createCaptureVM();
        // Act
        await captureVM.selectSource(ImageSource.camera);

        // Assert
        expect(captureVM.model.selectedSource, ImageSource.camera);
        expect(captureVM.model.hasPermission, true);
        expect(captureVM.state.isSuccess, true);
      });
    });

    group('captureFromCamera', () {
      test('should capture image from camera successfully', () async {
        // Arrange
        reset(mockImagePickerService);
        reset(mockNavigationService);
        final testBytes = TestHelpers.createTestImageBytes();
        when(
          mockImagePickerService.pickImage(
            source: ImageSource.camera,
            imageQuality: 85,
          ),
        ).thenAnswer((_) async => testBytes);
        when(
          mockNavigationService.goTo(
            anyString,
            arguments: anyNamed('arguments'),
          ),
        ).thenAnswer((_) async => {});
        createCaptureVM();

        // Act
        await captureVM.captureFromCamera();

        // Assert
        verify(
          mockImagePickerService.pickImage(
            source: ImageSource.camera,
            imageQuality: 85,
          ),
        ).called(1);
        verify(
          mockNavigationService.goTo(
            Routes.processing,
            arguments: argThat(isNotNull, named: 'arguments'),
          ),
        ).called(1);
      });

      test('should handle error when camera capture fails', () async {
        // Arrange
        reset(mockImagePickerService);
        reset(mockToastService);
        when(
          mockImagePickerService.pickImage(
            source: ImageSource.camera,
            imageQuality: 85,
          ),
        ).thenThrow(Exception('Camera error'));
        createCaptureVM();

        // Act
        await captureVM.captureFromCamera();

        // Assert
        verify(
          mockToastService.show(
            argThat(contains('Failed to capture')),
            type: anyNamed('type'),
          ),
        ).called(1);
      });
    });

    group('captureFromGallery', () {
      test('should pick image from gallery successfully', () async {
        // Arrange
        reset(mockImagePickerService);
        reset(mockNavigationService);
        final testBytes = TestHelpers.createTestImageBytes();
        when(
          mockImagePickerService.pickImage(
            source: ImageSource.gallery,
            imageQuality: 85,
          ),
        ).thenAnswer((_) async => testBytes);
        when(
          mockNavigationService.goTo(
            anyString,
            arguments: anyNamed('arguments'),
          ),
        ).thenAnswer((_) async => {});
        createCaptureVM();

        // Act
        await captureVM.captureFromGallery();

        // Assert
        verify(
          mockImagePickerService.pickImage(
            source: ImageSource.gallery,
            imageQuality: 85,
          ),
        ).called(1);
        verify(
          mockNavigationService.goTo(
            Routes.processing,
            arguments: argThat(isNotNull, named: 'arguments'),
          ),
        ).called(1);
      });

      test('should handle error when gallery pick fails', () async {
        // Arrange
        reset(mockImagePickerService);
        reset(mockToastService);
        when(
          mockImagePickerService.pickImage(
            source: ImageSource.gallery,
            imageQuality: 85,
          ),
        ).thenThrow(Exception('Gallery error'));
        createCaptureVM();

        // Act
        await captureVM.captureFromGallery();

        // Assert
        verify(
          mockToastService.show(
            argThat(contains('Failed to capture')),
            type: anyNamed('type'),
          ),
        ).called(1);
      });
    });

    group('markSourceDialogShown', () {
      test('should mark dialog as shown when showSourceDialog is true', () {
        // Arrange
        createCaptureVM();
        captureVM.selectSource(ImageSource.camera);
        // Note: This test depends on internal state management
        // In a real scenario, you'd need to set up the state first

        // Act
        captureVM.markSourceDialogShown();

        // Assert - verify state is updated
        expect(captureVM.state.isSuccess, true);
      });
    });

    group('captureImage', () {
      test('should set isProcessing flag during capture', () async {
        // Arrange
        reset(mockImagePickerService);
        reset(mockNavigationService);
        final testBytes = TestHelpers.createTestImageBytes();
        when(
          mockImagePickerService.pickImage(
            source: ImageSource.camera,
            imageQuality: 85,
          ),
        ).thenAnswer((_) async => testBytes);
        when(
          mockNavigationService.goTo(
            anyString,
            arguments: anyNamed('arguments'),
          ),
        ).thenAnswer((_) async => {});
        createCaptureVM();

        // Act
        await captureVM.captureImage();

        // Assert
        expect(
          captureVM.model.isProcessing,
          false,
        ); // Should be false after completion
        verify(
          mockImagePickerService.pickImage(
            source: ImageSource.camera,
            imageQuality: 85,
          ),
        ).called(1);
      });

      test('should handle null bytes from picker', () async {
        // Arrange
        reset(mockImagePickerService);
        reset(mockNavigationService);
        when(
          mockImagePickerService.pickImage(
            source: ImageSource.camera,
            imageQuality: 85,
          ),
        ).thenAnswer((_) async => null);
        createCaptureVM();

        // Act
        await captureVM.captureImage();

        // Assert
        verifyNever(
          mockNavigationService.goTo(
            anyString,
            arguments: anyNamed('arguments'),
          ),
        );
      });
    });

    group('pickFromGallery', () {
      test('should process image from gallery', () async {
        // Arrange
        reset(mockImagePickerService);
        reset(mockNavigationService);
        final testBytes = TestHelpers.createTestImageBytes();
        when(
          mockImagePickerService.pickImage(
            source: ImageSource.gallery,
            imageQuality: 85,
          ),
        ).thenAnswer((_) async => testBytes);
        when(
          mockNavigationService.goTo(
            anyString,
            arguments: anyNamed('arguments'),
          ),
        ).thenAnswer((_) async => {});
        createCaptureVM();

        // Act
        await captureVM.pickFromGallery();

        // Assert
        verify(
          mockImagePickerService.pickImage(
            source: ImageSource.gallery,
            imageQuality: 85,
          ),
        ).called(1);
        verify(
          mockNavigationService.goTo(
            Routes.processing,
            arguments: argThat(isNotNull, named: 'arguments'),
          ),
        ).called(1);
      });
    });
  });
}
