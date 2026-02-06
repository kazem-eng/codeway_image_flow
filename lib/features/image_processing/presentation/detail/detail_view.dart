import 'package:codeway_image_processing/base/mvvm_base/base.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/detail/_widgets/_detail_body.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/detail/detail_vm.dart';
import 'package:codeway_image_processing/setup/locator.dart';
import 'package:codeway_image_processing/ui_kit/components/imageflow_components_export.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/colors_model.dart';
import 'package:codeway_image_processing/ui_kit/styles/theme_data.dart';
import 'package:flutter/material.dart';

class DetailView extends StatelessWidget {
  const DetailView({super.key, required this.imageId});

  final String imageId;

  @override
  Widget build(BuildContext context) {
    return BaseView<DetailVM>(
      vmFactory: () => VMFactories.createDetailVM(),
      initViewModel: (vm) async {
        await vm.init(imageId);
      },
      builder: (context, vm) => Scaffold(
        appBar: ImageFlowAppBar(
          title: AppStrings.detailScreenTitle,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: ImageFlowSpacing.md),
              child: IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: ImageFlowColors.error,
                ),
                onPressed: () => DialogHelpers.showDeleteConfirm(
                  context,
                  onConfirm: vm.deleteImage,
                ),
              ),
            ),
          ],
        ),
        body: const DetailBody(),
      ),
    );
  }
}
