import 'package:flutter/material.dart';

import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'imageflow_components_export.dart';

/// Helper functions for showing common dialogs.
class DialogHelpers {
  DialogHelpers._();

  /// Shows a delete confirmation dialog and calls [onConfirm] if user confirms.
  /// The dialog is automatically closed after [onConfirm] completes.
  static Future<void> showDeleteConfirm(
    BuildContext context, {
    required Future<void> Function() onConfirm,
    String title = AppStrings.deleteDialogTitle,
    String content = AppStrings.deleteDialogContent,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => DeleteConfirmDialog(
        title: title,
        content: content,
        onCancel: () => Navigator.of(ctx).pop(),
        onConfirm: () async {
          Navigator.of(ctx).pop(); // Close dialog first
          await onConfirm(); // Then execute the action
        },
      ),
    );
  }
}
