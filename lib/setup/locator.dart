import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:codeway_image_processing/base/services/database_service/database_service.dart';
import 'package:codeway_image_processing/base/services/database_service/i_database_service.dart';
import 'package:codeway_image_processing/base/services/file_open_service/file_open_service.dart';
import 'package:codeway_image_processing/base/services/file_open_service/i_file_open_service.dart';
import 'package:codeway_image_processing/base/services/file_storage_service/file_storage_service.dart';
import 'package:codeway_image_processing/base/services/file_storage_service/i_file_storage_service.dart';
import 'package:codeway_image_processing/base/services/image_picker_service/i_image_picker_service.dart';
import 'package:codeway_image_processing/base/services/image_picker_service/image_picker_service.dart';
import 'package:codeway_image_processing/base/services/image_processing_service/i_image_processing_service.dart';
import 'package:codeway_image_processing/base/services/image_processing_service/image_processing_service.dart';
import 'package:codeway_image_processing/base/services/method_channel_service/i_method_channel_service.dart';
import 'package:codeway_image_processing/base/services/method_channel_service/method_channel_service.dart';
import 'package:codeway_image_processing/base/services/navigation_service/i_navigation_service.dart';
import 'package:codeway_image_processing/base/services/navigation_service/navigation_service.dart';
import 'package:codeway_image_processing/base/services/toast_service/i_toast_service.dart';
import 'package:codeway_image_processing/base/services/toast_service/toast_service.dart';
import 'package:codeway_image_processing/features/image_processing/data/repositories/i_processed_image_repository.dart';
import 'package:codeway_image_processing/features/image_processing/data/repositories/processed_image_repository.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/detail/detail_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/document/document_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/home/home_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/processing/processing_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/source_selector_dialog/source_selector_dialog_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/summary_vm.dart';

/// Dependency injection via GetX. Call once at app startup.
void setupLocator({required GlobalKey<NavigatorState> navigatorKey}) {
  Get.lazyPut<INavigationService>(
    () => NavigationService(navigatorKey: navigatorKey),
    fenix: true,
  );
  Get.lazyPut<IDatabaseService>(() => DatabaseService(), fenix: true);
  Get.lazyPut<IFileStorageService>(() => FileStorageService(), fenix: true);
  Get.lazyPut<IFileOpenService>(() => FileOpenService(), fenix: true);
  Get.lazyPut<IMethodChannelService>(
    () => MethodChannelService(channelName: kNativeImageProcessingChannelName),
    fenix: true,
  );
  Get.lazyPut<IImageProcessingService>(
    () => ImageProcessingService(
      channelService: Get.find<IMethodChannelService>(),
    ),
    fenix: true,
  );
  Get.lazyPut<IProcessedImageRepository>(
    () => ProcessedImageRepository(database: Get.find<IDatabaseService>()),
    fenix: true,
  );
  Get.lazyPut<IImagePickerService>(() => ImagePickerService(), fenix: true);
  Get.lazyPut<IToastService>(
    () => ToastService(navigatorKey: navigatorKey),
    fenix: true,
  );

  // ViewModels are created per-route via VMFactories below, not registered here.
}

/// ViewModel factories; each route gets a fresh VM via [BaseView].
class VMFactories {
  static SourceSelectorDialogVM createSourceSelectorDialogVM() {
    return SourceSelectorDialogVM(
      navigationService: Get.find<INavigationService>(),
      imagePickerService: Get.find<IImagePickerService>(),
    );
  }

  static HomeVM createHomeVM() {
    return HomeVM(
      repository: Get.find<IProcessedImageRepository>(),
      fileStorageService: Get.find<IFileStorageService>(),
      fileOpenService: Get.find<IFileOpenService>(),
      navigationService: Get.find<INavigationService>(),
      sourceSelectorDialogVm: createSourceSelectorDialogVM(),
    );
  }

  static ProcessingVM createProcessingVM() {
    return ProcessingVM(
      processingService: Get.find<IImageProcessingService>(),
      fileStorageService: Get.find<IFileStorageService>(),
      repository: Get.find<IProcessedImageRepository>(),
      navigationService: Get.find<INavigationService>(),
    );
  }

  static DocumentVM createDocumentVM() {
    return DocumentVM(
      processingService: Get.find<IImageProcessingService>(),
      imagePickerService: Get.find<IImagePickerService>(),
      fileOpenService: Get.find<IFileOpenService>(),
      fileStorageService: Get.find<IFileStorageService>(),
      repository: Get.find<IProcessedImageRepository>(),
      navigationService: Get.find<INavigationService>(),
    );
  }

  static SummaryVM createSummaryVM({bool closeOnEmpty = true}) {
    return SummaryVM(
      navigationService: Get.find<INavigationService>(),
      repository: Get.find<IProcessedImageRepository>(),
      fileStorageService: Get.find<IFileStorageService>(),
      fileOpenService: Get.find<IFileOpenService>(),
      closeOnEmpty: closeOnEmpty,
    );
  }

  static DetailVM createDetailVM() {
    return DetailVM(
      repository: Get.find<IProcessedImageRepository>(),
      fileStorageService: Get.find<IFileStorageService>(),
      fileOpenService: Get.find<IFileOpenService>(),
      navigationService: Get.find<INavigationService>(),
    );
  }
}
