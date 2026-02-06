import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:codeway_image_processing/base/mvvm_base/base.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processed_image.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/_widgets/summary_face_preview_section.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/_widgets/summary_face_thumbnail_strip.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/summary_props.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/summary_vm.dart';
import 'package:codeway_image_processing/setup/locator.dart';
import 'package:codeway_image_processing/ui_kit/components/imageflow_loader.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/styles_export.dart';

/// Faces tab for mixed review.
class MixedReviewFacesTab extends StatefulWidget {
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
  State<MixedReviewFacesTab> createState() => _MixedReviewFacesTabState();
}

class _MixedReviewFacesTabState extends State<MixedReviewFacesTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BaseView<SummaryVM>(
      vmFactory: () => VMFactories.createSummaryVM(closeOnEmpty: false),
      initViewModel: (vm) async {
        await vm.init(
          SummaryProps(
            faces: widget.faces,
            documents: const [],
            faceGroupId: widget.faceGroupId,
            faceGroupEntity: widget.faceGroupEntity,
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
          final faceIndex =
              model.selectedFaceIndex.clamp(0, model.faces.length - 1);
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: ImageFlowSpacing.pagePadding,
                  children: [
                    SummaryFacePreviewSection(
                      model: model,
                      onSelect: viewModel.selectFace,
                      onDeleteAt: viewModel.deleteFaceAt,
                      onOpenDetail: viewModel.openDetail,
                      showThumbnails: false,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  ImageFlowSpacing.md,
                  ImageFlowSpacing.sm,
                  ImageFlowSpacing.md,
                  ImageFlowSpacing.lg,
                ),
                child: SummaryFaceThumbnailStrip(
                  faces: model.faces,
                  selectedIndex: faceIndex,
                  onSelect: viewModel.selectFace,
                  onDeleteAt: viewModel.deleteFaceAt,
                ),
              ),
            ],
          );
        });
      },
    );
  }
}
