import 'package:flutter/material.dart';
import 'package:codeway_image_processing/base/mvvm_base/base.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/summary_props.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/summary_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/_widgets/summary_body.dart';
import 'package:codeway_image_processing/setup/locator.dart';
import 'package:codeway_image_processing/ui_kit/components/imageflow_app_bar.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/styles_export.dart';

class SummaryView extends StatelessWidget {
  const SummaryView({super.key, required this.props});

  final SummaryProps props;

  @override
  Widget build(BuildContext context) {
    return BaseView<SummaryVM>(
      vmFactory: () => VMFactories.createSummaryVM(),
      initViewModel: (vm) async {
        await vm.init(props);
      },
      builder: (context, vm) => Scaffold(
        appBar: ImageFlowAppBar(
          title: AppStrings.summaryTitle,
          titleStyle: ImageFlowTextStyles.appTitle,
          titleSpacing: ImageFlowSpacing.md,
        ),
        body: const SummaryBody(),
      ),
    );
  }
}
