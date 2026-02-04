import 'dart:typed_data';

import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processed_image.dart';

/// Result screen model. Holds props (processedImage) and loaded state.
class ResultModel {
  const ResultModel({
    this.processedImage,
    this.originalImage,
    this.processedImageBytes,
    this.pdfPath,
    this.documentTitle,
  });

  /// Entity from route props; set when VM is created, preserved across loading/error.
  final ProcessedImage? processedImage;
  final Uint8List? originalImage;
  final Uint8List? processedImageBytes;
  final String? pdfPath;
  final String? documentTitle;

  ResultModel copyWith({
    ProcessedImage? processedImage,
    Uint8List? originalImage,
    Uint8List? processedImageBytes,
    String? pdfPath,
    String? documentTitle,
    bool clearOriginalImage = false,
    bool clearProcessedImage = false,
  }) {
    return ResultModel(
      processedImage: processedImage ?? this.processedImage,
      originalImage: clearOriginalImage
          ? null
          : (originalImage ?? this.originalImage),
      processedImageBytes: clearProcessedImage
          ? null
          : (processedImageBytes ?? this.processedImageBytes),
      pdfPath: pdfPath ?? this.pdfPath,
      documentTitle: documentTitle ?? this.documentTitle,
    );
  }
}
