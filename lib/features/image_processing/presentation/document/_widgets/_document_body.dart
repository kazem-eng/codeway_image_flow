import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:codeway_image_processing/base/mvvm_base/base_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/document/document_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/document/_widgets/_document_action_row.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/document/_widgets/_document_page_list.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/document/_widgets/_document_preview_card.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/document/_widgets/_document_section_header.dart';
import 'package:codeway_image_processing/ui_kit/components/dialog_helpers.dart';
import 'package:codeway_image_processing/ui_kit/components/imageflow_loader.dart';
import 'package:codeway_image_processing/ui_kit/components/source_choice_dialog.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/styles_export.dart';

/// Document builder body.
class DocumentBody extends StatelessWidget {
  const DocumentBody({super.key});

  void _showSourceDialog(BuildContext context, DocumentVM vm) {
    showDialog<void>(
      context: context,
      builder: (_) => SourceChoiceDialog(
        onCamera: () {
          Navigator.of(context).pop();
          vm.addPage(ImageSource.camera);
        },
        onGallery: () {
          Navigator.of(context).pop();
          vm.addPagesFromGallery();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final vm = BaseViewModel.of<DocumentVM>();
      final model = vm.model;
      final pages = model.pages;

      if (pages.isEmpty) {
        return const Center(child: ImageFlowLoader());
      }

      final selectedIndex = model.selectedIndex.clamp(0, pages.length - 1);
      final selectedPage = pages[selectedIndex];
      final isBusy = model.isProcessingPage || model.isSaving;
      final isLandscape =
          MediaQuery.of(context).orientation == Orientation.landscape;

      return PopScope(
        canPop: !model.hasUnsavedChanges || model.isSaving,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          if (!model.hasUnsavedChanges || model.isSaving) return;
          final shouldDiscard = await DialogHelpers.showDiscardConfirm(context);
          if (shouldDiscard && context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: Stack(
          children: [
            Padding(
              padding: ImageFlowSpacing.pagePadding,
              child: isLandscape
                  ? Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: DocumentPreviewCard(page: selectedPage),
                        ),
                        SizedBox(width: ImageFlowSpacing.md),
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              DocumentSectionHeader(
                                title:
                                    '${AppStrings.pagesLabel} (${pages.length})',
                              ),
                              SizedBox(height: ImageFlowSpacing.sm),
                              Expanded(
                                child: DocumentPageList(
                                  pages: pages,
                                  selectedIndex: selectedIndex,
                                  onSelect: vm.selectPage,
                                  onRemove: vm.removePage,
                                  onReorder: vm.reorderPages,
                                ),
                              ),
                              SizedBox(height: ImageFlowSpacing.md),
                              DocumentActionRow(
                                isBusy: isBusy,
                                onAddPage: () =>
                                    _showSourceDialog(context, vm),
                                onExport: vm.exportPdf,
                                isSaving: model.isSaving,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        DocumentPreviewCard(
                          page: selectedPage,
                          height: ImageFlowSizes.documentPreviewHeight,
                        ),
                        SizedBox(height: ImageFlowSpacing.lg),
                        DocumentSectionHeader(
                          title:
                              '${AppStrings.pagesLabel} (${pages.length})',
                        ),
                        SizedBox(height: ImageFlowSpacing.sm),
                        Expanded(
                          child: DocumentPageList(
                            pages: pages,
                            selectedIndex: selectedIndex,
                            onSelect: vm.selectPage,
                            onRemove: vm.removePage,
                            onReorder: vm.reorderPages,
                          ),
                        ),
                        SizedBox(height: ImageFlowSpacing.md),
                        DocumentActionRow(
                          isBusy: isBusy,
                          onAddPage: () => _showSourceDialog(context, vm),
                          onExport: vm.exportPdf,
                          isSaving: model.isSaving,
                        ),
                      ],
                    ),
            ),
            if (model.isProcessingPage)
              Positioned.fill(
                child: Container(
                  color: ImageFlowColors.background.withValues(alpha: 0.75),
                  child: const Center(
                    child: ImageFlowLoader(message: AppStrings.processing),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
