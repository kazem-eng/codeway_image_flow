import 'package:flutter/material.dart';

import 'package:codeway_image_processing/features/image_processing/presentation/mixed_review/mixed_review_props.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/mixed_review/_widgets/mixed_review_documents_tab.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/mixed_review/_widgets/mixed_review_faces_tab.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/styles_export.dart';

/// Mixed review screen: documents + faces.
class MixedReviewView extends StatelessWidget {
  const MixedReviewView({super.key, required this.props});

  final MixedReviewProps props;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppStrings.summaryTitle,
            style: ImageFlowTextStyles.screenTitle,
          ),
          titleSpacing: ImageFlowSpacing.md,
          bottom: const TabBar(
            tabs: [
              Tab(text: AppStrings.documentType),
              Tab(text: AppStrings.face),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MixedReviewDocumentsTab(pages: props.pages),
            MixedReviewFacesTab(
              faces: props.faces,
              faceGroupId: props.faceGroupId,
              faceGroupEntity: props.faceGroupEntity,
            ),
          ],
        ),
      ),
    );
  }
}
