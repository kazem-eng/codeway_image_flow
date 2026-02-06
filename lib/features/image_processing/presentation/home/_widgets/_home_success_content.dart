import 'package:codeway_image_processing/base/mvvm_base/base_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/home/_widgets/_empty_state.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/home/_widgets/_history_item.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/home/home_vm.dart';
import 'package:codeway_image_processing/ui_kit/components/dialog_helpers.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Home screen success state: history list or empty state.
class HomeSuccessContent extends StatelessWidget {
  const HomeSuccessContent({super.key});

  @override
  Widget build(BuildContext context) {
    void showDeleteConfirm(HomeVM vm, String id) {
      DialogHelpers.showDeleteConfirm(
        context,
        onConfirm: () => vm.deleteItem(id),
      );
    }

    return Obx(() {
      final vm = BaseViewModel.of<HomeVM>();
      final items = vm.model.items;
      if (items.isEmpty) return const EmptyState();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsGeometry.only(
              left: ImageFlowSpacing.md,
              top: MediaQuery.paddingOf(context).top + ImageFlowSpacing.md,
              bottom: ImageFlowSpacing.md,
            ),
            child: Text(
              AppStrings.homeScreenTitle,
              style: ImageFlowTextStyles.appTitle,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(
                left: ImageFlowSpacing.md,
                right: ImageFlowSpacing.md,
                top: ImageFlowSpacing.sm,
                bottom: 80,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final image = item.image;
                final isFace = image.processingType.isFace;
                final isFaceBatch = image.processingType.isFaceBatch;
                return HistoryItem(
                  image: image,
                  thumbnailBytes: null,
                  title: item.title,
                  subtitle: item.subtitle,
                  onTap: () => isFaceBatch
                      ? vm.openFaceGroup(image)
                      : (isFace
                            ? vm.navigateToDetail(image)
                            : vm.openPdf(image)),
                  onDelete: () => showDeleteConfirm(vm, image.id),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
