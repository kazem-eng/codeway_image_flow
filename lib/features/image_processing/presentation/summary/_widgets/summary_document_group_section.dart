import 'package:flutter/material.dart';

import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processed_image.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/summary_props.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/styles_export.dart';

/// Document list section for summary.
class SummaryDocumentGroupSection extends StatelessWidget {
  const SummaryDocumentGroupSection({
    super.key,
    required this.documents,
    required this.onOpen,
  });

  final List<SummaryDocumentPreview> documents;
  final void Function(ProcessedImage) onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.documentType, style: ImageFlowTextStyles.bodyLarge),
        SizedBox(height: ImageFlowSpacing.sm),
        for (var i = 0; i < documents.length; i++)
          SummaryDocumentTile(
            index: i,
            document: documents[i],
            onTap: () => onOpen(documents[i].image),
          ),
      ],
    );
  }
}

/// Document tile for summary.
class SummaryDocumentTile extends StatelessWidget {
  const SummaryDocumentTile({
    super.key,
    required this.index,
    required this.document,
    required this.onTap,
  });

  final int index;
  final SummaryDocumentPreview document;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                  document.previewBytes,
                  width: ImageFlowSizes.batchItemThumbnailSize,
                  height: ImageFlowSizes.batchItemThumbnailSize,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: ImageFlowSpacing.sm),
              Expanded(
                child: Text(
                  '${AppStrings.documentType} ${index + 1}',
                  style: ImageFlowTextStyles.bodyMedium,
                ),
              ),
              const Icon(
                Icons.picture_as_pdf,
                color: ImageFlowColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
