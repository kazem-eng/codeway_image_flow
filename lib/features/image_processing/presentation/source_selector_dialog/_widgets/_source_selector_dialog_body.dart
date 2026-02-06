import 'package:codeway_image_processing/base/mvvm_base/base_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/source_selector_dialog/source_selector_dialog_vm.dart';
import 'package:codeway_image_processing/ui_kit/components/imageflow_components_export.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Source selector body: shows loader when processing.
class SourceSelectorDialogBody extends StatelessWidget {
  const SourceSelectorDialogBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final vm = BaseViewModel.of<SourceSelectorDialogVM>();
      return vm.state.maybeWhen<Widget>(
        success: (data) => data.isProcessing
            ? ImageFlowLoader(message: AppStrings.loading)
            : const SizedBox.shrink(),
        orElse: () => const SizedBox.shrink(),
      );
    });
  }
}
