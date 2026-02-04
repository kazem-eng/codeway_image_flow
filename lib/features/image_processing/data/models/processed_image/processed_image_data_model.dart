import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processed_image.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processing_type.dart';

/// Data model for processed image (DB/storage layer).
class ProcessedImageDataModel {
  const ProcessedImageDataModel({
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
  final int processingType;
  final String originalPath;
  final String processedPath;
  final String? thumbnailPath;
  final int? fileSize;
  final int createdAt;
  final String? metadata;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'processing_type': processingType,
      'original_path': originalPath,
      'processed_path': processedPath,
      'thumbnail_path': thumbnailPath,
      'file_size': fileSize,
      'created_at': createdAt,
      'metadata': metadata,
    };
  }

  factory ProcessedImageDataModel.fromMap(Map<String, dynamic> map) {
    return ProcessedImageDataModel(
      id: map['id'] as String,
      processingType: map['processing_type'] as int,
      originalPath: map['original_path'] as String,
      processedPath: map['processed_path'] as String,
      thumbnailPath: map['thumbnail_path'] as String?,
      fileSize: map['file_size'] as int?,
      createdAt: map['created_at'] as int,
      metadata: map['metadata'] as String?,
    );
  }

  ProcessedImage toEntity() {
    return ProcessedImage(
      id: id,
      processingType: ProcessingType.fromInt(processingType),
      originalPath: originalPath,
      processedPath: processedPath,
      thumbnailPath: thumbnailPath,
      fileSize: fileSize,
      createdAt: createdAt,
      metadata: metadata,
    );
  }

  static ProcessedImageDataModel fromEntity(ProcessedImage entity) {
    return ProcessedImageDataModel(
      id: entity.id,
      processingType: entity.processingType.value,
      originalPath: entity.originalPath,
      processedPath: entity.processedPath,
      thumbnailPath: entity.thumbnailPath,
      fileSize: entity.fileSize,
      createdAt: entity.createdAt,
      metadata: entity.metadata,
    );
  }
}
