import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:codeway_image_processing/base/mvvm_base/base.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processed_image.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/_widgets/summary_face_preview_section.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/summary_props.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/summary_vm.dart';
import 'package:codeway_image_processing/setup/locator.dart';
import 'package:codeway_image_processing/ui_kit/components/imageflow_loader.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/styles_export.dart';

/// Faces tab for mixed review.
class MixedReviewFacesTab extends StatelessWidget {
  const MixedReviewFacesTab({
    super.key,
    required this.faces,
    required this.faceGroupId,
    required this.faceGroupEntity,
  });

  final List<SummaryFacePreview> faces;
  final String? faceGroupId;
  final ProcessedImage? faceGroupEntity;

  @override
  Widget build(BuildContext context) {
    return BaseView<SummaryVM>(
      vmFactory: () => VMFactories.createSummaryVM(closeOnEmpty: false),
      initViewModel: (vm) async {
        await vm.init(
          SummaryProps(
            faces: faces,
            documents: const [],
            faceGroupId: faceGroupId,
            faceGroupEntity: faceGroupEntity,
          ),
        );
      },
      builder: (context, vm) {
        return Obx(() {
          final viewModel = BaseViewModel.of<SummaryVM>();
          final model = viewModel.model;
          if (viewModel.state.isLoading) {
            return const ImageFlowLoader(message: AppStrings.loading);
          }
          if (model.faces.isEmpty) {
            return Center(
              child: Text(
                AppStrings.noItemsProcessed,
                style: ImageFlowTextStyles.bodyMedium,
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
              SummaryFacePreviewSection(
                model: model,
                onSelect: viewModel.selectFace,
                onDeleteAt: viewModel.deleteFaceAt,
              ),
            ],
          );
        });
      },
    );
  }
}
