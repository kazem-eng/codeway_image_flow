import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import 'package:codeway_image_processing/base/mvvm_base/base_state.dart';
import 'package:codeway_image_processing/base/services/file_storage_service/file_storage_service.dart';
import 'package:codeway_image_processing/base/services/file_storage_service/i_file_storage_service.dart';
import 'package:codeway_image_processing/base/services/file_open_service/i_file_open_service.dart';
import 'package:codeway_image_processing/base/services/image_picker_service/i_image_picker_service.dart';
import 'package:codeway_image_processing/base/services/image_processing_service/i_image_processing_service.dart';
import 'package:codeway_image_processing/base/services/navigation_service/i_navigation_service.dart';
import 'package:codeway_image_processing/base/services/navigation_service/routes.dart';
import 'package:codeway_image_processing/base/services/toast_service/i_toast_service.dart';
import 'package:codeway_image_processing/features/image_processing/data/repositories/i_processed_image_repository.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processed_image.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processing_type.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/document/document_model.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/document/document_props.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/utils/date_formats.dart';

/// Document builder ViewModel.
class DocumentVM {
  DocumentVM({
    required IImageProcessingService processingService,
    required IImagePickerService imagePickerService,
    required IFileOpenService fileOpenService,
    required IFileStorageService fileStorageService,
    required IProcessedImageRepository repository,
    required INavigationService navigationService,
  }) : _processingService = processingService,
       _imagePickerService = imagePickerService,
       _fileOpenService = fileOpenService,
       _fileStorageService = fileStorageService,
       _repository = repository,
       _navigationService = navigationService;

  final IImageProcessingService _processingService;
  final IImagePickerService _imagePickerService;
  final IFileOpenService _fileOpenService;
  final IFileStorageService _fileStorageService;
  final IProcessedImageRepository _repository;
  final INavigationService _navigationService;
  final IToastService _toastService = Get.find<IToastService>();

  final _state = const BaseState<DocumentModel>.success(DocumentModel()).obs;
  BaseState<DocumentModel> get state => _state.value;

  DocumentModel get model => _state.value.data ?? const DocumentModel();

  final _uuid = const Uuid();

  void init(DocumentProps props) {
    final pages =
        props.pages
            .map(
              (page) => DocumentPage(
                id: _uuid.v4(),
                originalBytes: page.originalBytes,
                processedBytes: page.processedBytes,
              ),
            )
            .toList();
    _state.value = BaseState.success(
      DocumentModel(
        pages: pages,
        selectedIndex: 0,
        hasUnsavedChanges: true,
      ),
    );
  }

  void selectPage(int index) {
    if (index < 0 || index >= model.pages.length) return;
    _state.value = BaseState.success(model.copyWith(selectedIndex: index));
  }

  Future<void> addPage(ImageSource source) async {
    if (model.isProcessingPage || model.isSaving) return;
    _state.value = BaseState.success(model.copyWith(isProcessingPage: true));
    try {
      final bytes = await _imagePickerService.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (bytes == null) {
        _state.value = BaseState.success(
          model.copyWith(isProcessingPage: false),
        );
        return;
      }
      final type = await _processingService.detectContentType(bytes);
      if (type.isFace) {
        _toastService.show(
          AppStrings.multiPageDocumentsOnly,
          type: ToastType.warning,
        );
        _state.value = BaseState.success(
          model.copyWith(isProcessingPage: false),
        );
        return;
      }
      final processed = await _processingService.processDocument(bytes);
      final updated = List<DocumentPage>.from(model.pages)
        ..add(
          DocumentPage(
            id: _uuid.v4(),
            originalBytes: bytes,
            processedBytes: processed,
          ),
        );
      _state.value = BaseState.success(
        model.copyWith(
          pages: updated,
          selectedIndex: updated.length - 1,
          isProcessingPage: false,
          hasUnsavedChanges: true,
        ),
      );
      _toastService.show(AppStrings.pageAdded, type: ToastType.success);
    } catch (e) {
      _toastService.show(
        AppStrings.failedToCaptureImage,
        type: ToastType.error,
      );
      _state.value = BaseState.success(model.copyWith(isProcessingPage: false));
    }
  }

  Future<void> addPagesFromGallery() async {
    if (model.isProcessingPage || model.isSaving) return;
    _state.value = BaseState.success(model.copyWith(isProcessingPage: true));
    try {
      final images = await _imagePickerService.pickMultiImages(
        imageQuality: 85,
      );
      if (images.isEmpty) {
        _state.value = BaseState.success(
          model.copyWith(isProcessingPage: false),
        );
        return;
      }
      final updated = List<DocumentPage>.from(model.pages);
      var skippedFaces = false;
      for (final bytes in images) {
        final type = await _processingService.detectContentType(bytes);
        if (type.isFace) {
          skippedFaces = true;
          continue;
        }
        final processed = await _processingService.processDocument(bytes);
        updated.add(
          DocumentPage(
            id: _uuid.v4(),
            originalBytes: bytes,
            processedBytes: processed,
          ),
        );
      }
      if (updated.length != model.pages.length) {
        _state.value = BaseState.success(
          model.copyWith(
            pages: updated,
            selectedIndex: updated.length - 1,
            isProcessingPage: false,
            hasUnsavedChanges: true,
          ),
        );
        _toastService.show(AppStrings.pageAdded, type: ToastType.success);
      } else {
        _state.value = BaseState.success(
          model.copyWith(isProcessingPage: false),
        );
      }
      if (skippedFaces) {
        _toastService.show(
          AppStrings.multiPageDocumentsOnly,
          type: ToastType.warning,
        );
      }
    } catch (e) {
      _toastService.show(
        AppStrings.failedToCaptureImage,
        type: ToastType.error,
      );
      _state.value = BaseState.success(model.copyWith(isProcessingPage: false));
    }
  }

  void reorderPages(int oldIndex, int newIndex) {
    final pages = List<DocumentPage>.from(model.pages);
    if (oldIndex < 0 || oldIndex >= pages.length) return;
    if (newIndex > pages.length) newIndex = pages.length;
    if (oldIndex < newIndex) newIndex -= 1;

    final selected = pages[model.selectedIndex];
    final item = pages.removeAt(oldIndex);
    pages.insert(newIndex, item);

    final selectedIndex = pages.indexWhere((p) => p.id == selected.id);
    _state.value = BaseState.success(
      model.copyWith(
        pages: pages,
        selectedIndex: selectedIndex,
        hasUnsavedChanges: true,
      ),
    );
  }

  void removePage(int index) {
    final pages = List<DocumentPage>.from(model.pages);
    if (pages.length <= 1) {
      _toastService.show(AppStrings.atLeastOnePage, type: ToastType.warning);
      return;
    }
    if (index < 0 || index >= pages.length) return;
    pages.removeAt(index);
    final newIndex = model.selectedIndex.clamp(0, pages.length - 1);
    _state.value = BaseState.success(
      model.copyWith(
        pages: pages,
        selectedIndex: newIndex,
        hasUnsavedChanges: true,
      ),
    );
  }

  Future<void> exportPdf() async {
    final pages = model.pages;
    if (pages.isEmpty || model.isSaving) return;
    _state.value = BaseState.success(model.copyWith(isSaving: true));
    try {
      final title =
          '${AppStrings.documentPrefix} ${DateFormats.formatCurrentIsoDate()}';
      final pdfBytes = await _processingService.createPdfFromImages(
        pages.map((p) => p.processedBytes).toList(),
        title,
      );
      final pageLabel = pages.length == 1 ? AppStrings.page : AppStrings.pages;
      final documentTitle = '$title - ${pages.length} $pageLabel';
      final entity = await _saveResult(
        originalBytes: pages.first.originalBytes,
        processedBytes: pdfBytes,
        type: ProcessingType.document,
        isPdf: true,
        documentTitle: documentTitle,
      );
      _fileOpenService.open(entity.processedPath);
      _state.value = BaseState.success(
        model.copyWith(hasUnsavedChanges: false),
      );
      await _navigationService.goBackUntil(Routes.home);
    } catch (e) {
      _handleSaveError(e);
    } finally {
      _state.value = BaseState.success(model.copyWith(isSaving: false));
    }
  }

  Future<ProcessedImage> _saveResult({
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
      return entity;
    } catch (e) {
      _handleSaveError(e);
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

  Future<void> _persistEntity(ProcessedImage entity) async {
    await _repository.init();
    await _repository.add(entity);
  }

  void _handleSaveError(Object error) {
    _toastService.show(AppStrings.failedToSaveImagePdf, type: ToastType.error);
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
