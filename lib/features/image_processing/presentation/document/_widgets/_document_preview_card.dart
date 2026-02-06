import 'package:flutter/material.dart';

import 'package:codeway_image_processing/features/image_processing/presentation/document/document_model.dart';
import 'package:codeway_image_processing/ui_kit/styles/styles_export.dart';

class DocumentPreviewCard extends StatelessWidget {
  const DocumentPreviewCard({super.key, required this.page, this.height});

  final DocumentPage page;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(ImageFlowSizes.cardInnerPadding),
      decoration: ImageFlowDecorations.card(),
      child: ClipRRect(
        borderRadius: ImageFlowShapes.roundedMedium(),
        child: Image.memory(page.processedBytes, fit: BoxFit.contain),
      ),
    );
  }
}
