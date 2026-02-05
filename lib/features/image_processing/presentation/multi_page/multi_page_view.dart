import 'package:flutter/material.dart';

import 'package:codeway_image_processing/base/mvvm_base/base.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/multi_page/_widgets/_multi_page_body.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/multi_page/multi_page_props.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/multi_page/multi_page_vm.dart';
import 'package:codeway_image_processing/setup/locator.dart';
import 'package:codeway_image_processing/ui_kit/components/imageflow_app_bar.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';

/// Multi-page document builder view.
class MultiPageView extends StatelessWidget {
  const MultiPageView({super.key, required this.props});

  final MultiPageProps props;

  @override
  Widget build(BuildContext context) {
    return BaseView<MultiPageVM>(
      vmFactory: () => VMFactories.createMultiPageVM(),
      initViewModel: (vm) async {
        vm.init(props);
      },
      builder: (context, vm) => Scaffold(
        appBar: const ImageFlowAppBar(title: AppStrings.document),
        body: const MultiPageBody(),
      ),
    );
  }
}
