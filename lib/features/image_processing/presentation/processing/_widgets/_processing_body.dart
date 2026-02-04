import 'package:codeway_image_processing/base/mvvm_base/base_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/processing/_widgets/_processing_success_content.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/processing/processing_vm.dart';
import 'package:codeway_image_processing/ui_kit/components/imageflow_components_export.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Processing screen body: reactive state (loading / success / error).
class ProcessingBody extends StatelessWidget {
  const ProcessingBody({super.key});

  @override
  Widget build(BuildContext context) {
    Widget loadingWidget() =>
        const Center(child: ImageFlowLoader(message: AppStrings.preparing));

    return Obx(() {
      final vm = BaseViewModel.of<ProcessingVM>();
      return vm.state.maybeWhen<Widget>(
        loading: () => loadingWidget(),
        success: (data) => ProcessingSuccessContent(data: data),
        error: (exception) =>
            Center(child: ImageFlowErrorWidget(message: exception.toString())),
        orElse: () => loadingWidget(),
      );
    });
  }
}
