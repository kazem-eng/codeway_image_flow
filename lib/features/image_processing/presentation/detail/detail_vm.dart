import 'dart:typed_data';

import 'package:codeway_image_processing/base/base_exception.dart';
import 'package:codeway_image_processing/base/mvvm_base/base_state.dart';
import 'package:codeway_image_processing/base/services/file_open_service/i_file_open_service.dart';
import 'package:codeway_image_processing/base/services/file_storage_service/i_file_storage_service.dart';
import 'package:codeway_image_processing/base/services/navigation_service/i_navigation_service.dart';
import 'package:codeway_image_processing/base/services/toast_service/i_toast_service.dart';
import 'package:codeway_image_processing/features/image_processing/data/repositories/i_processed_image_repository.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processed_image.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processing_type.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/detail/detail_model.dart';
import 'package:codeway_image_processing/features/image_processing/utils/face_batch_metadata.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:get/get.dart';

/// Detail screen ViewModel. Props passed via [init] from view; all logic uses model.
class DetailVM {
  DetailVM({
    required IProcessedImageRepository repository,
    required IFileStorageService fileStorageService,
    required IFileOpenService fileOpenService,
    required INavigationService navigationService,
  }) : _repository = repository,
       _fileStorageService = fileStorageService,
       _fileOpenService = fileOpenService,
       _navigationService = navigationService;

  final IProcessedImageRepository _repository;
  final IFileStorageService _fileStorageService;
  final IFileOpenService _fileOpenService;
  final INavigationService _navigationService;
  final IToastService _toastService = Get.find<IToastService>();
  final _state = const BaseState<DetailModel>.loading().obs;

  /// Call from view's [initViewModel] with props (e.g. vm.init(imageId); vm.loadImage()).
  Future<void> init(String imageId) async {
    _state.value = BaseState.loading(DetailModel(imageId: imageId));
    await loadImage();
  }

  BaseState<DetailModel> get state => _state.value;

  DetailModel get model => _state.value.data ?? const DetailModel();

  Future<void> loadImage() async {
    final id = model.imageId;
    if (id == null) return;
    _state.value = BaseState.loading(model);
    try {
      await _repository.init();
      final entity = await _repository.getById(id);
      if (entity == null) {
        _state.value = BaseState.error(
          exception: StorageException(message: AppStrings.itemNotFound),
          data: model,
        );
        return;
      }
      final pair = await _loadImageBytes(entity);
      if (pair == null) {
        await _handleMissingFile(entity);
        return;
      }
      _state.value = BaseState.success(
        model.copyWith(
          image: entity,
          originalBytes: pair.originalBytes,
          processedBytes: pair.processedBytes,
          pdfPath: entity.processingType == ProcessingType.document
              ? entity.processedPath
              : null,
        ),
      );
    } catch (e) {
      _state.value = BaseState.error(
        exception: StorageException(message: e.toString()),
        data: model,
      );
    }
  }

  Future<_ImagePair?> _loadImageBytes(ProcessedImage image) async {
    // For document type, only load original bytes for viewing.
    if (image.processingType.isDocument) {
      final original = await _loadFirstExisting([
        image.originalPath,
        if (image.thumbnailPath != null) image.thumbnailPath!,
      ]);
      if (original == null) return null;
      return _ImagePair(originalBytes: original, processedBytes: null);
    }

    // For other types, load both original and processed (or thumbnail) bytes.
    final processed = await _loadFirstExisting([
      image.processedPath,
      if (image.thumbnailPath != null) image.thumbnailPath!,
    ]);
    final original = await _loadFirstExisting([image.originalPath]);
    if (processed == null || original == null) return null;
    return _ImagePair(originalBytes: original, processedBytes: processed);
  }

  Future<Uint8List?> _loadFirstExisting(List<String> paths) async {
    for (final path in paths) {
      try {
        return await _fileStorageService.loadImage(path);
      } on FileStorageException {
        continue;
      }
    }
    return null;
  }

  Future<void> _deleteEntityAndFiles(ProcessedImage image) async {
    // Delete files first - if this fails, DB entry remains for retry
    await _fileStorageService.deleteProcessedImageFiles(image);
    // Only delete DB entry if files are successfully deleted
    await _repository.delete(image.id);
  }

  Future<void> _handleMissingFile(ProcessedImage image) async {
    // Attempt to clean up entity and files, but proceed regardless of success
    // since files are already missing and we need to update the UI
    try {
      await _deleteEntityAndFiles(image);
    } catch (_) {
      // Silently handle deletion failure - files are already missing,
      // so we proceed to update UI and inform user regardless
    }
    _toastService.show(AppStrings.fileMissingRemoved, type: ToastType.warning);
    _state.value = BaseState.success(model.copyWith(image: null));
    _navigationService.goBack();
  }

  Future<void> deleteImage() async {
    final entity = model.image;
    if (entity == null) return;
    try {
      await _deleteEntityAndFiles(entity);
      await _removeFromFaceGroup(entity);
      _toastService.show(AppStrings.itemDeleted, type: ToastType.warning);
      _navigationService.goBack();
    } catch (e) {
      _toastService.show(AppStrings.failedToDeleteItem, type: ToastType.error);
      _navigationService.goBack();
    }
  }

  Future<void> _removeFromFaceGroup(ProcessedImage entity) async {
    final groupId = FaceBatchMetadata.groupIdFromItem(entity.metadata);
    if (groupId == null) return;
    await _repository.init();
    final group = await _repository.getById(groupId);
    if (group == null) return;
    final ids = FaceBatchMetadata.parseGroup(group.metadata);
    ids.remove(entity.id);
    if (ids.isEmpty) {
      await _fileStorageService.deleteProcessedImageFiles(group);
      await _repository.delete(group.id);
      return;
    }
    final updated = ProcessedImage(
      id: group.id,
      processingType: group.processingType,
      originalPath: group.originalPath,
      processedPath: group.processedPath,
      thumbnailPath: group.thumbnailPath,
      fileSize: group.fileSize,
      createdAt: group.createdAt,
      metadata: FaceBatchMetadata.group(ids),
    );
    await _repository.add(updated);
  }

  Future<void> openPdf() async {
    final entity = model.image ?? await _loadEntityForPdf();
    final pdfPath =
        model.pdfPath ??
        (entity != null && entity.processingType.isDocument
            ? entity.processedPath
            : null);
    if (pdfPath == null) return;
    try {
      await _fileOpenService.open(pdfPath);
    } catch (e) {
      _toastService.show(AppStrings.fileNotFound, type: ToastType.error);
    }
  }

  Future<ProcessedImage?> _loadEntityForPdf() async {
    final id = model.imageId;
    if (id == null) return null;
    try {
      await _repository.init();
      return await _repository.getById(id);
    } catch (_) {
      return null;
    }
  }
}

class _ImagePair {
  _ImagePair({required this.originalBytes, required this.processedBytes});

  final Uint8List originalBytes;
  final Uint8List? processedBytes;
}
