import 'package:codeway_image_processing/base/base_exception.dart';
import 'package:codeway_image_processing/base/mvvm_base/base_state.dart';
import 'package:codeway_image_processing/base/services/file_storage_service/i_file_storage_service.dart';
import 'package:codeway_image_processing/base/services/navigation_service/i_navigation_service.dart';
import 'package:codeway_image_processing/base/services/navigation_service/routes.dart';
import 'package:codeway_image_processing/base/services/toast_service/i_toast_service.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processed_image.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/result/result_model.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';

/// Result screen ViewModel. Props passed via [init] from view; all logic uses model.
class ResultVM {
  ResultVM({
    required IFileStorageService fileStorageService,
    required INavigationService navigationService,
  }) : _fileStorageService = fileStorageService,
       _navigationService = navigationService;

  final IFileStorageService _fileStorageService;
  final INavigationService _navigationService;
  final IToastService _toastService = Get.find<IToastService>();
  final _state = const BaseState<ResultModel>.loading().obs;

  /// Call from view's [initViewModel] with props (e.g. vm.init(processedImage); vm.loadImages()).
  Future<void> init(ProcessedImage processedImage) async {
    _state.value = BaseState.success(
      ResultModel(processedImage: processedImage),
    );
    await loadImages();
  }

  BaseState<ResultModel> get state => _state.value;

  ResultModel get model => _state.value.data ?? const ResultModel();

  /// Screen title for the result screen (Face Result / PDF Created).
  String get screenTitle {
    final entity = model.processedImage;
    if (entity == null) return AppStrings.faceResultScreenTitle;
    return entity.processingType.isFace
        ? AppStrings.faceResultScreenTitle
        : AppStrings.pdfCreatedScreenTitle;
  }

  Future<void> loadImages() async {
    final entity = model.processedImage;
    if (entity == null) return;
    _state.value = BaseState.loading(model);
    try {
      final original = await _fileStorageService.loadImage(entity.originalPath);
      final isDocument = entity.processingType.isDocument;
      final processed = isDocument
          ? await _fileStorageService.loadPdfBytes(entity.processedPath)
          : await _fileStorageService.loadImage(entity.processedPath);

      _state.value = BaseState.success(
        model.copyWith(
          originalImage: original,
          processedImageBytes: processed,
          pdfPath: isDocument ? entity.processedPath : null,
          documentTitle: entity.metadata,
        ),
      );
    } catch (e) {
      _toastService.show(AppStrings.failedToLoadImages);
      _state.value = BaseState.error(
        exception: StorageException(message: e.toString()),
        data: model,
      );
    }
  }

  Future<void> done() async {
    final showSuccessToast = _state.value.isSuccess;
    await _navigationService.goBackUntil(Routes.home);
    if (showSuccessToast) {
      _toastService.show(AppStrings.imageProcessedSuccessfully);
    }
  }

  Future<void> openPdf() async {
    final path = model.processedImage?.processedPath;
    if (path == null) return;
    try {
      await OpenFilex.open(path);
    } catch (e) {
      _toastService.show(AppStrings.fileNotFound);
    }
  }
}
