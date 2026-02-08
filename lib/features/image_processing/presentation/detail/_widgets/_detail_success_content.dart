import 'package:flutter/material.dart';

import 'package:codeway_image_processing/base/mvvm_base/base_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/detail/_widgets/_pdf_viewer_button.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/detail/_widgets/_swipe_image.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/detail/detail_model.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/detail/detail_vm.dart';
import 'package:codeway_image_processing/ui_kit/components/imageflow_components_export.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/theme_data.dart';

/// Detail screen success state: image(s), PDF button, metadata.
class DetailSuccessContent extends StatelessWidget {
  const DetailSuccessContent({super.key, required this.data});

  final DetailModel data;

  @override
  Widget build(BuildContext context) {
    final vm = BaseViewModel.of<DetailVM>();
    final image = data.image;
    if (image == null) {
      return ImageFlowErrorWidget(message: AppStrings.itemNotFound);
    }

    final original = data.originalBytes;
    final processed = data.processedBytes;
    if (original == null) {
      return const ImageFlowLoader();
    }

    return Column(
      children: [
        Expanded(
          child: image.processingType.isFace
              ? PageView(
                  children: [
                    SwipeImage(
                      bytes: processed ?? original,
                      label: AppStrings.filtered,
                    ),
                    SwipeImage(bytes: original, label: AppStrings.original),
                  ],
                )
              : InteractiveViewer(
                  child: Center(
                    child: Image.memory(original, fit: BoxFit.contain),
                  ),
                ),
        ),
        if (image.processingType.isDocument)
          Padding(
            padding: ImageFlowSpacing.screenPadding,
            child: PdfViewerButton(onPressed: vm.openPdf),
          ),
        MetadataDisplay(
          dateMillis: image.createdAt,
          processingType: image.processingType,
          fileSize: image.fileSize,
        ),
      ],
    );
  }
}
