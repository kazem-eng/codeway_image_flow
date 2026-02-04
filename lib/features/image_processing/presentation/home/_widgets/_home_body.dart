import 'package:codeway_image_processing/base/mvvm_base/base_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/home/_widgets/_home_success_content.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/home/home_vm.dart';
import 'package:codeway_image_processing/ui_kit/components/imageflow_components_export.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Home screen body: reactive state (loading / success / error).
class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final vm = BaseViewModel.of<HomeVM>();
      return vm.state.maybeWhen<Widget>(
        loading: () => const ImageFlowLoader(message: AppStrings.loading),
        success: (_) => const HomeSuccessContent(),
        error: (exception) => ImageFlowErrorWidget(
          message: exception.toString(),
          onRetry: vm.loadHistory,
        ),
        orElse: () => const SizedBox.shrink(),
      );
    });
  }
}
