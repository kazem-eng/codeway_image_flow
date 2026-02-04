import 'package:codeway_image_processing/base/mvvm_base/base_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/capture/capture_vm.dart';
import 'package:codeway_image_processing/ui_kit/components/imageflow_components_export.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Capture screen body: shows loader when processing.
class CaptureBody extends StatelessWidget {
  const CaptureBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final vm = BaseViewModel.of<CaptureVM>();
      return vm.state.maybeWhen<Widget>(
        success: (data) => data.isProcessing
            ? ImageFlowLoader(message: AppStrings.loading)
            : const SizedBox.shrink(),
        orElse: () => const SizedBox.shrink(),
      );
    });
  }
}
