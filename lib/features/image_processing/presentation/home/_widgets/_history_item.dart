import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processed_image.dart';
import 'package:codeway_image_processing/ui_kit/styles/styles_export.dart';

class HistoryItem extends StatelessWidget {
  const HistoryItem({
    super.key,
    required this.image,
    this.thumbnailBytes,
    required this.onTap,
    required this.title,
    required this.subtitle,
    this.onDelete,
  });

  final ProcessedImage image;
  final Uint8List? thumbnailBytes;
  final VoidCallback onTap;
  final String title;
  final String subtitle;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isFace = image.processingType.isFace;
    final iconColor = isFace
        ? ImageFlowColors.accentPink
        : ImageFlowColors.accentPurple;

    return Container(
      margin: const EdgeInsets.only(bottom: ImageFlowSizes.itemBottomMargin),
      decoration: ImageFlowDecorations.card(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: ImageFlowShapes.roundedMedium(),
          child: Padding(
            padding: ImageFlowSpacing.cardPadding,
            child: Row(
              children: [
                Container(
                  width: ImageFlowSizes.iconContainer,
                  height: ImageFlowSizes.iconContainer,
                  decoration: ImageFlowDecorations.gradientIcon(
                    color: iconColor,
                  ),
                  child: Icon(
                    isFace ? Icons.face : Icons.picture_as_pdf,
                    color: ImageFlowColors.textPrimary,
                    size: ImageFlowSizes.iconSmall,
                  ),
                ),
                SizedBox(width: ImageFlowSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: ImageFlowTextStyles.bodyLarge),
                      SizedBox(height: ImageFlowSpacing.xs),
                      Text(subtitle, style: ImageFlowTextStyles.bodySmall),
                    ],
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: ImageFlowColors.textTertiary,
                    ),
                    onPressed: onDelete,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
