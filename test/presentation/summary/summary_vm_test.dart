import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';

import 'package:codeway_image_processing/base/services/toast_service/i_toast_service.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processed_image.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processing_type.dart';
import 'package:codeway_image_processing/features/image_processing/domain/utils/face_batch_metadata.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/summary_props.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/summary_vm.dart';

import '../../helpers/mocks.dart';

// Helper to use any with proper typing
dynamic anyString = any;
dynamic anyUint8List = any;

void main() {
  late SummaryVM summaryVM;
  late MockINavigationService mockNavigationService;
  late MockIProcessedImageRepository mockRepository;
  late MockIFileStorageService mockFileStorageService;
  late MockIFileOpenService mockFileOpenService;
  late MockIToastService mockToastService;

  void createSummaryVM({bool closeOnEmpty = true}) {
    summaryVM = SummaryVM(
      navigationService: mockNavigationService,
      repository: mockRepository,
      fileStorageService: mockFileStorageService,
      fileOpenService: mockFileOpenService,
      closeOnEmpty: closeOnEmpty,
    );
  }

  ProcessedImage faceEntity(String id) {
    return ProcessedImage(
      id: id,
      processingType: ProcessingType.face,
      originalPath: '/test/$id-original.jpg',
      processedPath: '/test/$id-processed.jpg',
      thumbnailPath: '/test/$id-thumb.jpg',
      fileSize: 10,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      metadata: null,
    );
  }

  setUp(() {
    Get.testMode = true;
    Get.reset();
    mockNavigationService = MockINavigationService();
    mockRepository = MockIProcessedImageRepository();
    mockFileStorageService = MockIFileStorageService();
    mockFileOpenService = MockIFileOpenService();
    mockToastService = MockIToastService();

    Get.put<IToastService>(mockToastService);
  });

  tearDown(() {
    Get.reset();
  });

  group('SummaryVM', () {
    test('init should use provided faces without repository lookup', () async {
      createSummaryVM();

      final face = faceEntity('face-1');
      final props = SummaryProps(
        faces: [
          SummaryFacePreview(
            image: face,
            originalBytes: Uint8List.fromList([1]),
            processedBytes: Uint8List.fromList([2]),
          ),
        ],
        documents: const [],
      );

      await summaryVM.init(props);

      expect(summaryVM.model.faces.length, 1);
      verifyNever(mockRepository.getById(anyString));
    });

    test('init should load faces from face group metadata', () async {
      createSummaryVM();

      final faceId = 'face-1';
      final group = ProcessedImage(
        id: 'group-1',
        processingType: ProcessingType.faceBatch,
        originalPath: '/test/original.jpg',
        processedPath: '/test/processed.jpg',
        thumbnailPath: '/test/thumb.jpg',
        fileSize: 20,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        metadata: FaceBatchMetadata.group([faceId]),
      );
      final face = faceEntity(faceId);

      when(mockRepository.init()).thenAnswer((_) async => {});
      when(mockRepository.getById('group-1')).thenAnswer((_) async => group);
      when(mockRepository.getById(faceId)).thenAnswer((_) async => face);
      when(
        mockFileStorageService.loadImage(face.processedPath),
      ).thenAnswer((_) async => Uint8List.fromList([1]));
      when(
        mockFileStorageService.loadImage(face.originalPath),
      ).thenAnswer((_) async => Uint8List.fromList([2]));

      final props = SummaryProps(
        faces: const [],
        documents: const [],
        faceGroupId: 'group-1',
      );

      await summaryVM.init(props);

      expect(summaryVM.model.faces.length, 1);
      expect(summaryVM.model.faceGroupId, 'group-1');
    });

    test(
      'deleteFaceAt should clear faces without navigating when closeOnEmpty is false',
      () async {
        createSummaryVM(closeOnEmpty: false);

        final face = faceEntity('face-1');
        final props = SummaryProps(
          faces: [
            SummaryFacePreview(
              image: face,
              originalBytes: Uint8List.fromList([1]),
              processedBytes: Uint8List.fromList([2]),
            ),
          ],
          documents: const [],
        );

        await summaryVM.init(props);

        when(mockRepository.init()).thenAnswer((_) async => {});
        when(
          mockFileStorageService.deleteProcessedImageFiles(face),
        ).thenAnswer((_) async => {});
        when(mockRepository.delete(face.id)).thenAnswer((_) async => {});

        await summaryVM.deleteFaceAt(0);

        expect(summaryVM.model.faces.isEmpty, true);
        verifyNever(mockNavigationService.goBackUntil(anyString));
      },
    );
  });
}
