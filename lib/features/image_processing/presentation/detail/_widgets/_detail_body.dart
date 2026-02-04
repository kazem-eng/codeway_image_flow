import 'package:codeway_image_processing/base/mvvm_base/base_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/detail/_widgets/_detail_success_content.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/detail/detail_vm.dart';
import 'package:codeway_image_processing/ui_kit/components/imageflow_components_export.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Detail screen body: reactive state (loading / success / error).
class DetailBody extends StatelessWidget {
  const DetailBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final vm = BaseViewModel.of<DetailVM>();
      return vm.state.maybeWhen<Widget>(
        loading: () => const ImageFlowLoader(message: AppStrings.loading),
        success: (data) => DetailSuccessContent(data: data),
        error: (exception) => ImageFlowErrorWidget(
          message: exception.toString(),
          onRetry: vm.loadImage,
        ),
        orElse: () => const ImageFlowLoader(),
      );
    });
  }
}
