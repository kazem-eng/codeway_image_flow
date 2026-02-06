import 'package:flutter/material.dart';

import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/styles_export.dart';

/// Progress card for batch processing.
class ProcessingProgressCard extends StatelessWidget {
  const ProcessingProgressCard({
    super.key,
    required this.title,
    required this.completed,
    required this.total,
    required this.progress,
    required this.successCount,
    required this.failedCount,
    required this.isCompleted,
    required this.stepText,
  });

  final String title;
  final int completed;
  final int total;
  final double progress;
  final int successCount;
  final int failedCount;
  final bool isCompleted;
  final String stepText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ImageFlowSizes.cardInnerPadding),
      decoration: ImageFlowDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: ImageFlowTextStyles.bodyLarge),
          SizedBox(height: ImageFlowSpacing.sm),
          LinearProgressIndicator(
            value: progress,
            minHeight: ImageFlowSizes.progressBarHeightLarge,
            backgroundColor: ImageFlowColors.surfaceVariant,
            valueColor: const AlwaysStoppedAnimation<Color>(
              ImageFlowColors.primaryStart,
            ),
            borderRadius: BorderRadius.circular(
              ImageFlowSpacing.borderRadiusSmall,
            ),
          ),
          SizedBox(height: ImageFlowSpacing.sm),
          Text(stepText, style: ImageFlowTextStyles.statusText),
          SizedBox(height: ImageFlowSpacing.sm),
          Text(
            '$completed / $total',
            style: ImageFlowTextStyles.bodyMedium,
          ),
          if (isCompleted)
            Padding(
              padding: const EdgeInsets.only(top: ImageFlowSpacing.xs),
              child: Text(
                '$successCount ${AppStrings.processingCompleted}, '
                '$failedCount ${AppStrings.processingFailed}',
                style: ImageFlowTextStyles.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}
