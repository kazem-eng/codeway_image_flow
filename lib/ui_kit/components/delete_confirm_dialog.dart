import 'package:flutter/material.dart';

import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/colors_model.dart';
import 'package:codeway_image_processing/ui_kit/styles/theme_data.dart';

/// Reusable delete confirmation alert dialog.
class DeleteConfirmDialog extends StatelessWidget {
  const DeleteConfirmDialog({
    super.key,
    required this.onCancel,
    required this.onConfirm,
    this.title = 'Delete',
    this.content = 'Remove this item from history?',
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
            AppStrings.delete,
            style: ImageFlowTextStyles.destructiveAction,
          ),
        ),
      ],
    );
  }
}
