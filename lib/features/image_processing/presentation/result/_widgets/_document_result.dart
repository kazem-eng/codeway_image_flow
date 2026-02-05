import 'package:flutter/material.dart';

import 'package:codeway_image_processing/ui_kit/components/imageflow_components_export.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/styles_export.dart';

/// Document/PDF result card.
class DocumentResultCard extends StatelessWidget {
  const DocumentResultCard({
    super.key,
    required this.documentTitle,
    required this.onOpenPdf,
  });

  final String? documentTitle;
  final VoidCallback onOpenPdf;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ImageFlowSpacing.screenPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          Container(
            padding: const EdgeInsets.all(ImageFlowSizes.cardOuterPadding),
            decoration: ImageFlowDecorations.pdfCard(),
            child: Center(
              child: Text(
                AppStrings.pdf,
                style: ImageFlowTextStyles.pdfCardTitle,
              ),
            ),
          ),
          SizedBox(height: ImageFlowSpacing.md),
          Text(
            documentTitle ?? AppStrings.document,
            style: ImageFlowTextStyles.bodyLarge.copyWith(
              color: ImageFlowColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ImageFlowSpacing.xl),
          Spacer(),
          SizedBox(
            width: double.infinity,
            child: ImageFlowButton(
              label: AppStrings.openPdf,
              onPressed: onOpenPdf,
            ),
          ),
        ],
      ),
    );
  }
}
