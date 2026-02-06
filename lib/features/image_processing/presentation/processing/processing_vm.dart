import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import 'package:codeway_image_processing/base/mvvm_base/base_state.dart';
import 'package:codeway_image_processing/base/services/file_storage_service/i_file_storage_service.dart';
import 'package:codeway_image_processing/base/services/image_processing_service/i_image_processing_service.dart';
import 'package:codeway_image_processing/base/services/navigation_service/i_navigation_service.dart';
import 'package:codeway_image_processing/base/services/navigation_service/routes.dart';
import 'package:codeway_image_processing/features/image_processing/data/repositories/i_processed_image_repository.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processed_image.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processing_step.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processing_type.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/processing/processing_model.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/summary_props.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/mixed_review/mixed_review_props.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/document/document_props.dart';
import 'package:codeway_image_processing/features/image_processing/utils/face_batch_metadata.dart';
import 'package:codeway_image_processing/features/image_processing/utils/processed_image_saver.dart';

/// Processing ViewModel.
class ProcessingVM {
  ProcessingVM({
    required IImageProcessingService processingService,
    required IFileStorageService fileStorageService,
    required IProcessedImageRepository repository,
    required INavigationService navigationService,
  }) : _processingService = processingService,
       _navigationService = navigationService,
       _imageSaver = ProcessedImageSaver(
         fileStorageService: fileStorageService,
         repository: repository,
       );

  final IImageProcessingService _processingService;
  final INavigationService _navigationService;
  final ProcessedImageSaver _imageSaver;
  final _state = const BaseState<ProcessingModel>.success(
    ProcessingModel(),
  ).obs;
  BaseState<ProcessingModel> get state => _state.value;
  ProcessingModel get model => _state.value.data ?? const ProcessingModel();

  final _uuid = const Uuid();

  void init(List<Uint8List> images) {
    final items = images
        .map(
          (bytes) => ProcessingItem(
            id: _uuid.v4(),
            originalBytes: bytes,
          ),
        )
        .toList();
    _state.value = BaseState.success(ProcessingModel(items: items));
  }

  Future<void> startProcessing() async {
    if (model.isProcessing || model.items.isEmpty) return;
    _prepareProcessingState();

    final batch = _ProcessingBatch(faceGroupId: _uuid.v4());
    await _processItems(batch);
    _markProcessingCompleted();

    final faceGroupEntity = await _finalizeFaceGroup(batch);
    await _routeToOutcome(
      docCount: batch.docCount,
      faceCount: batch.faceCount,
      documentPages: batch.documentPages,
      faceResults: batch.faceResults,
      documentResults: const <SummaryDocumentPreview>[],
      faceGroupEntity: faceGroupEntity,
    );
  }

  void _prepareProcessingState() {
    _state.value = BaseState.success(
      model.copyWith(
        isProcessing: true,
        isCompleted: false,
        completedCount: 0,
        currentIndex: 0,
        processingStep: ProcessingStep.detectingContent,
      ),
    );
  }

  Future<void> _processItems(_ProcessingBatch batch) async {
    for (var i = 0; i < model.items.length; i++) {
      try {
        await _processItem(i, batch);
      } catch (e) {
        _updateItem(
          i,
          status: ProcessingItemStatus.failed,
          errorMessage: e.toString(),
        );
      }
      _incrementCompleted();
    }
  }

  Future<void> _processItem(int index, _ProcessingBatch batch) async {
    _setCurrentIndex(index);
    _setProcessingStep(ProcessingStep.detectingContent);
    _updateItemStatus(index, ProcessingItemStatus.processing);

    final originalBytes = model.items[index].originalBytes;
    final type = await _processingService.detectContentType(originalBytes);
    _updateItem(index, type: type);

    if (type.isFace) {
      await _processFaceItem(index, originalBytes, batch);
      return;
    }
    await _processDocumentItem(index, originalBytes, batch);
  }

  Future<void> _processFaceItem(
    int index,
    Uint8List originalBytes,
    _ProcessingBatch batch,
  ) async {
    _setProcessingStep(ProcessingStep.detectingFaces);
    final processed = await _processingService.detectAndProcessFaces(
      originalBytes,
    );
    _setProcessingStep(ProcessingStep.saving);
    final entity = await _imageSaver.save(
      originalBytes: originalBytes,
      processedBytes: processed,
      type: ProcessingType.face,
      isPdf: false,
      metadata: FaceBatchMetadata.item(batch.faceGroupId),
    );
    batch.faceCount += 1;
    batch.faceEntities.add(entity);
    batch.faceResults.add(
      SummaryFacePreview(
        image: entity,
        originalBytes: originalBytes,
        processedBytes: processed,
      ),
    );
    _updateItem(
      index,
      status: ProcessingItemStatus.success,
      type: ProcessingType.face,
      result: entity,
      errorMessage: null,
    );
  }

  Future<void> _processDocumentItem(
    int index,
    Uint8List originalBytes,
    _ProcessingBatch batch,
  ) async {
    _setProcessingStep(ProcessingStep.processingDocument);
    final processed = await _processingService.processDocument(
      originalBytes,
    );
    batch.docCount += 1;
    batch.documentPages.add(
      DocumentSeedPage(
        originalBytes: originalBytes,
        processedBytes: processed,
      ),
    );
    _updateItem(
      index,
      status: ProcessingItemStatus.success,
      type: ProcessingType.document,
      result: null,
      errorMessage: null,
    );
  }

  void _markProcessingCompleted() {
    _state.value = BaseState.success(
      model.copyWith(
        isProcessing: false,
        isCompleted: true,
        currentIndex: -1,
        processingStep: ProcessingStep.done,
      ),
    );
  }

  Future<ProcessedImage?> _finalizeFaceGroup(_ProcessingBatch batch) async {
    if (batch.faceEntities.length > 1) {
      return _saveFaceGroupEntity(
        groupId: batch.faceGroupId,
        faces: batch.faceEntities,
      );
    }
    await _stripFaceBatchMetadataIfSingle(
      batch.faceEntities,
      batch.faceResults,
    );
    return null;
  }

  void _setCurrentIndex(int index) {
    _state.value = BaseState.success(model.copyWith(currentIndex: index));
  }

  void _setProcessingStep(ProcessingStep step) {
    _state.value = BaseState.success(model.copyWith(processingStep: step));
  }

  void _incrementCompleted() {
    _state.value = BaseState.success(
      model.copyWith(completedCount: model.completedCount + 1),
    );
  }

  void _updateItemStatus(int index, ProcessingItemStatus status) {
    _updateItem(index, status: status);
  }

  void _updateItem(
    int index, {
    ProcessingItemStatus? status,
    ProcessingType? type,
    ProcessedImage? result,
    String? errorMessage,
  }) {
    if (index < 0 || index >= model.items.length) return;
    final items = List<ProcessingItem>.from(model.items);
    items[index] = items[index].copyWith(
      status: status,
      type: type,
      result: result,
      errorMessage: errorMessage,
    );
    _state.value = BaseState.success(model.copyWith(items: items));
  }

  Future<void> _routeToOutcome({
    required int docCount,
    required int faceCount,
    required List<DocumentSeedPage> documentPages,
    required List<SummaryFacePreview> faceResults,
    required List<SummaryDocumentPreview> documentResults,
    required ProcessedImage? faceGroupEntity,
  }) async {
    final shouldUseDocumentFlow =
        documentPages.isNotEmpty && faceCount == 0 && docCount > 0;
    final shouldUseMixedReview =
        documentPages.isNotEmpty && faceCount > 0 && docCount > 0;

    if (shouldUseDocumentFlow) {
      await _navigationService.replaceWith(
        Routes.multiPage,
        arguments: DocumentProps(pages: documentPages),
      );
      return;
    }

    if (shouldUseMixedReview) {
      await _navigationService.replaceWith(
        Routes.mixedReview,
        arguments: MixedReviewProps(
          pages: documentPages,
          faces: faceResults,
          faceGroupId: faceGroupEntity?.id,
          faceGroupEntity: faceGroupEntity,
        ),
      );
      return;
    }

    await _navigationService.replaceWith(
      Routes.summary,
      arguments: SummaryProps(
        documents: documentResults,
        faces: faceResults,
        faceGroupEntity: faceGroupEntity,
      ),
    );
  }

  Future<ProcessedImage> _saveFaceGroupEntity({
    required String groupId,
    required List<ProcessedImage> faces,
  }) async {
    final first = faces.first;
    final totalSize =
        faces.fold<int>(0, (sum, item) => sum + (item.fileSize ?? 0));
    final entity = ProcessedImage(
      id: groupId,
      processingType: ProcessingType.faceBatch,
      originalPath: first.originalPath,
      processedPath: first.processedPath,
      thumbnailPath: first.thumbnailPath,
      fileSize: totalSize,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      metadata: FaceBatchMetadata.group(
        faces.map((f) => f.id).toList(),
      ),
    );
    await _imageSaver.persist(entity);
    return entity;
  }

  Future<void> _stripFaceBatchMetadataIfSingle(
    List<ProcessedImage> faceEntities,
    List<SummaryFacePreview> faceResults,
  ) async {
    if (faceEntities.length != 1) return;
    final single = faceEntities.first;
    if (!FaceBatchMetadata.isBatchItem(single.metadata)) return;
    final updated = ProcessedImage(
      id: single.id,
      processingType: single.processingType,
      originalPath: single.originalPath,
      processedPath: single.processedPath,
      thumbnailPath: single.thumbnailPath,
      fileSize: single.fileSize,
      createdAt: single.createdAt,
      metadata: null,
    );
    await _imageSaver.persist(updated);
    faceEntities[0] = updated;
    if (faceResults.isNotEmpty) {
      final preview = faceResults.first;
      faceResults[0] = SummaryFacePreview(
        image: updated,
        originalBytes: preview.originalBytes,
        processedBytes: preview.processedBytes,
      );
    }
  }
}

class _ProcessingBatch {
  _ProcessingBatch({required this.faceGroupId});

  final String faceGroupId;
  final List<DocumentSeedPage> documentPages = [];
  final List<SummaryFacePreview> faceResults = [];
  final List<ProcessedImage> faceEntities = [];
  int docCount = 0;
  int faceCount = 0;
}
