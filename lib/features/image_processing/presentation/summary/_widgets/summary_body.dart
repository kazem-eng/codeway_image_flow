import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:codeway_image_processing/base/mvvm_base/base_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/summary_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/_widgets/summary_document_group_section.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/_widgets/summary_face_preview_section.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/_widgets/summary_face_thumbnail_strip.dart';
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
      final hasDocuments = model.documents.isNotEmpty;
      final hasFaces = model.faces.isNotEmpty;

      if (vm.state.isLoading) {
        return const ImageFlowLoader(message: AppStrings.loading);
      }

      if (!hasDocuments && !hasFaces) {
        return Padding(
          padding: ImageFlowSpacing.pagePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: ImageFlowSpacing.lg,
            children: [
              Text(
                AppStrings.noItemsProcessed,
                style: ImageFlowTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              ImageFlowButton(label: AppStrings.done, onPressed: vm.done),
            ],
          ),
        );
      }

      if (hasFaces) {
        final faceIndex = model.selectedFaceIndex.clamp(
          0,
          model.faces.length - 1,
        );
        final bottomBar = Padding(
          padding: EdgeInsets.fromLTRB(
            ImageFlowSpacing.md,
            ImageFlowSpacing.sm,
            ImageFlowSpacing.md,
            ImageFlowSpacing.lg,
          ),
          child: Column(
            children: [
              SummaryFaceThumbnailStrip(
                faces: model.faces,
                selectedIndex: faceIndex,
                onSelect: vm.selectFace,
                onDeleteAt: vm.deleteFaceAt,
              ),
              SizedBox(height: ImageFlowSpacing.md),
              ImageFlowButton(label: AppStrings.done, onPressed: vm.done),
            ],
          ),
        );

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: ImageFlowSpacing.pagePadding,
                children: [
                  if (hasDocuments)
                    SummaryDocumentGroupSection(
                      documents: model.documents,
                      onOpen: vm.openDocument,
                    ),
                  if (hasDocuments) SizedBox(height: ImageFlowSpacing.lg),
                  SummaryFacePreviewSection(
                    model: model,
                    onSelect: vm.selectFace,
                    onDeleteAt: vm.deleteFaceAt,
                    onOpenDetail: vm.openDetail,
                    showThumbnails: false,
                  ),
                ],
              ),
            ),
            bottomBar,
          ],
        );
      }

      return ListView(
        padding: ImageFlowSpacing.pagePadding,
        children: [
          if (hasDocuments)
            SummaryDocumentGroupSection(
              documents: model.documents,
              onOpen: vm.openDocument,
            ),
          SizedBox(height: ImageFlowSpacing.md),
          ImageFlowButton(label: AppStrings.done, onPressed: vm.done),
        ],
      );
    });
  }
}
