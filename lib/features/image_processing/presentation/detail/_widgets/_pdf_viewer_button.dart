import 'package:flutter/material.dart';

import 'package:codeway_image_processing/ui_kit/components/imageflow_components_export.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';

class PdfViewerButton extends StatelessWidget {
  const PdfViewerButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ImageFlowButton(label: AppStrings.openPdf, onPressed: onPressed);
  }
}
