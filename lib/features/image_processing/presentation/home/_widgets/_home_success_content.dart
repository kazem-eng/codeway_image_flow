import 'package:codeway_image_processing/base/mvvm_base/base_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/home/_widgets/_empty_state.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/home/_widgets/_history_item.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/home/home_vm.dart';
import 'package:codeway_image_processing/ui_kit/components/dialog_helpers.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/theme_data.dart';
import 'package:codeway_image_processing/ui_kit/utils/date_formats.dart';
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
      final history = vm.model.history;
      if (history.isEmpty) return const EmptyState();
      return ListView.builder(
        padding: EdgeInsets.only(
          left: ImageFlowSpacing.md,
          right: ImageFlowSpacing.md,
          top: ImageFlowSpacing.sm,
          bottom: 80,
        ),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final image = history[index];
          final dateStr = DateFormats.formatDateWithTime(image.createdAt);
          final isFace = image.processingType.isFace;
          final title = isFace
              ? AppStrings.faceResultScreenTitle
              : (image.metadata ?? AppStrings.pdfDocument);
          return HistoryItem(
            image: image,
            thumbnailBytes: null,
            title: title,
            subtitle: dateStr,
            onTap: () =>
                isFace ? vm.navigateToDetail(image) : vm.openPdf(image),
            onDelete: () => showDeleteConfirm(vm, image.id),
          );
        },
      );
    });
  }
}
