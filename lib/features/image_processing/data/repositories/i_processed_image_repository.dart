import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processed_image.dart';

/// Repository interface for processed images.
abstract class IProcessedImageRepository {
  Future<void> init();
  Future<List<ProcessedImage>> getAll();
  Future<ProcessedImage?> getById(String id);
  Future<String> add(ProcessedImage image);
  Future<void> delete(String id);
}
