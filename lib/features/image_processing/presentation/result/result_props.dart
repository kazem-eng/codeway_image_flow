import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processed_image.dart';

/// Arguments for result screen.
class ResultProps {
  const ResultProps({required this.processedImage});

  final ProcessedImage processedImage;
}
