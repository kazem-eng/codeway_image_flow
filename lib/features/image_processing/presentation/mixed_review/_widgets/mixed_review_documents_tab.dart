import 'package:flutter/material.dart';

import 'package:codeway_image_processing/base/mvvm_base/base.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/document/_widgets/_document_body.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/document/document_props.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/document/document_vm.dart';
import 'package:codeway_image_processing/setup/locator.dart';

/// Documents tab for mixed review.
class MixedReviewDocumentsTab extends StatelessWidget {
  const MixedReviewDocumentsTab({super.key, required this.pages});

  final List<DocumentSeedPage> pages;

  @override
  Widget build(BuildContext context) {
    return BaseView<DocumentVM>(
      vmFactory: () => VMFactories.createDocumentVM(),
      initViewModel: (vm) async {
        vm.init(DocumentProps(pages: pages));
      },
      builder: (context, vm) => const DocumentBody(),
    );
  }
}
