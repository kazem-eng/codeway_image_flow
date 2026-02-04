import 'package:codeway_image_processing/ui_kit/components/imageflow_components_export.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/theme_data.dart';
import 'package:flutter/material.dart';

/// Result screen error state: message, retry, and Done button.
class ResultErrorContent extends StatelessWidget {
  const ResultErrorContent({
    super.key,
    required this.message,
    required this.onRetry,
    required this.onDone,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ImageFlowSpacing.screenPadding,
      child: Column(
        spacing: ImageFlowSpacing.lg,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ImageFlowErrorWidget(message: message, onRetry: onRetry),
          ImageFlowButton(label: AppStrings.done, onPressed: onDone),
        ],
      ),
    );
  }
}
