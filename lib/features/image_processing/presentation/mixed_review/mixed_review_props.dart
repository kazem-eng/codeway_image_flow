import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processed_image.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/summary_props.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/document/document_props.dart';

/// Arguments for mixed (documents + faces) review.
class MixedReviewProps {
  const MixedReviewProps({
    required this.pages,
    required this.faces,
    this.faceGroupId,
    this.faceGroupEntity,
  });

  final List<DocumentSeedPage> pages;
  final List<SummaryFacePreview> faces;
  final String? faceGroupId;
  final ProcessedImage? faceGroupEntity;
}
