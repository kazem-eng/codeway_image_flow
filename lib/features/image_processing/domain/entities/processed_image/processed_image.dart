import 'processing_type.dart';

/// Domain entity for a processed image record.
class ProcessedImage {
  const ProcessedImage({
    required this.id,
    required this.processingType,
    required this.originalPath,
    required this.processedPath,
    this.thumbnailPath,
    this.fileSize,
    required this.createdAt,
    this.metadata,
  });

  final String id;
  final ProcessingType processingType;
  final String originalPath;
  final String processedPath;
  final String? thumbnailPath;
  final int? fileSize;
  final int createdAt;
  final String? metadata;
}
