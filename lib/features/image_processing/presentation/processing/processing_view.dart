import 'dart:typed_data';

import 'package:codeway_image_processing/base/mvvm_base/base.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/processing/_widgets/_processing_body.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/processing/processing_vm.dart';
import 'package:codeway_image_processing/setup/locator.dart';
import 'package:codeway_image_processing/ui_kit/styles/theme_data.dart';
import 'package:flutter/material.dart';

/// Processing screen view. Receives [imageBytes] as optional prop; VM is created via [BaseView].
class ProcessingView extends StatelessWidget {
  const ProcessingView({super.key, this.imageBytes});

  final Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    return BaseView<ProcessingVM>(
      vmFactory: () => VMFactories.createProcessingVM(),
      initViewModel: (vm) async {
        vm.init(imageBytes);
        await vm.startProcessing();
      },
      builder: (context, vm) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: ImageFlowSpacing.screenPadding,
            child: const ProcessingBody(),
          ),
        ),
      ),
    );
  }
}
