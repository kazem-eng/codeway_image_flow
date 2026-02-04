import 'package:codeway_image_processing/base/mvvm_base/base_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/result/_widgets/_before_after_comparison.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/result/_widgets/_document_result.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/result/result_model.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/result/result_vm.dart';
import 'package:codeway_image_processing/ui_kit/components/imageflow_components_export.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/theme_data.dart';
import 'package:flutter/material.dart';

/// Result screen success state: face comparison or document card.
class ResultSuccessContent extends StatelessWidget {
  const ResultSuccessContent({super.key, required this.data});

  final ResultModel data;

  @override
  Widget build(BuildContext context) {
    final vm = BaseViewModel.of<ResultVM>();
    final processedImage = data.processedImage;

    // Return loader if processed image is null
    if (processedImage == null) return const ImageFlowLoader();

    // Face result
    if (processedImage.processingType.isFace) {
      final orig = data.originalImage;
      final proc = data.processedImageBytes;
      if (orig != null && proc != null) {
        return Padding(
          padding: ImageFlowSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: BeforeAfterComparison(
                  beforeBytes: orig,
                  afterBytes: proc,
                ),
              ),
              ImageFlowButton(label: AppStrings.done, onPressed: vm.done),
            ],
          ),
        );
      }
    }

    // Document result
    return DocumentResultCard(
      documentTitle: data.documentTitle,
      onOpenPdf: vm.openPdf,
    );
  }
}
