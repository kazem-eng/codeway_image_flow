import 'package:flutter/material.dart';

import 'package:codeway_image_processing/ui_kit/components/imageflow_button.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/styles_export.dart';

class DocumentActionRow extends StatelessWidget {
  const DocumentActionRow({
    super.key,
    required this.isBusy,
    required this.onAddPage,
    required this.onExport,
    required this.isSaving,
  });

  final bool isBusy;
  final VoidCallback onAddPage;
  final Future<void> Function() onExport;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: ImageFlowSpacing.md,
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isBusy ? null : onAddPage,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: ImageFlowColors.primaryStart),
              foregroundColor: ImageFlowColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: ImageFlowShapes.roundedMedium(),
              ),
              minimumSize: const Size.fromHeight(ImageFlowSizes.buttonHeight),
            ),
            child: Text(AppStrings.addPage),
          ),
        ),
        Expanded(
          child: ImageFlowButton(
            label: AppStrings.savePdf,
            onPressed: isBusy ? null : onExport,
            isLoading: isSaving,
          ),
        ),
      ],
    );
  }
}
