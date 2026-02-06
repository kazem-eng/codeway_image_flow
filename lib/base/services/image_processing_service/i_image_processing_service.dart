import 'dart:typed_data';

import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processing_type.dart';

/// Image processing service interface (face & document).
abstract class IImageProcessingService {
  Future<Uint8List> detectAndProcessFaces(Uint8List imageBytes);
  Future<Uint8List> processDocument(Uint8List imageBytes);
  Future<ProcessingType> detectContentType(Uint8List imageBytes);
  Future<Uint8List> createPdfFromImage(Uint8List imageBytes, String title);
  Future<Uint8List> createPdfFromImages(
    List<Uint8List> imageBytes,
    String title,
  );
}
