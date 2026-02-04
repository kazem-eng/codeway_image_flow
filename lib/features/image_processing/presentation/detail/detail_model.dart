import 'dart:typed_data';

import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processed_image.dart';

/// Detail screen model. Holds props (imageId) and loaded state (image, bytes, pdfPath).
class DetailModel {
  const DetailModel({
    this.imageId,
    this.image,
    this.originalBytes,
    this.processedBytes,
    this.pdfPath,
  });

  /// From route props; preserved across loading/error.
  final String? imageId;

  /// Loaded entity; set on success.
  final ProcessedImage? image;
  final Uint8List? originalBytes;
  final Uint8List? processedBytes;
  final String? pdfPath;

  DetailModel copyWith({
    String? imageId,
    ProcessedImage? image,
    Uint8List? originalBytes,
    Uint8List? processedBytes,
    String? pdfPath,
  }) {
    return DetailModel(
      imageId: imageId ?? this.imageId,
      image: image ?? this.image,
      originalBytes: originalBytes ?? this.originalBytes,
      processedBytes: processedBytes ?? this.processedBytes,
      pdfPath: pdfPath ?? this.pdfPath,
    );
  }
}
