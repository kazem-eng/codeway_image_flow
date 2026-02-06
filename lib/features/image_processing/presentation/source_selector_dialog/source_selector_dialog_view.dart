import 'package:codeway_image_processing/base/mvvm_base/base.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/source_selector_dialog/_widgets/_source_selector_dialog_body.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/source_selector_dialog/source_selector_dialog_vm.dart';
import 'package:codeway_image_processing/setup/locator.dart';
import 'package:codeway_image_processing/ui_kit/components/imageflow_components_export.dart';
import 'package:flutter/material.dart';

/// Source selector dialog host view. VM is created via [BaseView]; no props.
class SourceSelectorDialogView extends StatelessWidget {
  const SourceSelectorDialogView({super.key});

  Future<void> _showSourceDialog(BuildContext context) async {
    final vm = BaseViewModel.of<SourceSelectorDialogVM>();
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (ctx) => SourceChoiceDialog(
        onCamera: () {
          Navigator.of(ctx).pop();
          vm.captureFromCamera();
        },
        onGallery: () {
          Navigator.of(ctx).pop();
          vm.captureBatchFromGallery();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<SourceSelectorDialogVM>(
      vmFactory: () => VMFactories.createSourceSelectorDialogVM(),
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
          body: const SafeArea(child: SourceSelectorDialogBody()),
        );
      },
    );
  }
}
