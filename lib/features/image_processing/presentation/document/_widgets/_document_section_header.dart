import 'package:flutter/material.dart';

import 'package:codeway_image_processing/ui_kit/styles/styles_export.dart';

class DocumentSectionHeader extends StatelessWidget {
  const DocumentSectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: ImageFlowTextStyles.bodyLarge),
    );
  }
}
