import 'package:codeway_image_processing/features/image_processing/presentation/processing/_widgets/_progress_indicator.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/processing/processing_model.dart';
import 'package:codeway_image_processing/ui_kit/components/imageflow_components_export.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/decorations.dart';
import 'package:codeway_image_processing/ui_kit/styles/theme_data.dart';
import 'package:flutter/material.dart';

/// Processing screen success state: image, progress, step text.
class ProcessingSuccessContent extends StatelessWidget {
  const ProcessingSuccessContent({super.key, required this.data});

  final ProcessingModel data;

  @override
  Widget build(BuildContext context) {
    final image = data.originalImage;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Display image or loader
        if (image != null)
          Flexible(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.8,
                ),
                child: ClipRRect(
                  borderRadius: ImageFlowShapes.roundedLarge(),
                  child: Image.memory(image, fit: BoxFit.contain),
                ),
              ),
            ),
          )
        else
          const ImageFlowLoader(message: AppStrings.preparing),

        // Spacing and progress
        SizedBox(height: ImageFlowSpacing.lg),
        ProcessingProgressIndicator(progress: data.progress),
        SizedBox(height: ImageFlowSpacing.sm),

        // Current processing step text
        Text(
          data.processingStep.displayText,
          style: ImageFlowTextStyles.statusText,
        ),
      ],
    );
  }
}
