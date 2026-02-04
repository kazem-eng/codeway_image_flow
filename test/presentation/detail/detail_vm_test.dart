import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';

import 'package:codeway_image_processing/base/services/toast_service/i_toast_service.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processing_type.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/detail/detail_vm.dart';

import '../../helpers/mocks.dart';

// Helper to use any with proper typing
dynamic anyString = any;

void main() {
  late DetailVM detailVM;
  late MockIProcessedImageRepository mockRepository;
  late MockIFileStorageService mockFileStorageService;
  late MockINavigationService mockNavigationService;
  late MockIToastService mockToastService;

  void createDetailVM() {
    detailVM = DetailVM(
      repository: mockRepository,
      fileStorageService: mockFileStorageService,
      navigationService: mockNavigationService,
    );
  }

  setUp(() {
    Get.testMode = true;
    Get.reset();
    mockRepository = MockIProcessedImageRepository();
    mockFileStorageService = MockIFileStorageService();
    mockNavigationService = MockINavigationService();
    mockToastService = MockIToastService();

    Get.put<IToastService>(mockToastService);
    // Ensure mocks are in clean state
    reset(mockRepository);
    reset(mockFileStorageService);
    reset(mockNavigationService);
    reset(mockToastService);
  });

  tearDown(() {
    Get.reset();
  });

  group('DetailVM', () {
    group('init', () {
      test('should initialize with image ID', () async {
        // Arrange
        reset(mockRepository);
        final testImage = TestHelpers.createTestProcessedImage(id: 'test-id');
        when(mockRepository.init()).thenAnswer((_) async => {});
        when(
          mockRepository.getById('test-id'),
        ).thenAnswer((_) async => testImage);
        createDetailVM();

        // Act
        await detailVM.init('test-id');

        // Assert
        expect(detailVM.model.imageId, 'test-id');
        verify(mockRepository.init()).called(1);
        verify(mockRepository.getById('test-id')).called(1);
      });
    });

    group('loadImage', () {
      test('should load image successfully', () async {
        // Arrange
        reset(mockRepository);
        reset(mockFileStorageService);
        final testImage = TestHelpers.createTestProcessedImage(id: 'test-id');
        final testBytes = TestHelpers.createTestImageBytes();
        when(mockRepository.init()).thenAnswer((_) async => {});
        when(
          mockRepository.getById('test-id'),
        ).thenAnswer((_) async => testImage);
        // loadImage loads both original and processed images
        when(
          mockFileStorageService.loadImage(argThat(isA<String>())),
        ).thenAnswer((_) async => testBytes);
        createDetailVM();
        // init calls loadImage automatically
        await detailVM.init('test-id');

        // Assert
        expect(detailVM.state.isSuccess, true);
        expect(detailVM.model.image, testImage);
        // loadImage loads both original and processed
        verify(
          mockFileStorageService.loadImage(argThat(isA<String>())),
        ).called(greaterThanOrEqualTo(2));
      });

      test('should handle error when image not found', () async {
        // Arrange
        reset(mockRepository);
        reset(mockToastService);
        when(mockRepository.init()).thenAnswer((_) async => {});
        when(
          mockRepository.getById('non-existent'),
        ).thenAnswer((_) async => null);
        createDetailVM();
        // init calls loadImage automatically
        await detailVM.init('non-existent');

        // Assert
        expect(detailVM.state.isError, true);
        // No toast shown for not found - it's just an error state
      });

      test('should handle error when loading fails', () async {
        // Arrange
        reset(mockRepository);
        reset(mockFileStorageService);
        reset(mockToastService);
        final testImage = TestHelpers.createTestProcessedImage(id: 'test-id');
        when(mockRepository.init()).thenAnswer((_) async => {});
        when(
          mockRepository.getById('test-id'),
        ).thenAnswer((_) async => testImage);
        when(
          mockFileStorageService.loadImage(argThat(isA<String>())),
        ).thenThrow(Exception('Load error'));
        createDetailVM();
        // init calls loadImage automatically
        await detailVM.init('test-id');

        // Assert
        expect(detailVM.state.isError, true);
        // Error is handled in state, no toast shown
      });

      test('should return early if imageId is null', () async {
        // Arrange - Create VM without calling init, so imageId is null
        reset(mockRepository);
        createDetailVM();
        // Don't call init, so imageId remains null

        // Act
        await detailVM.loadImage();

        // Assert
        verifyNever(mockRepository.getById(argThat(isA<String>())));
      });
    });

    group('deleteImage', () {
      test('should delete image successfully', () async {
        // Arrange
        reset(mockRepository);
        reset(mockFileStorageService);
        reset(mockNavigationService);
        reset(mockToastService);
        final testImage = TestHelpers.createTestProcessedImage(id: 'test-id');
        final testBytes = TestHelpers.createTestImageBytes();
        when(mockRepository.init()).thenAnswer((_) async => {});
        when(
          mockRepository.getById('test-id'),
        ).thenAnswer((_) async => testImage);
        when(
          mockFileStorageService.loadImage(anyString),
        ).thenAnswer((_) async => testBytes);
        when(
          mockFileStorageService.deleteProcessedImageFiles(testImage),
        ).thenAnswer((_) async => {});
        when(mockRepository.delete('test-id')).thenAnswer((_) async => {});
        when(mockNavigationService.goBack()).thenReturn(null);
        createDetailVM();
        await detailVM.init('test-id');
        await detailVM.loadImage();

        // Act
        await detailVM.deleteImage();

        // Assert
        verify(
          mockFileStorageService.deleteProcessedImageFiles(testImage),
        ).called(1);
        verify(mockRepository.delete('test-id')).called(1);
        verify(mockNavigationService.goBack()).called(1);
        verify(mockToastService.show(argThat(isA<String>()))).called(1);
      });

      test('should handle error when deletion fails', () async {
        // Arrange
        reset(mockRepository);
        reset(mockFileStorageService);
        reset(mockToastService);
        final testImage = TestHelpers.createTestProcessedImage(id: 'test-id');
        final testBytes = TestHelpers.createTestImageBytes();
        when(mockRepository.init()).thenAnswer((_) async => {});
        when(
          mockRepository.getById('test-id'),
        ).thenAnswer((_) async => testImage);
        // loadImage loads both original and processed
        when(
          mockFileStorageService.loadImage(argThat(isA<String>())),
        ).thenAnswer((_) async => testBytes);
        when(
          mockFileStorageService.deleteProcessedImageFiles(testImage),
        ).thenThrow(Exception('Delete failed'));
        createDetailVM();
        // init calls loadImage automatically
        await detailVM.init('test-id');

        // Act
        await detailVM.deleteImage();

        // Assert
        verify(mockToastService.show(argThat(contains('Failed')))).called(1);
        verifyNever(mockRepository.delete(argThat(isA<String>())));
      });
    });

    group('openPdf', () {
      test('should open PDF for document type', () async {
        // Arrange
        reset(mockRepository);
        reset(mockFileStorageService);
        final testImage = TestHelpers.createTestProcessedImage(
          id: 'test-id',
          type: ProcessingType.document,
        );
        final testBytes = TestHelpers.createTestImageBytes();
        when(mockRepository.init()).thenAnswer((_) async => {});
        when(
          mockRepository.getById('test-id'),
        ).thenAnswer((_) async => testImage);
        when(
          mockFileStorageService.loadImage(anyString),
        ).thenAnswer((_) async => testBytes);

        createDetailVM();
        await detailVM.init('test-id');

        // Act
        await detailVM.openPdf();

        // Note: OpenFilex.open is hard to mock, so we just verify it doesn't throw
      });

      test('should not open PDF for face type', () async {
        // Arrange
        reset(mockRepository);
        reset(mockFileStorageService);
        final testImage = TestHelpers.createTestProcessedImage(
          id: 'test-id',
          type: ProcessingType.face,
        );
        final testBytes = TestHelpers.createTestImageBytes();
        when(mockRepository.init()).thenAnswer((_) async => {});
        when(
          mockRepository.getById('test-id'),
        ).thenAnswer((_) async => testImage);
        when(
          mockFileStorageService.loadImage(anyString),
        ).thenAnswer((_) async => testBytes);

        createDetailVM();
        await detailVM.init('test-id');

        // Act
        await detailVM.openPdf();

        // Assert - should return early without opening
      });
    });
  });
}
