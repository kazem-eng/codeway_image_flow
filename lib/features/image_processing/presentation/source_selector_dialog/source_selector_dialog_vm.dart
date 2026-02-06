import 'dart:typed_data';

import 'package:codeway_image_processing/base/mvvm_base/base_state.dart';
import 'package:codeway_image_processing/base/services/image_picker_service/i_image_picker_service.dart';
import 'package:codeway_image_processing/base/services/navigation_service/i_navigation_service.dart';
import 'package:codeway_image_processing/base/services/navigation_service/routes.dart';
import 'package:codeway_image_processing/base/services/toast_service/i_toast_service.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/source_selector_dialog/source_selector_dialog_model.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/processing/processing_props.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// ViewModel for the source selector dialog.
class SourceSelectorDialogVM {
  SourceSelectorDialogVM({
    required INavigationService navigationService,
    required IImagePickerService imagePickerService,
  }) : _navigationService = navigationService,
       _imagePickerService = imagePickerService;

  final INavigationService _navigationService;
  final IImagePickerService _imagePickerService;
  final IToastService _toastService = Get.find<IToastService>();

  final _state = const BaseState<SourceSelectorDialogModel>.success(
    SourceSelectorDialogModel(),
  ).obs;
  BaseState<SourceSelectorDialogModel> get state => _state.value;

  SourceSelectorDialogModel get model =>
      _state.value.data ?? const SourceSelectorDialogModel();

  Future<void> selectSource(ImageSource source) async {
    _state.value = BaseState.success(
      model.copyWith(selectedSource: source, hasPermission: true),
    );
  }

  Future<void> captureFromCamera() async {
    await selectSource(ImageSource.camera);
    await _captureSingleImage(
      ImageSource.camera,
      showErrorToast: true,
    );
  }

  Future<void> captureFromGallery() async {
    await selectSource(ImageSource.gallery);
    await _captureMultipleImages(showErrorToast: true);
  }

  void markSourceDialogShown() {
    final current = _state.value.data ?? const SourceSelectorDialogModel();
    if (current.showSourceDialog) {
      _state.value = BaseState.success(
        current.copyWith(showSourceDialog: false),
      );
    }
  }

  Future<void> captureImage() async {
    await _captureSingleImage(
      ImageSource.camera,
      showErrorToast: false,
    );
  }

  Future<void> pickFromGallery() async {
    await _captureMultipleImages(
      showErrorToast: false,
      updateCapturedImage: true,
    );
  }

  Future<void> captureBatchFromGallery() async {
    await _captureMultipleImages(showErrorToast: true);
  }

  Future<void> processImage(Uint8List imageBytes) async {
    await processBatch([imageBytes]);
  }

  Future<void> processBatch(List<Uint8List> images) async {
    await _navigationService.goTo(
      Routes.processing,
      arguments: ProcessingProps(images: images),
    );
  }

  void _setProcessing(bool value) {
    _state.value = BaseState.success(model.copyWith(isProcessing: value));
  }

  void _setCapturedImage(Uint8List bytes) {
    _state.value = BaseState.success(model.copyWith(capturedImage: bytes));
  }

  Future<void> _runProcessing(
    Future<void> Function() action, {
    required bool showErrorToast,
  }) async {
    _setProcessing(true);
    try {
      await action();
    } catch (e) {
      if (showErrorToast) {
        _toastService.show(
          AppStrings.failedToCaptureImage,
          type: ToastType.error,
        );
      } else {
        rethrow;
      }
    } finally {
      _setProcessing(false);
    }
  }

  Future<void> _captureSingleImage(
    ImageSource source, {
    required bool showErrorToast,
  }) async {
    await _runProcessing(() async {
      final bytes = await _imagePickerService.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (bytes == null) return;
      _setCapturedImage(bytes);
      await processImage(bytes);
    }, showErrorToast: showErrorToast);
  }

  Future<void> _captureMultipleImages({
    required bool showErrorToast,
    bool updateCapturedImage = false,
  }) async {
    await _runProcessing(() async {
      final images = await _imagePickerService.pickMultiImages(
        imageQuality: 85,
      );
      if (images.isEmpty) return;
      if (updateCapturedImage) {
        _setCapturedImage(images.first);
      }
      await processBatch(images);
    }, showErrorToast: showErrorToast);
  }
}
