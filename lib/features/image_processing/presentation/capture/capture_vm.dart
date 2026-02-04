import 'dart:typed_data';

import 'package:codeway_image_processing/base/mvvm_base/base_state.dart';
import 'package:codeway_image_processing/base/services/image_picker_service/i_image_picker_service.dart';
import 'package:codeway_image_processing/base/services/navigation_service/i_navigation_service.dart';
import 'package:codeway_image_processing/base/services/navigation_service/routes.dart';
import 'package:codeway_image_processing/base/services/toast_service/i_toast_service.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/capture/capture_model.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/processing/processing_props.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// Capture screen ViewModel.
class CaptureVM {
  CaptureVM({
    required INavigationService navigationService,
    required IImagePickerService imagePickerService,
  }) : _navigationService = navigationService,
       _imagePickerService = imagePickerService;

  final INavigationService _navigationService;
  final IImagePickerService _imagePickerService;
  final IToastService _toastService = Get.find<IToastService>();

  final _state = const BaseState<CaptureModel>.success(CaptureModel()).obs;
  BaseState<CaptureModel> get state => _state.value;

  CaptureModel get model => _state.value.data ?? const CaptureModel();

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
      _toastService.show(AppStrings.failedToCaptureImage);
    }
  }

  Future<void> captureFromGallery() async {
    try {
      await selectSource(ImageSource.gallery);
      await pickFromGallery();
    } catch (e) {
      _toastService.show(AppStrings.failedToCaptureImage);
    }
  }

  void markSourceDialogShown() {
    final current = _state.value.data ?? const CaptureModel();
    if (current.showSourceDialog) {
      _state.value = BaseState.success(
        current.copyWith(showSourceDialog: false),
      );
    }
  }

  Future<void> captureImage() async {
    final current = _state.value.data ?? const CaptureModel();
    _state.value = BaseState.success(current.copyWith(isProcessing: true));
    try {
      final bytes = await _imagePickerService.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (bytes != null) {
        final current2 = _state.value.data ?? const CaptureModel();
        _state.value = BaseState.success(
          current2.copyWith(capturedImage: bytes),
        );
        await processImage(bytes);
      }
    } catch (e) {
      rethrow;
    } finally {
      final current3 = _state.value.data ?? const CaptureModel();
      _state.value = BaseState.success(current3.copyWith(isProcessing: false));
    }
  }

  Future<void> pickFromGallery() async {
    _state.value = BaseState.success(model.copyWith(isProcessing: true));
    try {
      final bytes = await _imagePickerService.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (bytes != null) {
        _state.value = BaseState.success(model.copyWith(capturedImage: bytes));
        await processImage(bytes);
      }
    } catch (e) {
      rethrow;
    } finally {
      _state.value = BaseState.success(model.copyWith(isProcessing: false));
    }
  }

  Future<void> processImage(Uint8List imageBytes) async {
    await _navigationService.goTo(
      Routes.processing,
      arguments: ProcessingProps(imageBytes: imageBytes),
    );
  }
}
