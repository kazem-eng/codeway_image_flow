import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';

import 'package:codeway_image_processing/base/services/navigation_service/routes.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processing_type.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/processing/processing_vm.dart';

import '../../helpers/mocks.dart';

// Helper to use any with proper typing
dynamic anyString = any;
dynamic anyUint8List = any;
dynamic anyProcessedImage = any;

void main() {
  late ProcessingVM processingVM;
  late MockIImageProcessingService mockProcessingService;
  late MockIFileStorageService mockFileStorageService;
  late MockIProcessedImageRepository mockRepository;
  late MockINavigationService mockNavigationService;

  void createProcessingVM() {
    processingVM = ProcessingVM(
      processingService: mockProcessingService,
      fileStorageService: mockFileStorageService,
      repository: mockRepository,
      navigationService: mockNavigationService,
    );
  }

  setUp(() {
    Get.testMode = true;
    Get.reset();
    mockProcessingService = MockIImageProcessingService();
    mockFileStorageService = MockIFileStorageService();
    mockRepository = MockIProcessedImageRepository();
    mockNavigationService = MockINavigationService();

    reset(mockProcessingService);
    reset(mockFileStorageService);
    reset(mockRepository);
    reset(mockNavigationService);
  });

  tearDown(() {
    Get.reset();
  });

  group('ProcessingVM', () {
    group('init', () {
      test('should initialize with image list', () {
        // Arrange
        final testBytes = TestHelpers.createTestImageBytes();
        createProcessingVM();

        // Act
        processingVM.init([testBytes]);

        // Assert
        expect(processingVM.model.items.length, 1);
        expect(processingVM.model.items.first.originalBytes, testBytes);
        expect(processingVM.state.isSuccess, true);
      });
    });

    group('startProcessing', () {
      test('should process face images and navigate to summary', () async {
        // Arrange
        final testBytes = TestHelpers.createTestImageBytes();
        createProcessingVM();
        processingVM.init([testBytes]);
        when(
          mockProcessingService.detectContentType(testBytes),
        ).thenAnswer((_) async => ProcessingType.face);
        when(
          mockProcessingService.detectAndProcessFaces(testBytes),
        ).thenAnswer((_) async => testBytes);
        when(
          mockFileStorageService.saveProcessedImage(anyUint8List, anyString),
        ).thenAnswer((_) async => '/test/path.jpg');
        when(
          mockFileStorageService.saveThumbnail(anyUint8List, anyString),
        ).thenAnswer((_) async => '/test/thumb.jpg');
        when(mockRepository.init()).thenAnswer((_) async => {});
        when(
          mockRepository.add(anyProcessedImage),
        ).thenAnswer((_) async => 'test-id');
        when(
          mockNavigationService.replaceWith(
            anyString,
            arguments: anyNamed('arguments'),
          ),
        ).thenAnswer((_) async => {});

        // Act
        await processingVM.startProcessing();

        // Assert
        verify(mockProcessingService.detectContentType(testBytes)).called(1);
        verify(mockProcessingService.detectAndProcessFaces(testBytes)).called(1);
        verify(
          mockNavigationService.replaceWith(
            Routes.summary,
            arguments: anyNamed('arguments'),
          ),
        ).called(1);
      });

      test('should process document images and navigate to multi-page', () async {
        // Arrange
        final testBytes = TestHelpers.createTestImageBytes();
        final processedImageBytes = Uint8List.fromList([10, 20, 30]);
        createProcessingVM();
        processingVM.init([testBytes]);
        when(
          mockProcessingService.detectContentType(testBytes),
        ).thenAnswer((_) async => ProcessingType.document);
        when(
          mockProcessingService.processDocument(testBytes),
        ).thenAnswer((_) async => processedImageBytes);
        when(
          mockNavigationService.replaceWith(
            anyString,
            arguments: anyNamed('arguments'),
          ),
        ).thenAnswer((_) async => {});

        // Act
        await processingVM.startProcessing();

        // Assert
        verify(mockProcessingService.detectContentType(testBytes)).called(1);
        verify(mockProcessingService.processDocument(testBytes)).called(1);
        verify(
          mockNavigationService.replaceWith(
            Routes.multiPage,
            arguments: anyNamed('arguments'),
          ),
        ).called(1);
      });

      test('should skip processing when no items', () async {
        // Arrange
        createProcessingVM();

        // Act
        await processingVM.startProcessing();

        // Assert
        verifyNever(mockProcessingService.detectContentType(anyUint8List));
      });
    });
  });
}
