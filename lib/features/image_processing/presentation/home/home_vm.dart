import 'package:codeway_image_processing/base/base_exception.dart';
import 'package:codeway_image_processing/base/mvvm_base/base_state.dart';
import 'package:codeway_image_processing/base/services/file_open_service/i_file_open_service.dart';
import 'package:codeway_image_processing/base/services/file_storage_service/i_file_storage_service.dart';
import 'package:codeway_image_processing/base/services/navigation_service/i_navigation_service.dart';
import 'package:codeway_image_processing/base/services/navigation_service/routes.dart';
import 'package:codeway_image_processing/base/services/toast_service/i_toast_service.dart';
import 'package:codeway_image_processing/features/image_processing/data/repositories/i_processed_image_repository.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processed_image.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processing_type.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/summary_props.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/source_selector_dialog/source_selector_dialog_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/detail/detail_props.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/home/home_model.dart';
import 'package:codeway_image_processing/features/image_processing/utils/face_batch_metadata.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/utils/date_formats.dart';
import 'package:get/get.dart';

/// Home screen ViewModel.
class HomeVM {
  HomeVM({
    required IProcessedImageRepository repository,
    required IFileStorageService fileStorageService,
    required IFileOpenService fileOpenService,
    required INavigationService navigationService,
    required SourceSelectorDialogVM sourceSelectorDialogVm,
  }) : _repository = repository,
       _fileStorageService = fileStorageService,
       _fileOpenService = fileOpenService,
       _navigationService = navigationService,
       _sourceSelectorDialogVm = sourceSelectorDialogVm;

  final IProcessedImageRepository _repository;
  final IFileStorageService _fileStorageService;
  final IFileOpenService _fileOpenService;
  final INavigationService _navigationService;
  final SourceSelectorDialogVM _sourceSelectorDialogVm;
  final IToastService _toastService = Get.find<IToastService>();

  final _state = const BaseState<HomeModel>.loading().obs;
  BaseState<HomeModel> get state => _state.value;

  HomeModel get model => _state.value.data ?? const HomeModel();

  Future<void> onReturn() async {
    await loadHistory();
  }

  Future<void> loadHistory() async {
    final currentModel = model;
    _state.value = BaseState.loading(currentModel);
    try {
      await _repository.init();
      final images = await _repository.getAll();
      final visible = images
          .where((image) => !FaceBatchMetadata.isBatchItem(image.metadata))
          .toList();
      final items = visible.map(_buildHistoryItem).toList();
      _state.value = BaseState.success(currentModel.copyWith(items: items));
    } catch (e) {
      _state.value = BaseState.error(
        exception: StorageException(message: e.toString()),
        data: currentModel,
      );
    }
  }

  HomeHistoryItem _buildHistoryItem(ProcessedImage image) {
    return HomeHistoryItem(
      image: image,
      title: _historyTitle(image),
      subtitle: DateFormats.formatDateWithTime(image.createdAt),
    );
  }

  String _historyTitle(ProcessedImage image) {
    if (image.processingType.isFaceBatch) {
      final count = FaceBatchMetadata.parseGroup(image.metadata).length;
      return '${AppStrings.facesLabel} ($count)';
    }
    if (image.processingType.isFace) {
      return AppStrings.faceResultScreenTitle;
    }
    if (image.processingType.isDocument) {
      return _documentTitle(image.metadata);
    }
    return image.metadata ?? AppStrings.pdfDocument;
  }

  String _documentTitle(String? metadata) {
    if (metadata == null || metadata.isEmpty) {
      return AppStrings.pdfDocument;
    }
    final prefix = AppStrings.documentPrefix;
    final cleaned = metadata.replaceFirst(
      RegExp('^$prefix\\s\\d{4}-\\d{2}-\\d{2}\\s-\\s'),
      '$prefix - ',
    );
    return cleaned;
  }

  Future<void> deleteItem(String id) async {
    try {
      await _repository.init();
      final image = await _repository.getById(id);
      if (image == null) return;
      if (image.processingType.isFaceBatch) {
        await _deleteFaceBatchItems(image);
      }
      await _deleteImageAndFiles(image);
      await loadHistory();
      _toastService.show(AppStrings.itemDeleted, type: ToastType.warning);
    } catch (e) {
      _toastService.show(AppStrings.failedToDeleteItem, type: ToastType.error);
    }
  }

  Future<void> _deleteFaceBatchItems(ProcessedImage group) async {
    final faceIds = FaceBatchMetadata.parseGroup(group.metadata);
    for (final faceId in faceIds) {
      await _deleteFaceItemById(faceId);
    }
  }

  Future<void> _deleteFaceItemById(String id) async {
    final face = await _repository.getById(id);
    if (face == null) return;
    await _deleteImageAndFiles(face);
  }

  Future<void> _deleteImageAndFiles(ProcessedImage image) async {
    // Delete files first so a failed delete keeps the DB entry for retry.
    await _fileStorageService.deleteProcessedImageFiles(image);
    await _repository.delete(image.id);
  }

  Future<void> captureFromCamera() async {
    await _captureAndRefresh(_sourceSelectorDialogVm.captureFromCamera);
  }

  Future<void> captureFromGallery() async {
    await _captureAndRefresh(_sourceSelectorDialogVm.captureFromGallery);
  }

  Future<void> captureBatchFromGallery() async {
    await _captureAndRefresh(_sourceSelectorDialogVm.captureBatchFromGallery);
  }

  Future<void> _captureAndRefresh(Future<void> Function() action) async {
    try {
      await action();
      await loadHistory();
    } catch (e) {
      _toastService.show(
        AppStrings.failedToCaptureImage,
        type: ToastType.error,
      );
    }
  }

  Future<void> navigateToDetail(ProcessedImage image) async {
    await _navigationService.goTo(
      Routes.detail,
      arguments: DetailProps(imageId: image.id),
    );
    // History will refresh when user returns to home screen
  }

  Future<void> openFaceGroup(ProcessedImage image) async {
    await _navigationService.goTo(
      Routes.summary,
      arguments: SummaryProps(
        faces: const [],
        documents: const [],
        faceGroupId: image.id,
      ),
    );
  }

  Future<void> openPdf(ProcessedImage image) async {
    if (image.processingType != ProcessingType.document) return;
    try {
      await _fileOpenService.open(image.processedPath);
    } catch (e) {
      _toastService.show(AppStrings.fileNotFound, type: ToastType.error);
    }
  }
}
