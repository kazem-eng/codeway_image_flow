import 'package:flutter/material.dart';

import 'package:codeway_image_processing/ui_kit/components/source_selector.dart';
import 'package:codeway_image_processing/ui_kit/styles/colors_model.dart';
import 'package:codeway_image_processing/ui_kit/styles/decorations.dart';
import 'package:codeway_image_processing/ui_kit/styles/theme_data.dart';

/// Dialog to choose camera or gallery as capture source. Reused in Home and Capture.
class SourceChoiceDialog extends StatelessWidget {
  const SourceChoiceDialog({
    super.key,
    required this.onCamera,
    required this.onGallery,
  });

  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: ImageFlowSpacing.screenPadding,
      child: SourceSelector(
        onCamera: onCamera,
        onGallery: onGallery,
      ),
    );
    return Dialog(
      backgroundColor: ImageFlowColors.surface,
      shape: ImageFlowDecorations.dialogShape(),
      child: IntrinsicWidth(child: content),
    );
  }
}
