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

  Future<void> loadHistory() async {
    final currentModel = model;
    _state.value = BaseState.loading(currentModel);
    try {
      await _repository.init();
      final images = await _repository.getAll();
      final visible = images
          .where((image) => !FaceBatchMetadata.isBatchItem(image.metadata))
          .toList();
      _state.value = BaseState.success(
        currentModel.copyWith(history: visible),
      );
    } catch (e) {
      _state.value = BaseState.error(
        exception: StorageException(message: e.toString()),
        data: currentModel,
      );
    }
  }


  Future<void> deleteItem(String id) async {
    try {
      await _repository.init();
      final image = await _repository.getById(id);
      if (image != null) {
        if (image.processingType.isFaceBatch) {
          final faceIds = FaceBatchMetadata.parseGroup(image.metadata);
          for (final faceId in faceIds) {
            final face = await _repository.getById(faceId);
            if (face != null) {
              await _fileStorageService.deleteProcessedImageFiles(face);
              await _repository.delete(faceId);
            }
          }
        }
        // Delete files first - if this fails, DB entry remains for retry
        await _fileStorageService.deleteProcessedImageFiles(image);
        // Only delete DB entry if files are successfully deleted
        await _repository.delete(id);
      }
      await loadHistory();
      _toastService.show(AppStrings.itemDeleted, type: ToastType.warning);
    } catch (e) {
      _toastService.show(AppStrings.failedToDeleteItem, type: ToastType.error);
    }
  }

  Future<void> captureFromCamera() async {
    try {
      await _sourceSelectorDialogVm.captureFromCamera();
      await loadHistory();
    } catch (e) {
      _toastService.show(AppStrings.failedToCaptureImage, type: ToastType.error);
    }
  }

  Future<void> captureFromGallery() async {
    try {
      await _sourceSelectorDialogVm.captureFromGallery();
      await loadHistory();
    } catch (e) {
      _toastService.show(AppStrings.failedToCaptureImage, type: ToastType.error);
    }
  }

  Future<void> captureBatchFromGallery() async {
    try {
      await _sourceSelectorDialogVm.captureBatchFromGallery();
      await loadHistory();
    } catch (e) {
      _toastService.show(AppStrings.failedToCaptureImage, type: ToastType.error);
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
