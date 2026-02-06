import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processing_type.dart';
import 'package:codeway_image_processing/ui_kit/components/imageflow_components_export.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/styles_export.dart';

/// Before/After image comparison.
class BeforeAfterComparison extends StatelessWidget {
  const BeforeAfterComparison({
    super.key,
    required this.beforeBytes,
    required this.afterBytes,
    this.processingType,
    this.dateMillis,
    this.fileSize,
  });

  final Uint8List beforeBytes;
  final Uint8List afterBytes;
  final ProcessingType? processingType;
  final int? dateMillis;
  final int? fileSize;

  void _openFullScreen(BuildContext context, int initialPage) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FullScreenImageViewer(
          beforeBytes: beforeBytes,
          afterBytes: afterBytes,
          initialPage: initialPage,
          processingType: processingType,
          dateMillis: dateMillis,
          fileSize: fileSize,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: ImageFlowSpacing.md,
      children: [
        Expanded(
          child: _buildPreviewCard(
            context: context,
            label: AppStrings.before,
            bytes: beforeBytes,
            innerLabel: AppStrings.original,
            onTap: () => _openFullScreen(context, 0),
          ),
        ),
        Expanded(
          child: _buildPreviewCard(
            context: context,
            label: AppStrings.after,
            bytes: afterBytes,
            innerLabel: AppStrings.blackAndWhite,
            onTap: () => _openFullScreen(context, 1),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewCard({
    required BuildContext context,
    required String label,
    required Uint8List bytes,
    required String innerLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: ImageFlowSizes.previewCardOuterMinHeight,
      ),
      padding: const EdgeInsets.all(ImageFlowSizes.cardInnerPadding),
      decoration: ImageFlowDecorations.card(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: ImageFlowSizes.previewCardMinHeight,
          ),
          decoration: ImageFlowDecorations.innerCard(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: ImageFlowSpacing.sm,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                spacing: ImageFlowSpacing.sm,
                children: [
                  Text(
                    label,
                    style: ImageFlowTextStyles.bodySmall.copyWith(
                      color: ImageFlowColors.textPrimary,
                    ),
                  ),
                  ClipRRect(
                    borderRadius: ImageFlowShapes.roundedSmall(),
                    child: Image.memory(
                      bytes,
                      fit: BoxFit.contain,
                      height: ImageFlowSizes.previewImageHeight,
                    ),
                  ),
                  Text(
                    innerLabel,
                    style: ImageFlowTextStyles.bodySmall.copyWith(
                      color: ImageFlowColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-screen image viewer with swipe support.
class _FullScreenImageViewer extends StatefulWidget {
  const _FullScreenImageViewer({
    required this.beforeBytes,
    required this.afterBytes,
    required this.initialPage,
    required this.processingType,
    required this.dateMillis,
    required this.fileSize,
  });

  final Uint8List beforeBytes;
  final Uint8List afterBytes;
  final int initialPage;
  final ProcessingType? processingType;
  final int? dateMillis;
  final int? fileSize;

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showMetadata =
        widget.processingType != null && widget.dateMillis != null;
    return Scaffold(
      backgroundColor: ImageFlowColors.background,
      appBar: ImageFlowAppBar(
        title: _currentPage == 0 ? AppStrings.original : AppStrings.filtered,
        titleStyle: ImageFlowTextStyles.fullScreenAppBarTitle,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                _buildPage(widget.beforeBytes, AppStrings.original),
                _buildPage(widget.afterBytes, AppStrings.filtered),
              ],
            ),
          ),
          if (showMetadata)
            MetadataDisplay(
              dateMillis: widget.dateMillis!,
              processingType: widget.processingType!,
              fileSize: widget.fileSize,
            ),
        ],
      ),
    );
  }

  Widget _buildPage(Uint8List bytes, String label) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(child: Image.memory(bytes, fit: BoxFit.contain)),
    );
  }
}
