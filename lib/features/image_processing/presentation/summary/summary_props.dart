import 'dart:typed_data';

import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processed_image.dart';

class SummaryProps {
  const SummaryProps({
    required this.faces,
    required this.documents,
    this.faceGroupId,
    this.faceGroupEntity,
  });

  final List<SummaryFacePreview> faces;
  final List<SummaryDocumentPreview> documents;
  final String? faceGroupId;
  final ProcessedImage? faceGroupEntity;
}

/// Preview data for a processed face item.
class SummaryFacePreview {
  const SummaryFacePreview({
    required this.image,
    required this.originalBytes,
    required this.processedBytes,
  });

  final ProcessedImage image;
  final Uint8List originalBytes;
  final Uint8List processedBytes;
}

/// Preview data for a processed document item.
class SummaryDocumentPreview {
  const SummaryDocumentPreview({
    required this.image,
    required this.previewBytes,
  });

  final ProcessedImage image;
  final Uint8List previewBytes;
}
