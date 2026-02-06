import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:codeway_image_processing/base/mvvm_base/base_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/processing/processing_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/processing/_widgets/processing_item_tile.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/processing/_widgets/processing_progress_card.dart';
import 'package:codeway_image_processing/ui_kit/components/imageflow_loader.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/styles_export.dart';

/// Processing screen body.
class ProcessingBody extends StatelessWidget {
  const ProcessingBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final vm = BaseViewModel.of<ProcessingVM>();
      final model = vm.model;
      final items = model.items;

      if (items.isEmpty) {
        return const ImageFlowLoader(message: AppStrings.preparing);
      }

      final total = model.totalCount;
      final completed = model.completedCount;
      final progress = model.progress.clamp(0.0, 1.0).toDouble();
      final currentLabel = model.isCompleted
          ? AppStrings.processingCompleted
          : AppStrings.processing;
      final stepText = model.processingStep.displayText;

      return Padding(
        padding: ImageFlowSpacing.pagePadding,
        child: Column(
          children: [
            ProcessingProgressCard(
              title: currentLabel,
              completed: completed,
              total: total,
              progress: progress,
              successCount: model.successCount,
              failedCount: model.failedCount,
              isCompleted: model.isCompleted,
              stepText: stepText,
            ),
            SizedBox(height: ImageFlowSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppStrings.summaryTitle,
                style: ImageFlowTextStyles.bodyLarge,
              ),
            ),
            SizedBox(height: ImageFlowSpacing.sm),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ProcessingItemTile(
                    item: item,
                    index: index,
                    onTap: null,
                  );
                },
              ),
            ),
            SizedBox(height: ImageFlowSpacing.md),
          ],
        ),
      );
    });
  }
}
