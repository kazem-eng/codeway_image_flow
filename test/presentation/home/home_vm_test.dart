import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';

import 'package:codeway_image_processing/base/base_exception.dart';
import 'package:codeway_image_processing/base/services/navigation_service/routes.dart';
import 'package:codeway_image_processing/base/services/toast_service/i_toast_service.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processing_type.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/home/home_vm.dart';

import '../../helpers/mocks.dart';

// Helper to use any with proper typing
dynamic anyString = any;
dynamic anyProcessedImage = any;

void main() {
  late HomeVM homeVM;
  late MockIProcessedImageRepository mockRepository;
  late MockIFileStorageService mockFileStorageService;
  late MockIFileOpenService mockFileOpenService;
  late MockINavigationService mockNavigationService;
  late MockCaptureVM mockCaptureVM;
  late MockIToastService mockToastService;

  setUp(() {
    Get.testMode = true;
    Get.reset();
    mockRepository = MockIProcessedImageRepository();
    mockFileStorageService = MockIFileStorageService();
    mockFileOpenService = MockIFileOpenService();
    mockNavigationService = MockINavigationService();
    mockCaptureVM = MockCaptureVM();
    mockToastService = MockIToastService();

    Get.put<IToastService>(mockToastService);
  });

  void createHomeVM() {
    homeVM = HomeVM(
      repository: mockRepository,
      fileStorageService: mockFileStorageService,
      fileOpenService: mockFileOpenService,
      navigationService: mockNavigationService,
      captureVm: mockCaptureVM,
    );
  }

  tearDown(() {
    Get.reset();
  });

  group('HomeVM', () {
    group('loadHistory', () {
      test('should load history successfully', () async {
        // Arrange
        // Ensure mock is in clean state - reset clears previous stubs
        reset(mockRepository);
        final testImages = [
          TestHelpers.createTestProcessedImage(id: '1'),
          TestHelpers.createTestProcessedImage(id: '2'),
        ];
        // Stub methods before creating VM to avoid any calls during construction
        when(mockRepository.init()).thenAnswer((_) async => {});
        when(mockRepository.getAll()).thenAnswer((_) async => testImages);
        createHomeVM();

        // Act
        await homeVM.loadHistory();

        // Assert
        expect(homeVM.state.isSuccess, true);
        expect(homeVM.model.history.length, 2);
        verify(mockRepository.init()).called(1);
        verify(mockRepository.getAll()).called(1);
      });

      test('should handle error when loading history fails', () async {
        // Arrange
        reset(mockRepository);
        when(mockRepository.init()).thenThrow(Exception('Database error'));
        createHomeVM();

        // Act
        await homeVM.loadHistory();

        // Assert
        expect(homeVM.state.isError, true);
        expect(homeVM.state.exception, isA<StorageException>());
        expect(homeVM.state.data, isNotNull); // Should preserve model
      });
    });

    group('deleteItem', () {
      test('should delete item successfully', () async {
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
          mockFileStorageService.deleteProcessedImageFiles(testImage),
        ).thenAnswer((_) async => {});
        when(mockRepository.delete('test-id')).thenAnswer((_) async => {});
        when(mockRepository.getAll()).thenAnswer((_) async => []);
        createHomeVM();

        // Act
        await homeVM.deleteItem('test-id');

        // Assert
        verify(
          mockFileStorageService.deleteProcessedImageFiles(testImage),
        ).called(1);
        verify(mockRepository.delete('test-id')).called(1);
        verify(
          mockToastService.show(anyString, type: anyNamed('type')),
        ).called(1);
      });

      test('should handle error when deletion fails', () async {
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
          mockFileStorageService.deleteProcessedImageFiles(testImage),
        ).thenThrow(Exception('Delete failed'));
        createHomeVM();

        // Act
        await homeVM.deleteItem('test-id');

        // Assert
        verify(
          mockToastService.show(
            argThat(contains('Failed to delete')),
            type: anyNamed('type'),
          ),
        ).called(1);
        verifyNever(mockRepository.delete(anyString));
      });

      test('should not delete if image not found', () async {
        // Arrange
        reset(mockRepository);
        reset(mockFileStorageService);
        when(mockRepository.init()).thenAnswer((_) async => {});
        when(
          mockRepository.getById('non-existent'),
        ).thenAnswer((_) async => null);
        createHomeVM();

        // Act
        await homeVM.deleteItem('non-existent');

        // Assert
        verifyNever(
          mockFileStorageService.deleteProcessedImageFiles(anyProcessedImage),
        );
        verifyNever(mockRepository.delete(anyString));
      });
    });

    group('captureFromCamera', () {
      test('should capture from camera and reload history', () async {
        // Arrange
        reset(mockCaptureVM);
        reset(mockRepository);
        reset(mockToastService);
        when(mockCaptureVM.captureFromCamera()).thenAnswer((_) async => {});
        when(mockRepository.init()).thenAnswer((_) async => {});
        when(mockRepository.getAll()).thenAnswer((_) async => []);
        createHomeVM();

        // Act
        await homeVM.captureFromCamera();

        // Assert
        verify(mockCaptureVM.captureFromCamera()).called(1);
        verify(mockRepository.getAll()).called(1);
      });

      test('should handle error when capture fails', () async {
        // Arrange
        reset(mockCaptureVM);
        reset(mockToastService);
        when(
          mockCaptureVM.captureFromCamera(),
        ).thenThrow(Exception('Camera error'));
        createHomeVM();

        // Act
        await homeVM.captureFromCamera();

        // Assert
        verify(
          mockToastService.show(
            argThat(contains('Failed to capture')),
            type: anyNamed('type'),
          ),
        ).called(1);
        verifyNever(mockRepository.getAll());
      });
    });

    group('captureFromGallery', () {
      test('should capture from gallery and reload history', () async {
        // Arrange
        reset(mockCaptureVM);
        reset(mockRepository);
        reset(mockToastService);
        when(mockCaptureVM.captureFromGallery()).thenAnswer((_) async => {});
        when(mockRepository.init()).thenAnswer((_) async => {});
        when(mockRepository.getAll()).thenAnswer((_) async => []);
        createHomeVM();

        // Act
        await homeVM.captureFromGallery();

        // Assert
        verify(mockCaptureVM.captureFromGallery()).called(1);
        verify(mockRepository.getAll()).called(1);
      });

      test('should handle error when gallery pick fails', () async {
        // Arrange
        reset(mockCaptureVM);
        reset(mockToastService);
        when(
          mockCaptureVM.captureFromGallery(),
        ).thenThrow(Exception('Gallery error'));
        createHomeVM();

        // Act
        await homeVM.captureFromGallery();

        // Assert
        verify(
          mockToastService.show(
            argThat(contains('Failed to capture')),
            type: anyNamed('type'),
          ),
        ).called(1);
        verifyNever(mockRepository.getAll());
      });
    });

    group('navigateToDetail', () {
      test('should navigate to detail screen', () async {
        // Arrange
        reset(mockNavigationService);
        final testImage = TestHelpers.createTestProcessedImage(id: 'test-id');
        when(
          mockNavigationService.goTo(
            anyString,
            arguments: anyNamed('arguments'),
          ),
        ).thenAnswer((_) async => {});
        createHomeVM();

        // Act
        await homeVM.navigateToDetail(testImage);

        // Assert - verify goTo was called (arguments is optional, so we verify the route)
        verify(
          mockNavigationService.goTo(
            Routes.detail,
            arguments: argThat(isNotNull, named: 'arguments'),
          ),
        ).called(1);
      });
    });

    group('openPdf', () {
      test('should open PDF for document type', () async {
        // Arrange
        reset(mockFileOpenService);
        final testImage = TestHelpers.createTestProcessedImage(
          type: ProcessingType.document,
        );
        when(mockFileOpenService.open(anyString)).thenAnswer((_) async => {});
        createHomeVM();

        // Act
        await homeVM.openPdf(testImage);

        // Assert
        verify(mockFileOpenService.open(argThat(isA<String>()))).called(1);
      });

      test('should not open PDF for face type', () async {
        // Arrange
        reset(mockFileOpenService);
        final testImage = TestHelpers.createTestProcessedImage(
          type: ProcessingType.face,
        );
        createHomeVM();

        // Act
        await homeVM.openPdf(testImage);

        // Assert - should return early without opening
        verifyNever(mockFileOpenService.open(argThat(isA<String>())));
      });
    });
  });
}
