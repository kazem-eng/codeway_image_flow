import 'dart:typed_data';

import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processing_step.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processing_type.dart';

/// Processing screen model.
class ProcessingModel {
  const ProcessingModel({
    this.originalImage,
    this.processingStep = ProcessingStep.initializing,
    this.progress = 0.0,
    this.processingType,
  });

  final Uint8List? originalImage;
  final ProcessingStep processingStep;
  final double progress;
  final ProcessingType? processingType;

  ProcessingModel copyWith({
    Uint8List? originalImage,
    ProcessingStep? processingStep,
    double? progress,
    ProcessingType? processingType,
    bool clearOriginalImage = false,
  }) {
    return ProcessingModel(
      originalImage: clearOriginalImage
          ? null
          : (originalImage ?? this.originalImage),
      processingStep: processingStep ?? this.processingStep,
      progress: progress ?? this.progress,
      processingType: processingType ?? this.processingType,
    );
  }
}
