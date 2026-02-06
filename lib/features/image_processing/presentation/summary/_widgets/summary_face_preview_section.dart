import 'package:flutter/material.dart';

import 'package:codeway_image_processing/features/image_processing/presentation/summary/summary_model.dart';
import 'package:codeway_image_processing/ui_kit/components/before_after_comparison.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/styles_export.dart';

/// Face preview section used in summary and mixed review.
class SummaryFacePreviewSection extends StatelessWidget {
  const SummaryFacePreviewSection({
    super.key,
    required this.model,
    required this.onSelect,
    required this.onDeleteAt,
  });

  final SummaryModel model;
  final void Function(int) onSelect;
  final void Function(int) onDeleteAt;

  @override
  Widget build(BuildContext context) {
    final faces = model.faces;
    final index = model.selectedFaceIndex.clamp(0, faces.length - 1);
    final selected = faces[index];
    final previewHeight =
        MediaQuery.sizeOf(context).height *
        ImageFlowSizes.facePreviewHeightFactor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.face, style: ImageFlowTextStyles.bodyLarge),
        SizedBox(height: ImageFlowSpacing.sm),
        SizedBox(
          height: previewHeight,
          child: BeforeAfterComparison(
            beforeBytes: selected.originalBytes,
            afterBytes: selected.processedBytes,
            processingType: selected.image.processingType,
            dateMillis: selected.image.createdAt,
            fileSize: selected.image.fileSize,
          ),
        ),
        SizedBox(height: ImageFlowSpacing.md),
        SizedBox(
          height: ImageFlowSizes.faceThumbnailSize,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: faces.length,
            separatorBuilder: (_, _) => SizedBox(width: ImageFlowSpacing.sm),
            itemBuilder: (context, idx) {
              final item = faces[idx];
              final isSelected = idx == index;
              return GestureDetector(
                onTap: () => onSelect(idx),
                child: Stack(
                  children: [
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
                    Positioned(
                      top: ImageFlowSizes.thumbnailDeleteOffset,
                      right: ImageFlowSizes.thumbnailDeleteOffset,
                      child: GestureDetector(
                        onTap: () => onDeleteAt(idx),
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
        ),
        SizedBox(height: ImageFlowSpacing.md),
      ],
    );
  }
}
