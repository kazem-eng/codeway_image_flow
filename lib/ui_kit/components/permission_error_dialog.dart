import 'package:flutter/material.dart';

import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/colors_model.dart';
import 'package:codeway_image_processing/ui_kit/styles/theme_data.dart';

/// Reusable permission required alert dialog.
class PermissionErrorDialog extends StatelessWidget {
  const PermissionErrorDialog({
    super.key,
    required this.message,
    required this.onOpenSettings,
  });

  final String message;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ImageFlowColors.surface,
      title: Text(
        'Permission required',
        style: ImageFlowTextStyles.dialogTitle,
      ),
      content: Text(message, style: ImageFlowTextStyles.dialogContent),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            AppStrings.cancel,
            style: ImageFlowTextStyles.dialogActionNeutral,
          ),
        ),
        TextButton(
          onPressed: onOpenSettings,
          child: Text(
            AppStrings.openSettings,
            style: ImageFlowTextStyles.dialogAction,
          ),
        ),
      ],
    );
  }
}
