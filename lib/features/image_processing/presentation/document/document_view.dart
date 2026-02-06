import 'package:codeway_image_processing/ui_kit/styles/theme_data.dart';
import 'package:flutter/material.dart';

import 'package:codeway_image_processing/base/mvvm_base/base.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/document/_widgets/_document_body.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/document/document_props.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/document/document_vm.dart';
import 'package:codeway_image_processing/setup/locator.dart';
import 'package:codeway_image_processing/ui_kit/components/imageflow_app_bar.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';

/// Document builder view.
class DocumentView extends StatelessWidget {
  const DocumentView({super.key, required this.props});

  final DocumentProps props;

  @override
  Widget build(BuildContext context) {
    return BaseView<DocumentVM>(
      vmFactory: () => VMFactories.createDocumentVM(),
      initViewModel: (vm) async {
        vm.init(props);
      },
      builder: (context, vm) => Scaffold(
        appBar: ImageFlowAppBar(
          title: AppStrings.document,
          titleSpacing: ImageFlowSpacing.md,
        ),
        body: const DocumentBody(),
      ),
    );
  }
}
