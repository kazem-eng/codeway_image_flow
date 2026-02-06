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
    try {
      await selectSource(ImageSource.camera);
      await captureImage();
    } catch (e) {
      _toastService.show(AppStrings.failedToCaptureImage, type: ToastType.error);
    }
  }

  Future<void> captureFromGallery() async {
    try {
      await selectSource(ImageSource.gallery);
      await captureBatchFromGallery();
    } catch (e) {
      _toastService.show(AppStrings.failedToCaptureImage, type: ToastType.error);
    }
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
    final current = _state.value.data ?? const SourceSelectorDialogModel();
    _state.value = BaseState.success(current.copyWith(isProcessing: true));
    try {
      final bytes = await _imagePickerService.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (bytes != null) {
        final current2 = _state.value.data ?? const SourceSelectorDialogModel();
        _state.value = BaseState.success(
          current2.copyWith(capturedImage: bytes),
        );
        await processImage(bytes);
      }
    } catch (e) {
      rethrow;
    } finally {
      final current3 = _state.value.data ?? const SourceSelectorDialogModel();
      _state.value = BaseState.success(current3.copyWith(isProcessing: false));
    }
  }

  Future<void> pickFromGallery() async {
    _state.value = BaseState.success(model.copyWith(isProcessing: true));
    try {
      final images = await _imagePickerService.pickMultiImages(
        imageQuality: 85,
      );
      if (images.isNotEmpty) {
        _state.value = BaseState.success(
          model.copyWith(capturedImage: images.first),
        );
        await processBatch(images);
      }
    } catch (e) {
      rethrow;
    } finally {
      _state.value = BaseState.success(model.copyWith(isProcessing: false));
    }
  }

  Future<void> captureBatchFromGallery() async {
    _state.value = BaseState.success(model.copyWith(isProcessing: true));
    try {
      final images = await _imagePickerService.pickMultiImages(
        imageQuality: 85,
      );
      if (images.isNotEmpty) {
        await processBatch(images);
      }
    } catch (e) {
      _toastService.show(AppStrings.failedToCaptureImage, type: ToastType.error);
    } finally {
      _state.value = BaseState.success(model.copyWith(isProcessing: false));
    }
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
}
