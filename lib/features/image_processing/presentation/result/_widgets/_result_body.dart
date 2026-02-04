import 'package:codeway_image_processing/base/mvvm_base/base_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/result/_widgets/_result_error_content.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/result/_widgets/_result_success_content.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/result/result_vm.dart';
import 'package:codeway_image_processing/ui_kit/components/imageflow_components_export.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Result screen body: reactive state (loading / success / error). Uses vm.model for data.
class ResultBody extends StatelessWidget {
  const ResultBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final vm = BaseViewModel.of<ResultVM>();
      return vm.state.maybeWhen<Widget>(
        loading: () => const ImageFlowLoader(message: AppStrings.loading),
        success: (data) => ResultSuccessContent(data: data),
        error: (exception) => ResultErrorContent(
          message: exception.toString(),
          onRetry: vm.loadImages,
          onDone: vm.done,
        ),
        orElse: () => const ImageFlowLoader(),
      );
    });
  }
}
