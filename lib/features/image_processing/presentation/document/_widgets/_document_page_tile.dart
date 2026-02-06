import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:flutter/material.dart';

import 'package:codeway_image_processing/features/image_processing/presentation/document/document_model.dart';
import 'package:codeway_image_processing/ui_kit/styles/styles_export.dart';

class DocumentPageTile extends StatelessWidget {
  const DocumentPageTile({
    super.key,
    required this.index,
    required this.page,
    required this.isSelected,
    required this.onSelect,
    required this.onRemove,
  });

  final int index;
  final DocumentPage page;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: ImageFlowSpacing.sm),
      decoration: ImageFlowDecorations.card(
        border: Border.all(
          color: isSelected
              ? ImageFlowColors.primaryStart
              : ImageFlowColors.border,
        ),
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: ImageFlowShapes.roundedMedium(),
        child: Padding(
          padding: const EdgeInsets.all(ImageFlowSpacing.sm),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: ImageFlowShapes.roundedSmall(),
                child: Image.memory(
                  page.processedBytes,
                  width: ImageFlowSizes.batchItemThumbnailSize,
                  height: ImageFlowSizes.batchItemThumbnailSize,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: ImageFlowSpacing.sm),
              Expanded(
                child: Text(
                  '${AppStrings.pageLabel} ${index + 1}',
                  style: ImageFlowTextStyles.bodyMedium,
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(
                  Icons.delete_outline,
                  color: ImageFlowColors.textSecondary,
                ),
              ),
              ReorderableDragStartListener(
                index: index,
                child: const Icon(
                  Icons.drag_handle,
                  color: ImageFlowColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
