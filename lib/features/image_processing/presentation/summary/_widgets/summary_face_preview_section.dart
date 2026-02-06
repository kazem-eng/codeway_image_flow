import 'package:flutter/material.dart';

import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processed_image.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/summary_model.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/_widgets/summary_before_after_comparison.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/_widgets/summary_face_thumbnail_strip.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/styles_export.dart';

/// Face preview section used in summary and mixed review.
class SummaryFacePreviewSection extends StatelessWidget {
  const SummaryFacePreviewSection({
    super.key,
    required this.model,
    required this.onSelect,
    required this.onDeleteAt,
    required this.onOpenDetail,
    this.showThumbnails = true,
  });

  final SummaryModel model;
  final void Function(int) onSelect;
  final void Function(int) onDeleteAt;
  final void Function(ProcessedImage) onOpenDetail;
  final bool showThumbnails;

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
          child: SummaryBeforeAfterComparison(
            beforeBytes: selected.originalBytes,
            afterBytes: selected.processedBytes,
            onOpenBefore: () => onOpenDetail(selected.image),
            onOpenAfter: () => onOpenDetail(selected.image),
          ),
        ),
        SizedBox(height: ImageFlowSpacing.md),

        if (showThumbnails) ...[
          SummaryFaceThumbnailStrip(
            faces: faces,
            selectedIndex: index,
            onSelect: onSelect,
            onDeleteAt: onDeleteAt,
          ),
          SizedBox(height: ImageFlowSpacing.md),
        ],
      ],
    );
  }
}
