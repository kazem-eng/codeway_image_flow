import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:codeway_image_processing/base/services/file_storage_service/file_storage_service.dart';
import 'package:codeway_image_processing/base/services/file_storage_service/i_file_storage_service.dart';
import 'package:codeway_image_processing/base/services/file_open_service/file_open_service.dart';
import 'package:codeway_image_processing/base/services/file_open_service/i_file_open_service.dart';
import 'package:codeway_image_processing/base/services/image_picker_service/image_picker_service.dart';
import 'package:codeway_image_processing/base/services/image_picker_service/i_image_picker_service.dart';
import 'package:codeway_image_processing/base/services/image_processing_service/image_processing_service.dart';
import 'package:codeway_image_processing/base/services/image_processing_service/i_image_processing_service.dart';
import 'package:codeway_image_processing/base/services/navigation_service/i_navigation_service.dart';
import 'package:codeway_image_processing/base/services/navigation_service/navigation_service.dart';

import 'package:codeway_image_processing/base/services/toast_service/i_toast_service.dart';
import 'package:codeway_image_processing/base/services/toast_service/toast_service.dart';
import 'package:codeway_image_processing/features/image_processing/data/repositories/i_processed_image_repository.dart';
import 'package:codeway_image_processing/features/image_processing/data/repositories/processed_image_repository.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/capture/capture_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/detail/detail_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/home/home_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/multi_page/multi_page_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/processing/processing_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/result/result_vm.dart';

/// Setup dependency injection using GetX. Call once at app startup.
void setupLocator({required GlobalKey<NavigatorState> navigatorKey}) {
  // Register services as lazy singletons (fenix: true allows recreation if deleted)
  Get.lazyPut<INavigationService>(
    () => NavigationService(navigatorKey: navigatorKey),
    fenix: true,
  );
  Get.lazyPut<IFileStorageService>(() => FileStorageService(), fenix: true);
  Get.lazyPut<IFileOpenService>(() => FileOpenService(), fenix: true);
  Get.lazyPut<IImageProcessingService>(
    () => ImageProcessingService(),
    fenix: true,
  );
  Get.lazyPut<IProcessedImageRepository>(
    () => ProcessedImageRepository(),
    fenix: true,
  );
  Get.lazyPut<IImagePickerService>(() => ImagePickerService(), fenix: true);
  Get.lazyPut<IToastService>(
    () => ToastService(navigatorKey: navigatorKey),
    fenix: true,
  );

  // ViewModels are NOT registered here - they are created per-route via VMFactories
  // See VMFactories class below for factory methods
}

/// Factory functions for ViewModels. Creates fresh instances per route.
/// Used by BaseView to instantiate ViewModels with their dependencies.
class VMFactories {
  /// Creates a new CaptureVM instance with dependencies resolved from GetX.
  static CaptureVM createCaptureVM() {
    return CaptureVM(
      navigationService: Get.find<INavigationService>(),
      imagePickerService: Get.find<IImagePickerService>(),
    );
  }

  /// Creates a new HomeVM instance with dependencies resolved from GetX.
  static HomeVM createHomeVM() {
    return HomeVM(
      repository: Get.find<IProcessedImageRepository>(),
      fileStorageService: Get.find<IFileStorageService>(),
      fileOpenService: Get.find<IFileOpenService>(),
      navigationService: Get.find<INavigationService>(),
      captureVm: createCaptureVM(), // Direct creation, not Get.find
    );
  }

  /// Creates a new ProcessingVM instance with dependencies resolved from GetX.
  static ProcessingVM createProcessingVM() {
    return ProcessingVM(
      processingService: Get.find<IImageProcessingService>(),
      fileStorageService: Get.find<IFileStorageService>(),
      repository: Get.find<IProcessedImageRepository>(),
      navigationService: Get.find<INavigationService>(),
    );
  }

  /// Creates a new MultiPageVM instance with dependencies resolved from GetX.
  static MultiPageVM createMultiPageVM() {
    return MultiPageVM(
      processingService: Get.find<IImageProcessingService>(),
      imagePickerService: Get.find<IImagePickerService>(),
      fileOpenService: Get.find<IFileOpenService>(),
      fileStorageService: Get.find<IFileStorageService>(),
      repository: Get.find<IProcessedImageRepository>(),
      navigationService: Get.find<INavigationService>(),
    );
  }

  /// Creates a new ResultVM instance with dependencies resolved from GetX.
  static ResultVM createResultVM() {
    return ResultVM(
      fileStorageService: Get.find<IFileStorageService>(),
      fileOpenService: Get.find<IFileOpenService>(),
      navigationService: Get.find<INavigationService>(),
    );
  }

  /// Creates a new DetailVM instance with dependencies resolved from GetX.
  static DetailVM createDetailVM() {
    return DetailVM(
      repository: Get.find<IProcessedImageRepository>(),
      fileStorageService: Get.find<IFileStorageService>(),
      fileOpenService: Get.find<IFileOpenService>(),
      navigationService: Get.find<INavigationService>(),
    );
  }
}
