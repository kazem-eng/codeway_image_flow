import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:codeway_image_processing/base/mvvm_base/base_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/summary_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/_widgets/summary_document_group_section.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/_widgets/summary_face_preview_section.dart';
import 'package:codeway_image_processing/ui_kit/components/imageflow_button.dart';
import 'package:codeway_image_processing/ui_kit/components/imageflow_loader.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/styles_export.dart';

/// Summary screen body.
class SummaryBody extends StatelessWidget {
  const SummaryBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final vm = BaseViewModel.of<SummaryVM>();
      final model = vm.model;
      if (vm.state.isLoading) {
        return const ImageFlowLoader(message: AppStrings.loading);
      }

      if (model.faces.isEmpty && model.documents.isEmpty) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            ImageFlowSpacing.md,
            ImageFlowSpacing.md,
            ImageFlowSpacing.md,
            ImageFlowSpacing.lg,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.noItemsProcessed,
                style: ImageFlowTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ImageFlowSpacing.lg),
              ImageFlowButton(label: AppStrings.done, onPressed: vm.done),
            ],
          ),
        );
      }

      return ListView(
        padding: EdgeInsets.fromLTRB(
          ImageFlowSpacing.md,
          ImageFlowSpacing.md,
          ImageFlowSpacing.md,
          ImageFlowSpacing.lg,
        ),
        children: [
          if (model.documents.isNotEmpty)
            SummaryDocumentGroupSection(
              documents: model.documents,
              onOpen: vm.openDocument,
            ),
          if (model.documents.isNotEmpty)
            SizedBox(height: ImageFlowSpacing.lg),
          if (model.faces.isNotEmpty)
            SummaryFacePreviewSection(
              model: model,
              onSelect: vm.selectFace,
              onDeleteAt: vm.deleteFaceAt,
            ),
          SizedBox(height: ImageFlowSpacing.md),
          ImageFlowButton(label: AppStrings.done, onPressed: vm.done),
        ],
      );
    });
  }
}
