import 'package:codeway_image_processing/features/image_processing/presentation/summary/summary_props.dart';
import 'package:flutter/material.dart';

import 'package:codeway_image_processing/ui_kit/styles/styles_export.dart';

/// Horizontal strip of face thumbnails with delete actions.
class SummaryFaceThumbnailStrip extends StatelessWidget {
  const SummaryFaceThumbnailStrip({
    super.key,
    required this.faces,
    required this.selectedIndex,
    required this.onSelect,
    required this.onDeleteAt,
  });

  final List<SummaryFacePreview> faces;
  final int selectedIndex;
  final void Function(int) onSelect;
  final void Function(int) onDeleteAt;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ImageFlowSizes.faceThumbnailSize,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: faces.length,
        separatorBuilder: (_, _) => SizedBox(width: ImageFlowSpacing.sm),
        itemBuilder: (context, index) {
          final item = faces[index];
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelect(index),
            child: Stack(
              children: [
                // Thumbnail with border highlight if selected
                Container(
                  decoration: ImageFlowDecorations.card(
                    border: Border.all(
                      color: isSelected
                          ? ImageFlowColors.primaryStart
                          : ImageFlowColors.border,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: ImageFlowShapes.roundedSmall(),
                    child: Image.memory(
                      item.processedBytes,
                      width: ImageFlowSizes.faceThumbnailSize,
                      height: ImageFlowSizes.faceThumbnailSize,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Delete button at top-right corner
                Positioned(
                  top: ImageFlowSizes.thumbnailDeleteOffset,
                  right: ImageFlowSizes.thumbnailDeleteOffset,
                  child: GestureDetector(
                    onTap: () => onDeleteAt(index),
                    child: Container(
                      width: ImageFlowSizes.thumbnailDeleteSize,
                      height: ImageFlowSizes.thumbnailDeleteSize,
                      decoration: const BoxDecoration(
                        color: ImageFlowColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: ImageFlowSizes.thumbnailDeleteIconSize,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
