import 'dart:typed_data';

import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processed_image.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processing_step.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processing_type.dart';

class ProcessingModel {
  const ProcessingModel({
    this.items = const [],
    this.currentIndex = -1,
    this.completedCount = 0,
    this.isProcessing = false,
    this.isCompleted = false,
    this.processingStep = ProcessingStep.initializing,
  });

  final List<ProcessingItem> items;
  final int currentIndex;
  final int completedCount;
  final bool isProcessing;
  final bool isCompleted;
  final ProcessingStep processingStep;

  int get totalCount => items.length;
  int get successCount =>
      items.where((item) => item.status == ProcessingItemStatus.success).length;
  int get failedCount =>
      items.where((item) => item.status == ProcessingItemStatus.failed).length;

  double get progress {
    if (items.isEmpty) return 0;
    return completedCount / items.length;
  }

  ProcessingModel copyWith({
    List<ProcessingItem>? items,
    int? currentIndex,
    int? completedCount,
    bool? isProcessing,
    bool? isCompleted,
    ProcessingStep? processingStep,
  }) {
    return ProcessingModel(
      items: items ?? this.items,
      currentIndex: currentIndex ?? this.currentIndex,
      completedCount: completedCount ?? this.completedCount,
      isProcessing: isProcessing ?? this.isProcessing,
      isCompleted: isCompleted ?? this.isCompleted,
      processingStep: processingStep ?? this.processingStep,
    );
  }
}

enum ProcessingItemStatus { queued, processing, success, failed }

class ProcessingItem {
  const ProcessingItem({
    required this.id,
    required this.originalBytes,
    this.status = ProcessingItemStatus.queued,
    this.type,
    this.result,
    this.errorMessage,
  });

  final String id;
  final Uint8List originalBytes;
  final ProcessingItemStatus status;
  final ProcessingType? type;
  final ProcessedImage? result;
  final String? errorMessage;

  ProcessingItem copyWith({
    ProcessingItemStatus? status,
    ProcessingType? type,
    ProcessedImage? result,
    String? errorMessage,
  }) {
    return ProcessingItem(
      id: id,
      originalBytes: originalBytes,
      status: status ?? this.status,
      type: type ?? this.type,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
