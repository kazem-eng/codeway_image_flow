import 'dart:async';
import 'dart:typed_data';

import 'package:codeway_image_processing/base/base_exception.dart';
import 'package:codeway_image_processing/base/mvvm_base/base_state.dart';
import 'package:codeway_image_processing/base/services/file_storage_service/file_storage_service.dart';
import 'package:codeway_image_processing/base/services/file_storage_service/i_file_storage_service.dart';
import 'package:codeway_image_processing/base/services/image_processing_service/i_image_processing_service.dart';
import 'package:codeway_image_processing/base/services/navigation_service/i_navigation_service.dart';
import 'package:codeway_image_processing/base/services/navigation_service/routes.dart';
import 'package:codeway_image_processing/base/services/toast_service/i_toast_service.dart';
import 'package:codeway_image_processing/features/image_processing/data/repositories/i_processed_image_repository.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processed_image.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processing_step.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processing_type.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/multi_page/multi_page_props.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/processing/processing_model.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/result/result_props.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

/// Processing screen ViewModel. Props passed via [init] from view; call [startProcessing] after.
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
  final IToastService _toastService = Get.find<IToastService>();

  final _state = const BaseState<ProcessingModel>.loading().obs;
  BaseState<ProcessingModel> get state => _state.value;

  ProcessingModel get model => _state.value.data ?? const ProcessingModel();

  final _uuid = const Uuid();

  /// Call from view's [initViewModel] with props (e.g. vm.init(imageBytes); vm.startProcessing()).
  /// Stores the image bytes in the model for reactive access.
  void init(Uint8List? imageBytes) {
    if (imageBytes != null) {
      _state.value = BaseState.success(
        ProcessingModel(originalImage: imageBytes),
      );
    }
  }

  /// Call from view's [initViewModel] after [init] (e.g. vm.init(imageBytes); vm.startProcessing()).
  Future<void> startProcessing() async {
    final bytes = model.originalImage;
    if (bytes != null) await processImage();
  }

  Future<void> processImage() async {
    final imageBytes = model.originalImage;
    if (imageBytes == null) return;

    _state.value = BaseState.success(
      model.copyWith(
        processingStep: ProcessingStep.detectingContent,
        progress: 0.2,
      ),
    );

    final type = await _processingService.detectContentType(imageBytes);
    final current = _state.value.data!;
    final isFace = type.isFace;
    _state.value = BaseState.success(
      current.copyWith(
        processingType: type,
        processingStep: isFace
            ? ProcessingStep.detectingFaces
            : ProcessingStep.detectingDocument,
        progress: 0.3,
      ),
    );

    if (isFace) {
      await _processFace(imageBytes);
    } else {
      await _processDocument(imageBytes);
    }
  }

  Future<void> _processFace(Uint8List imageBytes) async {
    final current = _state.value.data!;
    _state.value = BaseState.success(
      current.copyWith(
        processingStep: ProcessingStep.detectingFaces,
        progress: 0.3,
      ),
    );
    Uint8List processed;
    try {
      processed = await _processingService.detectAndProcessFaces(imageBytes);
    } catch (e) {
      _toastService.show(AppStrings.noFacesDetected, type: ToastType.warning);
      // Preserve model state (original image) for retry
      final currentData = _state.value.data;
      _state.value = BaseState.error(
        exception: FaceDetectionException(message: e.toString()),
        data: currentData,
      );
      _navigationService.goBack();
      return;
    }
    final data = _state.value.data!;
    _state.value = BaseState.success(
      data.copyWith(processingStep: ProcessingStep.saving, progress: 0.8),
    );
    await _saveResult(
      originalBytes: imageBytes,
      processedBytes: processed,
      type: ProcessingType.face,
      isPdf: false,
      documentTitle: AppStrings.facesProcessed,
    );
  }

  Future<void> _processDocument(Uint8List imageBytes) async {
    final current = _state.value.data!;
    _state.value = BaseState.success(
      current.copyWith(
        processingStep: ProcessingStep.processingDocument,
        progress: 0.4,
      ),
    );

    // Process document - will crop if detected, or use full image
    final processedImage = await _processingService.processDocument(imageBytes);
    await _navigateToMultiPageBuilder(
      originalBytes: imageBytes,
      processedBytes: processedImage,
    );
  }

  Future<void> _navigateToMultiPageBuilder({
    required Uint8List originalBytes,
    required Uint8List processedBytes,
  }) async {
    await _navigationService.replaceWith(
      Routes.multiPage,
      arguments: MultiPageProps(
        originalBytes: originalBytes,
        processedBytes: processedBytes,
      ),
    );
  }

  Future<void> _saveResult({
    required Uint8List originalBytes,
    required Uint8List processedBytes,
    required ProcessingType type,
    required bool isPdf,
    String? documentTitle,
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
        documentTitle: documentTitle,
      );
      await _persistEntity(entity);
      _updateStateToComplete();
      // Go back to home first, then navigate to result from home
      await _navigateToResultViaHome(entity);
    } catch (e) {
      _handleSaveError(e);
    }
  }

  /// Saves all files (original, processed, thumbnail) and returns their paths.
  /// Implements rollback: if any file save fails, deletes already-saved files.
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
      // Rollback: delete any successfully saved files
      if (originalPath != null) {
        try {
          await _fileStorageService.deleteFile(originalPath);
        } catch (_) {
          // Ignore rollback errors
        }
      }
      if (processedPath != null) {
        try {
          await _fileStorageService.deleteFile(processedPath);
        } catch (_) {
          // Ignore rollback errors
        }
      }
      if (thumbnailPath != null) {
        try {
          await _fileStorageService.deleteFile(thumbnailPath);
        } catch (_) {
          // Ignore rollback errors
        }
      }
      rethrow;
    }
  }

  /// Creates a ProcessedImage entity from saved files and metadata.
  ProcessedImage _createProcessedImageEntity({
    required String id,
    required ProcessingType type,
    required _SavedFiles savedFiles,
    required Uint8List processedBytes,
    String? documentTitle,
  }) {
    return ProcessedImage(
      id: id,
      processingType: type,
      originalPath: savedFiles.originalPath,
      processedPath: savedFiles.processedPath,
      thumbnailPath: savedFiles.thumbnailPath,
      fileSize: processedBytes.length,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      metadata: documentTitle,
    );
  }

  /// Persists the entity to the repository.
  Future<void> _persistEntity(ProcessedImage entity) async {
    await _repository.init();
    await _repository.add(entity);
  }

  /// Updates state to indicate processing is complete.
  void _updateStateToComplete() {
    final data = _state.value.data!;
    _state.value = BaseState.success(
      data.copyWith(progress: 1.0, processingStep: ProcessingStep.done),
    );
  }

  /// Navigates to the result screen via home to ensure proper navigation context.
  Future<void> _navigateToResultViaHome(ProcessedImage entity) async {
    await _navigationService.replaceWith(
      Routes.result,
      arguments: ResultProps(processedImage: entity),
    );
  }

  /// Handles errors during the save operation.
  void _handleSaveError(Object error) {
    _state.value = BaseState.error(
      exception: StorageException(message: error.toString()),
    );
    _toastService.show(AppStrings.failedToSaveImagePdf, type: ToastType.error);
  }
}

/// Holds paths of saved files for a processed image.
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
