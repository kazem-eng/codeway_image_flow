import 'package:flutter/material.dart';

import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/colors_model.dart';
import 'package:codeway_image_processing/ui_kit/styles/theme_data.dart';

/// Empty history state.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: ImageFlowColors.textTertiary,
          ),
          SizedBox(height: ImageFlowSpacing.md),
          Text(
            AppStrings.noProcessedImagesYet,
            style: ImageFlowTextStyles.bodyMedium.copyWith(
              color: ImageFlowColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
