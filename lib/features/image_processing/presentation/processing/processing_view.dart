import 'package:flutter/material.dart';
import 'package:codeway_image_processing/base/mvvm_base/base.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/processing/processing_props.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/processing/processing_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/processing/_widgets/processing_body.dart';
import 'package:codeway_image_processing/setup/locator.dart';
import 'package:codeway_image_processing/ui_kit/components/imageflow_app_bar.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/styles_export.dart';

class ProcessingView extends StatelessWidget {
  const ProcessingView({super.key, required this.props});

  final ProcessingProps props;

  @override
  Widget build(BuildContext context) {
    return BaseView<ProcessingVM>(
      vmFactory: () => VMFactories.createProcessingVM(),
      initViewModel: (vm) async {
        vm.init(props.images);
        await vm.startProcessing();
      },
      builder: (context, vm) => Scaffold(
        appBar: ImageFlowAppBar(
          title: AppStrings.processingTitle,
          titleStyle: ImageFlowTextStyles.appTitle,
          titleSpacing: ImageFlowSpacing.md,
        ),
        body: const ProcessingBody(),
      ),
    );
  }
}
