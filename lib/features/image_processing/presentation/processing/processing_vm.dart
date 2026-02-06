import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import 'package:codeway_image_processing/base/mvvm_base/base_state.dart';
import 'package:codeway_image_processing/base/services/file_storage_service/file_storage_service.dart';
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

/// Processing ViewModel.
class ProcessingVM {
  ProcessingVM({
    required IImageProcessingService processingService,
    required IFileStorageService fileStorageService,
    required IProcessedImageRepository repository,
    required INavigationService navigationService,
  }) : _processingService = processingService,
       _fileStorageService = fileStorageService,
       _repository = repository,
       _navigationService = navigationService;

  final IImageProcessingService _processingService;
  final IFileStorageService _fileStorageService;
  final IProcessedImageRepository _repository;
  final INavigationService _navigationService;
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
    _state.value = BaseState.success(
      model.copyWith(
        isProcessing: true,
        isCompleted: false,
        completedCount: 0,
        currentIndex: 0,
        processingStep: ProcessingStep.detectingContent,
      ),
    );

    final documentPages = <DocumentSeedPage>[];
    final faceResults = <SummaryFacePreview>[];
    final faceEntities = <ProcessedImage>[];
    var docCount = 0;
    var faceCount = 0;
    final faceGroupId = _uuid.v4();

    for (var i = 0; i < model.items.length; i++) {
      _setCurrentIndex(i);
      _setProcessingStep(ProcessingStep.detectingContent);
      _updateItemStatus(i, ProcessingItemStatus.processing);
      try {
        final originalBytes = model.items[i].originalBytes;
        final type = await _processingService.detectContentType(originalBytes);
        _updateItem(i, type: type);
        if (type.isFace) {
          _setProcessingStep(ProcessingStep.detectingFaces);
          final processed = await _processingService.detectAndProcessFaces(
            originalBytes,
          );
          _setProcessingStep(ProcessingStep.saving);
          faceCount += 1;
          final entity = await _saveResult(
            originalBytes: originalBytes,
            processedBytes: processed,
            type: ProcessingType.face,
            isPdf: false,
            metadata: FaceBatchMetadata.item(faceGroupId),
          );
          faceEntities.add(entity);
          faceResults.add(
            SummaryFacePreview(
              image: entity,
              originalBytes: originalBytes,
              processedBytes: processed,
            ),
          );
          _updateItem(
            i,
            status: ProcessingItemStatus.success,
            type: type,
            result: entity,
            errorMessage: null,
          );
        } else {
          _setProcessingStep(ProcessingStep.processingDocument);
          final processed = await _processingService.processDocument(
            originalBytes,
          );
          docCount += 1;
          documentPages.add(
            DocumentSeedPage(
              originalBytes: originalBytes,
              processedBytes: processed,
            ),
          );
          _updateItem(
            i,
            status: ProcessingItemStatus.success,
            type: type,
            result: null,
            errorMessage: null,
          );
        }
      } catch (e) {
        _updateItem(
          i,
          status: ProcessingItemStatus.failed,
          errorMessage: e.toString(),
        );
      }
      _incrementCompleted();
    }

    _state.value = BaseState.success(
      model.copyWith(
        isProcessing: false,
        isCompleted: true,
        currentIndex: -1,
        processingStep: ProcessingStep.done,
      ),
    );

    ProcessedImage? faceGroupEntity;
    if (faceEntities.length > 1) {
      faceGroupEntity = await _saveFaceGroupEntity(
        groupId: faceGroupId,
        faces: faceEntities,
      );
    } else {
      await _stripFaceBatchMetadataIfSingle(faceEntities, faceResults);
    }

    final documentResults = <SummaryDocumentPreview>[];

    await _routeToOutcome(
      docCount: docCount,
      faceCount: faceCount,
      documentPages: documentPages,
      faceResults: faceResults,
      documentResults: documentResults,
      faceGroupEntity: faceGroupEntity,
    );
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

  Future<ProcessedImage> _saveResult({
    required Uint8List originalBytes,
    required Uint8List processedBytes,
    required ProcessingType type,
    required bool isPdf,
    String? metadata,
  }) async {
    try {
      final id = _uuid.v4();
      final savedFiles = await _saveFiles(
        id: id,
        originalBytes: originalBytes,
        processedBytes: processedBytes,
        type: type,
        isPdf: isPdf,
      );
      final entity = _createProcessedImageEntity(
        id: id,
        type: type,
        savedFiles: savedFiles,
        processedBytes: processedBytes,
        metadata: metadata,
      );
      await _persistEntity(entity);
      return entity;
    } catch (e) {
      rethrow;
    }
  }

  Future<_SavedFiles> _saveFiles({
    required String id,
    required Uint8List originalBytes,
    required Uint8List processedBytes,
    required ProcessingType type,
    required bool isPdf,
  }) async {
    final directory = type.isFace
        ? FileStorageService.facesDir
        : FileStorageService.documentsDir;

    String? originalPath;
    String? processedPath;
    String? thumbnailPath;

    try {
      originalPath = await _fileStorageService.saveProcessedImage(
        originalBytes,
        '$directory/${id}_original.jpg',
      );

      processedPath = isPdf
          ? await _fileStorageService.savePdf(
              processedBytes,
              '$directory/${id}_processed.pdf',
            )
          : await _fileStorageService.saveProcessedImage(
              processedBytes,
              '$directory/${id}_processed.jpg',
            );

      thumbnailPath = await _fileStorageService.saveThumbnail(
        originalBytes,
        '${id}_thumb.jpg',
      );

      return _SavedFiles(
        originalPath: originalPath,
        processedPath: processedPath,
        thumbnailPath: thumbnailPath,
      );
    } catch (e) {
      if (originalPath != null) {
        try {
          await _fileStorageService.deleteFile(originalPath);
        } catch (_) {}
      }
      if (processedPath != null) {
        try {
          await _fileStorageService.deleteFile(processedPath);
        } catch (_) {}
      }
      if (thumbnailPath != null) {
        try {
          await _fileStorageService.deleteFile(thumbnailPath);
        } catch (_) {}
      }
      rethrow;
    }
  }

  ProcessedImage _createProcessedImageEntity({
    required String id,
    required ProcessingType type,
    required _SavedFiles savedFiles,
    required Uint8List processedBytes,
    String? metadata,
  }) {
    return ProcessedImage(
      id: id,
      processingType: type,
      originalPath: savedFiles.originalPath,
      processedPath: savedFiles.processedPath,
      thumbnailPath: savedFiles.thumbnailPath,
      fileSize: processedBytes.length,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      metadata: metadata,
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
    await _persistEntity(entity);
    return entity;
  }

  Future<void> _persistEntity(ProcessedImage entity) async {
    await _repository.init();
    await _repository.add(entity);
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
    await _repository.init();
    await _repository.add(updated);
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

class _SavedFiles {
  const _SavedFiles({
    required this.originalPath,
    required this.processedPath,
    required this.thumbnailPath,
  });

  final String originalPath;
  final String processedPath;
  final String thumbnailPath;
}
