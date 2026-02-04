import 'package:flutter/material.dart';

import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/colors_model.dart';
import 'package:codeway_image_processing/ui_kit/styles/decorations.dart';
import 'package:codeway_image_processing/ui_kit/styles/theme_data.dart';

class ProcessingProgressIndicator extends StatelessWidget {
  const ProcessingProgressIndicator({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(AppStrings.processing, style: ImageFlowTextStyles.progressLabel),
        SizedBox(height: ImageFlowSpacing.lg),
        ClipRRect(
          borderRadius: ImageFlowDecorations.progressBarClip(),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: ImageFlowColors.surfaceVariant,
            valueColor: const AlwaysStoppedAnimation<Color>(
              ImageFlowColors.primaryStart,
            ),
            minHeight: ImageFlowSizes.progressBarHeight,
          ),
        ),
      ],
    );
  }
}
