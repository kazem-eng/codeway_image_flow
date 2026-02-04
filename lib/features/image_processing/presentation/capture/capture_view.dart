import 'package:codeway_image_processing/base/mvvm_base/base.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/capture/_widgets/_capture_body.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/capture/capture_vm.dart';
import 'package:codeway_image_processing/setup/locator.dart';
import 'package:codeway_image_processing/ui_kit/components/imageflow_components_export.dart';
import 'package:flutter/material.dart';

/// Capture screen view. VM is created via [BaseView]; no props.
class CaptureView extends StatelessWidget {
  const CaptureView({super.key});

  Future<void> _showSourceDialog(BuildContext context) async {
    final vm = BaseViewModel.of<CaptureVM>();
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
    return BaseView<CaptureVM>(
      vmFactory: () => VMFactories.createCaptureVM(),
      builder: (context, vm) {
        if (vm.model.showSourceDialog) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            vm.markSourceDialogShown();
            _showSourceDialog(context);
          });
        }
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: const SafeArea(child: CaptureBody()),
        );
      },
    );
  }
}
