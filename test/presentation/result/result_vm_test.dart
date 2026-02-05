import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';

import 'package:codeway_image_processing/base/base_exception.dart';
import 'package:codeway_image_processing/base/services/navigation_service/routes.dart';
import 'package:codeway_image_processing/base/services/toast_service/i_toast_service.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processing_type.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/result/result_vm.dart';

import '../../helpers/mocks.dart';

// Helper to use any with proper typing
dynamic anyString = any;

void main() {
  late ResultVM resultVM;
  late MockIFileStorageService mockFileStorageService;
  late MockIFileOpenService mockFileOpenService;
  late MockINavigationService mockNavigationService;
  late MockIToastService mockToastService;

  void createResultVM() {
    resultVM = ResultVM(
      fileStorageService: mockFileStorageService,
      fileOpenService: mockFileOpenService,
      navigationService: mockNavigationService,
    );
  }

  setUp(() {
    Get.testMode = true;
    Get.reset();
    mockFileStorageService = MockIFileStorageService();
    mockFileOpenService = MockIFileOpenService();
    mockNavigationService = MockINavigationService();
    mockToastService = MockIToastService();

    Get.put<IToastService>(mockToastService);
    // Ensure mocks are in clean state
    reset(mockFileStorageService);
    reset(mockNavigationService);
    reset(mockToastService);
  });

  tearDown(() {
    Get.reset();
  });

  group('ResultVM', () {
    group('init', () {
      test('should initialize with processed image', () async {
        // Arrange
        reset(mockFileStorageService);
        final testImage = TestHelpers.createTestProcessedImage();
        final testBytes = TestHelpers.createTestImageBytes();
        // Stub for both original and processed paths
        when(
          mockFileStorageService.loadImage(argThat(isA<String>())),
        ).thenAnswer((_) async => testBytes);
        createResultVM();

        // Act
        await resultVM.init(testImage);

        // Assert
        expect(resultVM.model.processedImage, testImage);
        // init automatically calls loadImages, which loads both original and processed
        // Verify that loadImage was called at least twice (original + processed)
        verify(
          mockFileStorageService.loadImage(argThat(isA<String>())),
        ).called(greaterThanOrEqualTo(2));
      });
    });

    group('screenTitle', () {
      test('should return face title for face type', () {
        // Arrange
        createResultVM();
        final testImage = TestHelpers.createTestProcessedImage(
          type: ProcessingType.face,
        );
        resultVM.init(testImage);

        // Act
        final title = resultVM.screenTitle;

        // Assert
        expect(title, isNotEmpty);
      });

      test('should return PDF title for document type', () {
        // Arrange
        createResultVM();
        final testImage = TestHelpers.createTestProcessedImage(
          type: ProcessingType.document,
        );
        resultVM.init(testImage);

        // Act
        final title = resultVM.screenTitle;

        // Assert
        expect(title, isNotEmpty);
      });
    });

    group('loadImages', () {
      test('should load images successfully for face type', () async {
        // Arrange
        reset(mockFileStorageService);
        final testImage = TestHelpers.createTestProcessedImage(
          type: ProcessingType.face,
        );
        final testBytes = TestHelpers.createTestImageBytes();
        // Stub for both original and processed paths
        when(
          mockFileStorageService.loadImage(argThat(isA<String>())),
        ).thenAnswer((_) async => testBytes);
        createResultVM();

        // Act - init calls loadImages automatically
        await resultVM.init(testImage);

        // Assert
        expect(resultVM.state.isSuccess, true);
        expect(resultVM.model.originalImage, isNotNull);
        expect(resultVM.model.processedImageBytes, isNotNull);
        // init calls loadImages which loads both original and processed
        verify(
          mockFileStorageService.loadImage(argThat(isA<String>())),
        ).called(greaterThanOrEqualTo(2)); // Original and processed
      });

      test('should load PDF bytes for document type', () async {
        // Arrange
        reset(mockFileStorageService);
        final testImage = TestHelpers.createTestProcessedImage(
          type: ProcessingType.document,
        );
        final testBytes = TestHelpers.createTestImageBytes();
        // Stub for both original image and PDF
        when(
          mockFileStorageService.loadImage(argThat(isA<String>())),
        ).thenAnswer((_) async => testBytes);
        when(
          mockFileStorageService.loadPdfBytes(argThat(isA<String>())),
        ).thenAnswer((_) async => testBytes);
        createResultVM();

        // Act - init calls loadImages automatically
        await resultVM.init(testImage);

        // Assert
        expect(resultVM.state.isSuccess, true);
        verify(
          mockFileStorageService.loadImage(argThat(isA<String>())),
        ).called(greaterThanOrEqualTo(1)); // Original
        verify(
          mockFileStorageService.loadPdfBytes(argThat(isA<String>())),
        ).called(greaterThanOrEqualTo(1));
      });

      test('should handle error when loading images fails', () async {
        // Arrange
        reset(mockFileStorageService);
        reset(mockToastService);
        final testImage = TestHelpers.createTestProcessedImage();
        when(
          mockFileStorageService.loadImage(anyString),
        ).thenThrow(Exception('Load error'));
        createResultVM();
        // init calls loadImages automatically, which will fail
        await resultVM.init(testImage);

        // Assert
        expect(resultVM.state.isError, true);
        expect(resultVM.state.exception, isA<StorageException>());
        verify(
          mockToastService.show(
            argThat(contains('Failed to load')),
            type: anyNamed('type'),
          ),
        ).called(greaterThanOrEqualTo(1));
      });

      test('should return early if processedImage is null', () async {
        // Arrange
        reset(mockFileStorageService);
        createResultVM();
        // Act
        await resultVM.loadImages();

        // Assert
        verifyNever(mockFileStorageService.loadImage(anyString));
      });
    });

    group('done', () {
      test('should navigate back to home and show success toast', () async {
        // Arrange
        reset(mockFileStorageService);
        reset(mockNavigationService);
        reset(mockToastService);
        final testImage = TestHelpers.createTestProcessedImage();
        final testBytes = TestHelpers.createTestImageBytes();
        // Stub loadImage for both original and processed
        when(
          mockFileStorageService.loadImage(argThat(isA<String>())),
        ).thenAnswer((_) async => testBytes);
        when(
          mockNavigationService.goBackUntil(anyString),
        ).thenAnswer((_) async => {});
        createResultVM();
        // init calls loadImages automatically, which should succeed
        await resultVM.init(testImage);
        // Ensure state is success
        expect(resultVM.state.isSuccess, true);

        // Act
        await resultVM.done();

        // Assert
        verify(mockNavigationService.goBackUntil(Routes.home)).called(1);
        verify(
          mockToastService.show(
            argThat(contains('successfully')),
            type: anyNamed('type'),
          ),
        ).called(1);
      });

      test('should not show toast if state is not success', () async {
        // Arrange
        reset(mockFileStorageService);
        reset(mockNavigationService);
        reset(mockToastService);
        final testImage = TestHelpers.createTestProcessedImage();
        when(
          mockFileStorageService.loadImage(anyString),
        ).thenThrow(Exception('Error'));
        when(
          mockNavigationService.goBackUntil(anyString),
        ).thenAnswer((_) async => {});
        createResultVM();
        await resultVM.init(testImage);
        await resultVM.loadImages(); // This will fail

        // Act
        await resultVM.done();

        // Assert
        verify(mockNavigationService.goBackUntil(Routes.home)).called(1);
        verifyNever(
          mockToastService.show(
            argThat(contains('successfully')),
            type: anyNamed('type'),
          ),
        );
      });
    });

    group('openPdf', () {
      test('should open PDF when path exists', () async {
        // Arrange
        reset(mockFileStorageService);
        reset(mockFileOpenService);
        final testImage = TestHelpers.createTestProcessedImage(
          type: ProcessingType.document,
        );
        final testBytes = TestHelpers.createTestImageBytes();
        when(
          mockFileStorageService.loadImage(anyString),
        ).thenAnswer((_) async => testBytes);
        when(
          mockFileStorageService.loadPdfBytes(anyString),
        ).thenAnswer((_) async => testBytes);
        when(mockFileOpenService.open(anyString)).thenAnswer((_) async => {});
        createResultVM();
        await resultVM.init(testImage);
        await resultVM.loadImages();

        // Act
        await resultVM.openPdf();

        // Assert
        verify(mockFileOpenService.open(argThat(isA<String>()))).called(1);
      });

      test('should return early if path is null', () async {
        // Arrange
        reset(mockFileStorageService);
        reset(mockFileOpenService);
        final testImage = TestHelpers.createTestProcessedImage(
          type: ProcessingType.face,
        );
        final testBytes = TestHelpers.createTestImageBytes();
        when(
          mockFileStorageService.loadImage(anyString),
        ).thenAnswer((_) async => testBytes);
        createResultVM();
        await resultVM.init(testImage);
        await resultVM.loadImages();

        // Act
        await resultVM.openPdf();

        // Assert - should return early without error
        verifyNever(mockFileOpenService.open(argThat(isA<String>())));
      });
    });
  });
}
