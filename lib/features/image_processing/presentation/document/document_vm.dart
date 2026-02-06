import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import 'package:codeway_image_processing/base/mvvm_base/base_state.dart';
import 'package:codeway_image_processing/base/services/file_storage_service/i_file_storage_service.dart';
import 'package:codeway_image_processing/base/services/file_open_service/i_file_open_service.dart';
import 'package:codeway_image_processing/base/services/image_picker_service/i_image_picker_service.dart';
import 'package:codeway_image_processing/base/services/image_processing_service/i_image_processing_service.dart';
import 'package:codeway_image_processing/base/services/navigation_service/i_navigation_service.dart';
import 'package:codeway_image_processing/base/services/navigation_service/routes.dart';
import 'package:codeway_image_processing/base/services/toast_service/i_toast_service.dart';
import 'package:codeway_image_processing/features/image_processing/data/repositories/i_processed_image_repository.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processing_type.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/document/document_model.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/document/document_props.dart';
import 'package:codeway_image_processing/features/image_processing/utils/processed_image_saver.dart';
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
       _navigationService = navigationService,
       _imageSaver = ProcessedImageSaver(
         fileStorageService: fileStorageService,
         repository: repository,
       );

  final IImageProcessingService _processingService;
  final IImagePickerService _imagePickerService;
  final IFileOpenService _fileOpenService;
  final INavigationService _navigationService;
  final ProcessedImageSaver _imageSaver;
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

  bool get _isBusy => model.isProcessingPage || model.isSaving;

  void _setProcessingPage(bool value) {
    _state.value = BaseState.success(model.copyWith(isProcessingPage: value));
  }

  void _updatePages(List<DocumentPage> pages, {int? selectedIndex}) {
    _state.value = BaseState.success(
      model.copyWith(
        pages: pages,
        selectedIndex: selectedIndex ?? model.selectedIndex,
        hasUnsavedChanges: true,
      ),
    );
  }

  Future<DocumentPage?> _createDocumentPage(Uint8List bytes) async {
    final type = await _processingService.detectContentType(bytes);
    if (type.isFace) {
      return null;
    }
    final processed = await _processingService.processDocument(bytes);
    return DocumentPage(
      id: _uuid.v4(),
      originalBytes: bytes,
      processedBytes: processed,
    );
  }

  Future<void> addPage(ImageSource source) async {
    if (_isBusy) return;
    _setProcessingPage(true);
    try {
      final bytes = await _imagePickerService.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (bytes == null) return;
      final page = await _createDocumentPage(bytes);
      if (page == null) {
        _toastService.show(
          AppStrings.multiPageDocumentsOnly,
          type: ToastType.warning,
        );
        return;
      }
      final updated = List<DocumentPage>.from(model.pages)..add(page);
      _updatePages(updated, selectedIndex: updated.length - 1);
      _toastService.show(AppStrings.pageAdded, type: ToastType.success);
    } catch (e) {
      _toastService.show(
        AppStrings.failedToCaptureImage,
        type: ToastType.error,
      );
    } finally {
      _setProcessingPage(false);
    }
  }

  Future<void> addPagesFromGallery() async {
    if (_isBusy) return;
    _setProcessingPage(true);
    try {
      final images = await _imagePickerService.pickMultiImages(
        imageQuality: 85,
      );
      if (images.isEmpty) return;
      final updated = List<DocumentPage>.from(model.pages);
      var skippedFaces = false;
      for (final bytes in images) {
        final page = await _createDocumentPage(bytes);
        if (page == null) {
          skippedFaces = true;
          continue;
        }
        updated.add(page);
      }
      if (updated.length != model.pages.length) {
        _updatePages(updated, selectedIndex: updated.length - 1);
        _toastService.show(AppStrings.pageAdded, type: ToastType.success);
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
    } finally {
      _setProcessingPage(false);
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
      final documentTitle =
          '${AppStrings.documentPrefix} - ${pages.length} $pageLabel';
      final entity = await _imageSaver.save(
        originalBytes: pages.first.originalBytes,
        processedBytes: pdfBytes,
        type: ProcessingType.document,
        isPdf: true,
        metadata: documentTitle,
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

  void _handleSaveError(Object error) {
    _toastService.show(AppStrings.failedToSaveImagePdf, type: ToastType.error);
  }
}
