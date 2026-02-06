import 'dart:typed_data';

import 'package:mockito/annotations.dart';

import 'package:codeway_image_processing/base/services/file_storage_service/i_file_storage_service.dart';
import 'package:codeway_image_processing/base/services/file_open_service/i_file_open_service.dart';
import 'package:codeway_image_processing/base/services/image_picker_service/i_image_picker_service.dart';
import 'package:codeway_image_processing/base/services/image_processing_service/i_image_processing_service.dart';
import 'package:codeway_image_processing/base/services/navigation_service/i_navigation_service.dart';
import 'package:codeway_image_processing/base/services/toast_service/i_toast_service.dart';
import 'package:codeway_image_processing/features/image_processing/data/repositories/i_processed_image_repository.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processed_image.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processing_type.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/source_selector_dialog/source_selector_dialog_vm.dart';

// Export generated mocks - must be before @GenerateMocks
export 'mocks.mocks.dart';

// Generate mocks with: flutter pub run build_runner build --delete-conflicting-outputs
@GenerateMocks([
  IFileStorageService,
  IFileOpenService,
  IImagePickerService,
  IImageProcessingService,
  INavigationService,
  IToastService,
  IProcessedImageRepository,
  SourceSelectorDialogVM,
])
void main() {}

// Test helpers
class TestHelpers {
  static Uint8List createTestImageBytes() {
    return Uint8List.fromList([1, 2, 3, 4, 5]);
  }

  static ProcessedImage createTestProcessedImage({
    String? id,
    ProcessingType? type,
  }) {
    return ProcessedImage(
      id: id ?? 'test-id',
      processingType: type ?? ProcessingType.face,
      originalPath: '/test/original.jpg',
      processedPath: '/test/processed.jpg',
      thumbnailPath: '/test/thumbnail.jpg',
      fileSize: 1000,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      metadata: 'Test metadata',
    );
  }
}
