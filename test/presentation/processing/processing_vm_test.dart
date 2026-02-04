import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';

import 'package:codeway_image_processing/base/services/toast_service/i_toast_service.dart';
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
  late MockIToastService mockToastService;

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
    mockToastService = MockIToastService();

    Get.put<IToastService>(mockToastService);
    // Ensure mocks are in clean state
    reset(mockProcessingService);
    reset(mockFileStorageService);
    reset(mockRepository);
    reset(mockNavigationService);
    reset(mockToastService);
  });

  tearDown(() {
    Get.reset();
  });

  group('ProcessingVM', () {
    group('init', () {
      test('should initialize with image bytes', () {
        // Arrange
        final testBytes = TestHelpers.createTestImageBytes();
        createProcessingVM();

        // Act
        processingVM.init(testBytes);

        // Assert
        expect(processingVM.model.originalImage, testBytes);
        expect(processingVM.state.isSuccess, true);
      });

      test('should handle null image bytes', () {
        // Arrange
        createProcessingVM();
        // Act
        processingVM.init(null);

        // Assert
        expect(processingVM.model.originalImage, isNull);
      });
    });

    group('startProcessing', () {
      test('should start processing when image bytes exist', () async {
        // Arrange
        reset(mockProcessingService);
        reset(mockFileStorageService);
        reset(mockRepository);
        reset(mockNavigationService);
        final testBytes = TestHelpers.createTestImageBytes();
        createProcessingVM();
        processingVM.init(testBytes);
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
        when(mockNavigationService.goBack()).thenReturn(null);
        when(
          mockNavigationService.goTo(
            anyString,
            arguments: anyNamed('arguments'),
          ),
        ).thenAnswer((_) async => {});

        // Act
        await processingVM.startProcessing();

        // Assert
        verify(mockProcessingService.detectContentType(testBytes)).called(1);
      });

      test('should not process when image bytes are null', () async {
        // Arrange
        reset(mockProcessingService);
        createProcessingVM();
        processingVM.init(null);

        // Act
        await processingVM.startProcessing();

        // Assert
        verifyNever(mockProcessingService.detectContentType(anyUint8List));
      });
    });

    group('processImage', () {
      test('should process face image successfully', () async {
        // Arrange
        reset(mockProcessingService);
        reset(mockFileStorageService);
        reset(mockRepository);
        reset(mockNavigationService);
        final testBytes = TestHelpers.createTestImageBytes();
        createProcessingVM();
        processingVM.init(testBytes);
        when(
          mockProcessingService.detectContentType(testBytes),
        ).thenAnswer((_) async => ProcessingType.face);
        when(
          mockProcessingService.detectAndProcessFaces(testBytes),
        ).thenAnswer((_) async => testBytes);
        when(
          mockFileStorageService.saveProcessedImage(anyUint8List, anyString),
        ).thenAnswer((_) async => '/test/original.jpg');
        when(
          mockFileStorageService.saveProcessedImage(anyUint8List, anyString),
        ).thenAnswer((_) async => '/test/processed.jpg');
        when(
          mockFileStorageService.saveThumbnail(anyUint8List, anyString),
        ).thenAnswer((_) async => '/test/thumb.jpg');
        when(mockRepository.init()).thenAnswer((_) async => {});
        when(
          mockRepository.add(anyProcessedImage),
        ).thenAnswer((_) async => 'test-id');
        when(mockNavigationService.goBack()).thenReturn(null);
        when(
          mockNavigationService.goTo(
            anyString,
            arguments: anyNamed('arguments'),
          ),
        ).thenAnswer((_) async => {});

        // Act
        await processingVM.processImage();

        // Assert
        verify(mockProcessingService.detectContentType(testBytes)).called(1);
        verify(
          mockProcessingService.detectAndProcessFaces(testBytes),
        ).called(1);
      });

      test('should process document image successfully', () async {
        // Arrange
        reset(mockProcessingService);
        reset(mockFileStorageService);
        reset(mockRepository);
        reset(mockNavigationService);
        final testBytes = TestHelpers.createTestImageBytes();
        final processedImageBytes = Uint8List.fromList([10, 20, 30]);
        final pdfBytes = Uint8List.fromList([40, 50, 60]);
        createProcessingVM();
        processingVM.init(testBytes);
        when(
          mockProcessingService.detectContentType(testBytes),
        ).thenAnswer((_) async => ProcessingType.document);
        when(
          mockProcessingService.processDocument(testBytes),
        ).thenAnswer((_) async => processedImageBytes);
        // createPdfFromImage is called with processedImageBytes and a title string
        when(
          mockProcessingService.createPdfFromImage(
            argThat(isA<Uint8List>()),
            argThat(isA<String>()),
          ),
        ).thenAnswer((_) async => pdfBytes);
        when(
          mockFileStorageService.saveProcessedImage(anyUint8List, anyString),
        ).thenAnswer((_) async => '/test/original.jpg');
        when(
          mockFileStorageService.savePdf(anyUint8List, anyString),
        ).thenAnswer((_) async => '/test/processed.pdf');
        when(
          mockFileStorageService.saveThumbnail(anyUint8List, anyString),
        ).thenAnswer((_) async => '/test/thumb.jpg');
        when(mockRepository.init()).thenAnswer((_) async => {});
        when(
          mockRepository.add(anyProcessedImage),
        ).thenAnswer((_) async => 'test-id');
        when(mockNavigationService.goBack()).thenReturn(null);
        when(
          mockNavigationService.goTo(
            anyString,
            arguments: anyNamed('arguments'),
          ),
        ).thenAnswer((_) async => {});

        // Act
        await processingVM.processImage();

        // Assert
        verify(mockProcessingService.detectContentType(testBytes)).called(1);
        verify(mockProcessingService.processDocument(testBytes)).called(1);
        verify(
          mockProcessingService.createPdfFromImage(
            argThat(isA<Uint8List>()),
            argThat(isA<String>()),
          ),
        ).called(1);
      });

      test('should handle face detection error', () async {
        // Arrange
        reset(mockProcessingService);
        reset(mockNavigationService);
        reset(mockToastService);
        final testBytes = TestHelpers.createTestImageBytes();
        createProcessingVM();
        processingVM.init(testBytes);
        when(
          mockProcessingService.detectContentType(testBytes),
        ).thenAnswer((_) async => ProcessingType.face);
        when(
          mockProcessingService.detectAndProcessFaces(testBytes),
        ).thenThrow(Exception('No faces detected'));
        when(mockNavigationService.goBack()).thenReturn(null);

        // Act
        await processingVM.processImage();

        // Assert
        expect(processingVM.state.isError, true);
        verify(
          mockToastService.show(argThat(contains('No faces detected'))),
        ).called(1);
        verify(mockNavigationService.goBack()).called(1);
      });

      test('should handle save error', () async {
        // Arrange
        reset(mockProcessingService);
        reset(mockFileStorageService);
        reset(mockToastService);
        final testBytes = TestHelpers.createTestImageBytes();
        createProcessingVM();
        processingVM.init(testBytes);
        when(
          mockProcessingService.detectContentType(testBytes),
        ).thenAnswer((_) async => ProcessingType.face);
        when(
          mockProcessingService.detectAndProcessFaces(testBytes),
        ).thenAnswer((_) async => testBytes);
        when(
          mockFileStorageService.saveProcessedImage(anyUint8List, anyString),
        ).thenThrow(Exception('Save failed'));

        // Act
        await processingVM.processImage();

        // Assert
        expect(processingVM.state.isError, true);
        verify(
          mockToastService.show(argThat(contains('Failed to save'))),
        ).called(1);
      });
    });
  });
}
