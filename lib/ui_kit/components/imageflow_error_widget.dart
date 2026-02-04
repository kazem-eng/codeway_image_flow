import 'package:flutter/material.dart';

import '../styles/colors_model.dart';
import '../styles/theme_data.dart';

/// Error display with optional retry.
class ImageFlowErrorWidget extends StatelessWidget {
  const ImageFlowErrorWidget({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: ImageFlowSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: ImageFlowColors.error),
            SizedBox(height: ImageFlowSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: ImageFlowTextStyles.bodyMedium,
            ),
            if (onRetry != null) ...[
              SizedBox(height: ImageFlowSpacing.lg),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(
                  Icons.refresh,
                  color: ImageFlowColors.primaryStart,
                ),
                label: const Text(
                  'Retry',
                  style: ImageFlowTextStyles.buttonLarge,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
