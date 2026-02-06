import 'package:flutter/material.dart';

import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/colors_model.dart';
import 'package:codeway_image_processing/ui_kit/styles/theme_data.dart';

/// Reusable discard confirmation alert dialog.
class DiscardConfirmDialog extends StatelessWidget {
  const DiscardConfirmDialog({
    super.key,
    required this.onCancel,
    required this.onConfirm,
    this.title = AppStrings.discardChangesTitle,
    this.content = AppStrings.discardChangesContent,
  });

  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ImageFlowColors.surface,
      title: Text(title, style: ImageFlowTextStyles.dialogTitle),
      content: Text(content, style: ImageFlowTextStyles.dialogContent),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(
            AppStrings.cancel,
            style: ImageFlowTextStyles.dialogActionNeutral,
          ),
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text(
            AppStrings.discard,
            style: ImageFlowTextStyles.destructiveAction,
          ),
        ),
      ],
    );
  }
}
