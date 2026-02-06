import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/styles_export.dart';

/// Side-by-side before/after comparison for face previews.
class SummaryBeforeAfterComparison extends StatelessWidget {
  const SummaryBeforeAfterComparison({
    super.key,
    required this.beforeBytes,
    required this.afterBytes,
    required this.onOpenBefore,
    required this.onOpenAfter,
  });

  final Uint8List beforeBytes;
  final Uint8List afterBytes;
  final VoidCallback onOpenBefore;
  final VoidCallback onOpenAfter;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: ImageFlowSpacing.md,
      children: [
        Expanded(
          child: _SummaryPreviewCard(
            label: AppStrings.before,
            bytes: beforeBytes,
            innerLabel: AppStrings.original,
            onTap: onOpenBefore,
          ),
        ),
        Expanded(
          child: _SummaryPreviewCard(
            label: AppStrings.after,
            bytes: afterBytes,
            innerLabel: AppStrings.blackAndWhite,
            onTap: onOpenAfter,
          ),
        ),
      ],
    );
  }
}

class _SummaryPreviewCard extends StatelessWidget {
  const _SummaryPreviewCard({
    required this.label,
    required this.bytes,
    required this.innerLabel,
    required this.onTap,
  });

  final String label;
  final Uint8List bytes;
  final String innerLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: ImageFlowSizes.previewCardOuterMinHeight,
      ),
      padding: const EdgeInsets.all(ImageFlowSizes.cardInnerPadding),
      decoration: ImageFlowDecorations.card(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: ImageFlowSizes.previewCardMinHeight,
          ),
          decoration: ImageFlowDecorations.innerCard(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: ImageFlowSpacing.sm,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                spacing: ImageFlowSpacing.sm,
                children: [
                  Text(
                    label,
                    style: ImageFlowTextStyles.bodySmall.copyWith(
                      color: ImageFlowColors.textPrimary,
                    ),
                  ),
                  ClipRRect(
                    borderRadius: ImageFlowShapes.roundedSmall(),
                    child: Image.memory(
                      bytes,
                      fit: BoxFit.contain,
                      height: ImageFlowSizes.previewImageHeight,
                    ),
                  ),
                  Text(
                    innerLabel,
                    style: ImageFlowTextStyles.bodySmall.copyWith(
                      color: ImageFlowColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
