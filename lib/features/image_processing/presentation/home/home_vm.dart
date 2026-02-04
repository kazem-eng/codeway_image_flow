import 'package:codeway_image_processing/base/base_exception.dart';
import 'package:codeway_image_processing/base/mvvm_base/base_state.dart';
import 'package:codeway_image_processing/base/services/file_storage_service/i_file_storage_service.dart';
import 'package:codeway_image_processing/base/services/navigation_service/i_navigation_service.dart';
import 'package:codeway_image_processing/base/services/navigation_service/routes.dart';
import 'package:codeway_image_processing/base/services/toast_service/i_toast_service.dart';
import 'package:codeway_image_processing/features/image_processing/data/repositories/i_processed_image_repository.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processed_image.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processing_type.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/capture/capture_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/detail/detail_props.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/home/home_model.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';

/// Home screen ViewModel.
class HomeVM {
  HomeVM({
    required IProcessedImageRepository repository,
    required IFileStorageService fileStorageService,
    required INavigationService navigationService,
    required CaptureVM captureVm,
  }) : _repository = repository,
       _fileStorageService = fileStorageService,
       _navigationService = navigationService,
       _captureVm = captureVm;

  final IProcessedImageRepository _repository;
  final IFileStorageService _fileStorageService;
  final INavigationService _navigationService;
  final CaptureVM _captureVm;
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
      _state.value = BaseState.success(currentModel.copyWith(history: images));
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
        // Delete files first - if this fails, DB entry remains for retry
        await _fileStorageService.deleteProcessedImageFiles(image);
        // Only delete DB entry if files are successfully deleted
        await _repository.delete(id);
      }
      await loadHistory();
      _toastService.show(AppStrings.itemDeleted);
    } catch (e) {
      _toastService.show(AppStrings.failedToDeleteItem);
    }
  }

  Future<void> captureFromCamera() async {
    try {
      await _captureVm.captureFromCamera();
      await loadHistory();
    } catch (e) {
      _toastService.show(AppStrings.failedToCaptureImage);
    }
  }

  Future<void> captureFromGallery() async {
    try {
      await _captureVm.captureFromGallery();
      await loadHistory();
    } catch (e) {
      _toastService.show(AppStrings.failedToCaptureImage);
    }
  }

  Future<void> navigateToDetail(ProcessedImage image) async {
    await _navigationService.goTo(
      Routes.detail,
      arguments: DetailProps(imageId: image.id),
    );
    // History will refresh when user returns to home screen
  }

  Future<void> openPdf(ProcessedImage image) async {
    if (image.processingType != ProcessingType.document) return;
    try {
      await OpenFilex.open(image.processedPath);
    } catch (e) {
      _toastService.show(AppStrings.fileNotFound);
    }
  }
}
