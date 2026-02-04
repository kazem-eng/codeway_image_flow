import 'dart:typed_data';

import '../../../features/image_processing/domain/entities/processed_image/processed_image.dart';

/// File storage service interface.
abstract class IFileStorageService {
  Future<String> saveProcessedImage(Uint8List imageBytes, String fileName);
  Future<String> savePdf(Uint8List pdfBytes, String fileName);
  Future<String> saveThumbnail(Uint8List imageBytes, String fileName);
  Future<Uint8List> loadImage(String filePath);
  Future<Uint8List?> loadPdfBytes(String filePath);
  Future<void> deleteFile(String filePath);
  Future<void> deleteProcessedImageFiles(ProcessedImage image);
  Future<String> getStorageDirectory(String subdirectory);
}
