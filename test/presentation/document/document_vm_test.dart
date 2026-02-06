import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/mockito.dart';

import 'package:codeway_image_processing/base/services/navigation_service/routes.dart';
import 'package:codeway_image_processing/base/services/toast_service/i_toast_service.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processing_type.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/document/document_props.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/document/document_vm.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';

import '../../helpers/mocks.dart';

// Helper to use any with proper typing
dynamic anyString = any;
dynamic anyUint8List = any;

void main() {
  late DocumentVM documentVM;
  late MockIImageProcessingService mockProcessingService;
  late MockIImagePickerService mockImagePickerService;
  late MockIFileOpenService mockFileOpenService;
  late MockIFileStorageService mockFileStorageService;
  late MockIProcessedImageRepository mockRepository;
  late MockINavigationService mockNavigationService;
  late MockIToastService mockToastService;

  void createDocumentVM() {
    documentVM = DocumentVM(
      processingService: mockProcessingService,
      imagePickerService: mockImagePickerService,
      fileOpenService: mockFileOpenService,
      fileStorageService: mockFileStorageService,
      repository: mockRepository,
      navigationService: mockNavigationService,
    );
  }

  setUp(() {
    Get.testMode = true;
    Get.reset();
    mockProcessingService = MockIImageProcessingService();
    mockImagePickerService = MockIImagePickerService();
    mockFileOpenService = MockIFileOpenService();
    mockFileStorageService = MockIFileStorageService();
    mockRepository = MockIProcessedImageRepository();
    mockNavigationService = MockINavigationService();
    mockToastService = MockIToastService();

    Get.put<IToastService>(mockToastService);
  });

  tearDown(() {
    Get.reset();
  });

  DocumentProps seedProps() {
    final bytes = TestHelpers.createTestImageBytes();
    return DocumentProps(
      pages: [DocumentSeedPage(originalBytes: bytes, processedBytes: bytes)],
    );
  }

  group('DocumentVM', () {
    test('init should populate pages and select first', () {
      createDocumentVM();

      documentVM.init(seedProps());

      expect(documentVM.model.pages.length, 1);
      expect(documentVM.model.selectedIndex, 0);
      expect(documentVM.model.hasUnsavedChanges, true);
    });

    test('addPage should add document page', () async {
      createDocumentVM();
      documentVM.init(seedProps());

      final newBytes = Uint8List.fromList([10, 20, 30]);
      final processedBytes = Uint8List.fromList([40, 50, 60]);
      when(
        mockImagePickerService.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        ),
      ).thenAnswer((_) async => newBytes);
      when(
        mockProcessingService.detectContentType(newBytes),
      ).thenAnswer((_) async => ProcessingType.document);
      when(
        mockProcessingService.processDocument(newBytes),
      ).thenAnswer((_) async => processedBytes);

      await documentVM.addPage(ImageSource.camera);

      expect(documentVM.model.pages.length, 2);
      expect(documentVM.model.selectedIndex, 1);
      verify(
        mockToastService.show(AppStrings.pageAdded, type: anyNamed('type')),
      ).called(1);
    });

    test('addPage should reject face images', () async {
      createDocumentVM();
      documentVM.init(seedProps());

      final newBytes = Uint8List.fromList([10, 20, 30]);
      when(
        mockImagePickerService.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        ),
      ).thenAnswer((_) async => newBytes);
      when(
        mockProcessingService.detectContentType(newBytes),
      ).thenAnswer((_) async => ProcessingType.face);

      await documentVM.addPage(ImageSource.camera);

      expect(documentVM.model.pages.length, 1);
      verify(
        mockToastService.show(
          AppStrings.multiPageDocumentsOnly,
          type: anyNamed('type'),
        ),
      ).called(1);
    });

    test(
      'addPagesFromGallery should add documents and warn on faces',
      () async {
        createDocumentVM();
        documentVM.init(seedProps());

        final faceBytes = Uint8List.fromList([1, 1, 1]);
        final docBytes = Uint8List.fromList([2, 2, 2]);
        final processedDoc = Uint8List.fromList([3, 3, 3]);
        when(
          mockImagePickerService.pickMultiImages(imageQuality: 85),
        ).thenAnswer((_) async => [faceBytes, docBytes]);

        var call = 0;
        when(mockProcessingService.detectContentType(anyUint8List)).thenAnswer(
          (_) async =>
              call++ == 0 ? ProcessingType.face : ProcessingType.document,
        );
        when(
          mockProcessingService.processDocument(docBytes),
        ).thenAnswer((_) async => processedDoc);

        await documentVM.addPagesFromGallery();

        expect(documentVM.model.pages.length, 2);
        verify(
          mockToastService.show(AppStrings.pageAdded, type: anyNamed('type')),
        ).called(1);
        verify(
          mockToastService.show(
            AppStrings.multiPageDocumentsOnly,
            type: anyNamed('type'),
          ),
        ).called(1);
      },
    );

    test('exportPdf should save and open PDF then navigate home', () async {
      createDocumentVM();
      documentVM.init(seedProps());

      final pdfBytes = Uint8List.fromList([9, 9, 9]);
      when(
        mockProcessingService.createPdfFromImages(any, any),
      ).thenAnswer((_) async => pdfBytes);
      when(
        mockFileStorageService.saveProcessedImage(any, any),
      ).thenAnswer((_) async => '/test/original.jpg');
      when(
        mockFileStorageService.savePdf(any, any),
      ).thenAnswer((_) async => '/test/processed.pdf');
      when(
        mockFileStorageService.saveThumbnail(any, any),
      ).thenAnswer((_) async => '/test/thumb.jpg');
      when(mockRepository.init()).thenAnswer((_) async => {});
      when(mockRepository.add(any)).thenAnswer((_) async => 'id');
      when(mockFileOpenService.open(any)).thenAnswer((_) async => {});
      when(
        mockNavigationService.goBackUntil(Routes.home),
      ).thenAnswer((_) async => {});

      expect(documentVM.model.pages, isNotEmpty);
      expect(documentVM.model.isSaving, false);

      await documentVM.exportPdf();

      verify(mockFileStorageService.savePdf(any, any)).called(1);
      verify(mockFileOpenService.open(any)).called(1);
      verify(mockNavigationService.goBackUntil(Routes.home)).called(1);
    });
  });
}
