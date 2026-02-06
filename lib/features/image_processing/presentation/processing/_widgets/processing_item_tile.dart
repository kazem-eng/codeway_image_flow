import 'package:flutter/material.dart';

import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processing_type.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/processing/processing_model.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/styles_export.dart';

/// List tile for a batch processing item.
class ProcessingItemTile extends StatelessWidget {
  const ProcessingItemTile({
    super.key,
    required this.item,
    required this.index,
    this.onTap,
  });

  final ProcessingItem item;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusLabel = _statusLabel(item.status);
    final statusColor = _statusColor(item.status);
    final typeLabel = _typeLabel(item.type);

    return Container(
      margin: const EdgeInsets.only(bottom: ImageFlowSizes.itemBottomMargin),
      decoration: ImageFlowDecorations.card(
        border: Border.all(color: ImageFlowColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: ImageFlowShapes.roundedMedium(),
        child: Padding(
          padding: const EdgeInsets.all(ImageFlowSpacing.sm),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: ImageFlowShapes.roundedSmall(),
                child: Image.memory(
                  item.originalBytes,
                  width: ImageFlowSizes.batchItemThumbnailSize,
                  height: ImageFlowSizes.batchItemThumbnailSize,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: ImageFlowSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppStrings.itemLabel} ${index + 1}',
                      style: ImageFlowTextStyles.bodyMedium,
                    ),
                    if (typeLabel != null)
                      Text(
                        typeLabel,
                        style: ImageFlowTextStyles.bodySmall,
                      ),
                    if (item.errorMessage != null)
                      Text(
                        item.errorMessage!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ImageFlowTextStyles.bodySmall,
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ImageFlowSpacing.sm,
                  vertical: ImageFlowSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: ImageFlowShapes.roundedSmall(),
                ),
                child: Text(
                  statusLabel,
                  style: ImageFlowTextStyles.bodySmall.copyWith(
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(ProcessingItemStatus status) {
    switch (status) {
      case ProcessingItemStatus.queued:
        return AppStrings.processingQueued;
      case ProcessingItemStatus.processing:
        return AppStrings.processing;
      case ProcessingItemStatus.success:
        return AppStrings.processingCompleted;
      case ProcessingItemStatus.failed:
        return AppStrings.processingFailed;
    }
  }

  Color _statusColor(ProcessingItemStatus status) {
    switch (status) {
      case ProcessingItemStatus.queued:
        return ImageFlowColors.textTertiary;
      case ProcessingItemStatus.processing:
        return ImageFlowColors.warning;
      case ProcessingItemStatus.success:
        return ImageFlowColors.success;
      case ProcessingItemStatus.failed:
        return ImageFlowColors.error;
    }
  }

  String? _typeLabel(ProcessingType? type) {
    if (type == null) return null;
    return type.isFace ? AppStrings.face : AppStrings.documentType;
  }
}
