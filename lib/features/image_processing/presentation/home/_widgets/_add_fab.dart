import 'package:codeway_image_processing/base/mvvm_base/base_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/home/home_vm.dart';
import 'package:codeway_image_processing/ui_kit/components/imageflow_components_export.dart';
import 'package:flutter/material.dart';

import 'package:codeway_image_processing/ui_kit/styles/colors_model.dart';
import 'package:codeway_image_processing/ui_kit/styles/decorations.dart';

/// FAB for adding new image.
class AddFab extends StatelessWidget {
  const AddFab({super.key});

  Future<void> _showSourceDialog(BuildContext context) async {
    final vm = BaseViewModel.of<HomeVM>();
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (ctx) => SourceChoiceDialog(
        onCamera: () {
          Navigator.of(ctx).pop(); // Close dialog first
          vm.captureFromCamera();
        },
        onGallery: () {
          Navigator.of(ctx).pop(); // Close dialog first
          vm.captureFromGallery();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ImageFlowDecorations.fab(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showSourceDialog(context),
          borderRadius: BorderRadius.circular(ImageFlowSizes.fabBorderRadius),
          child: SizedBox(
            width: ImageFlowSizes.fabSize,
            height: ImageFlowSizes.fabSize,
            child: Icon(
              Icons.add,
              color: ImageFlowColors.textPrimary,
              size: ImageFlowSizes.iconMedium,
            ),
          ),
        ),
      ),
    );
  }
}
