import 'package:codeway_image_processing/base/mvvm_base/base.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processed_image.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/result/_widgets/_result_body.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/result/result_vm.dart';
import 'package:codeway_image_processing/setup/locator.dart';
import 'package:codeway_image_processing/ui_kit/components/imageflow_app_bar.dart';
import 'package:flutter/material.dart';

/// Result screen view. Receives [processedImage] as prop; VM is created via [BaseView].
class ResultView extends StatelessWidget {
  const ResultView({super.key, required this.processedImage});

  final ProcessedImage processedImage;

  @override
  Widget build(BuildContext context) {
    return BaseView<ResultVM>(
      vmFactory: () => VMFactories.createResultVM(),
      initViewModel: (vm) async {
        await vm.init(processedImage);
      },
      builder: (context, vm) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            vm.done();
          }
        },
        child: Scaffold(
          appBar: ImageFlowAppBar(title: vm.screenTitle),
          body: const ResultBody(),
        ),
      ),
    );
  }
}
