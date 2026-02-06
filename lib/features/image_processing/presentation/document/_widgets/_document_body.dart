import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:codeway_image_processing/base/mvvm_base/base_vm.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/document/document_model.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/document/document_vm.dart';
import 'package:codeway_image_processing/ui_kit/components/dialog_helpers.dart';
import 'package:codeway_image_processing/ui_kit/components/imageflow_button.dart';
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
              padding: EdgeInsets.fromLTRB(
                ImageFlowSpacing.md,
                ImageFlowSpacing.md,
                ImageFlowSpacing.md,
                ImageFlowSpacing.lg,
              ),
              child: isLandscape
                  ? Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: _PreviewCard(page: selectedPage),
                        ),
                        SizedBox(width: ImageFlowSpacing.md),
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              _SectionHeader(
                                title:
                                    '${AppStrings.pagesLabel} (${pages.length})',
                              ),
                              SizedBox(height: ImageFlowSpacing.sm),
                              Expanded(
                                child: ReorderableListView.builder(
                                  buildDefaultDragHandles: false,
                                  onReorder: vm.reorderPages,
                                  itemCount: pages.length,
                                  itemBuilder: (context, index) {
                                    final page = pages[index];
                                    return _PageTile(
                                      key: ValueKey(page.id),
                                      index: index,
                                      page: page,
                                      isSelected: index == selectedIndex,
                                      onSelect: () => vm.selectPage(index),
                                      onRemove: () => vm.removePage(index),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: ImageFlowSpacing.md),
                              _ActionRow(
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
                        _PreviewCard(
                          page: selectedPage,
                          height: ImageFlowSizes.documentPreviewHeight,
                        ),
                        SizedBox(height: ImageFlowSpacing.lg),
                        _SectionHeader(
                          title:
                              '${AppStrings.pagesLabel} (${pages.length})',
                        ),
                        SizedBox(height: ImageFlowSpacing.sm),
                        Expanded(
                          child: ReorderableListView.builder(
                            buildDefaultDragHandles: false,
                            onReorder: vm.reorderPages,
                            itemCount: pages.length,
                            itemBuilder: (context, index) {
                              final page = pages[index];
                              return _PageTile(
                                key: ValueKey(page.id),
                                index: index,
                                page: page,
                                isSelected: index == selectedIndex,
                                onSelect: () => vm.selectPage(index),
                                onRemove: () => vm.removePage(index),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: ImageFlowSpacing.md),
                        _ActionRow(
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

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.page, this.height});

  final DocumentPage page;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(ImageFlowSizes.cardInnerPadding),
      decoration: ImageFlowDecorations.card(),
      child: ClipRRect(
        borderRadius: ImageFlowShapes.roundedMedium(),
        child: Image.memory(page.processedBytes, fit: BoxFit.contain),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: ImageFlowTextStyles.bodyLarge),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.isBusy,
    required this.onAddPage,
    required this.onExport,
    required this.isSaving,
  });

  final bool isBusy;
  final VoidCallback onAddPage;
  final Future<void> Function() onExport;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isBusy ? null : onAddPage,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: ImageFlowColors.primaryStart,
              ),
              foregroundColor: ImageFlowColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: ImageFlowShapes.roundedMedium(),
              ),
              minimumSize: const Size.fromHeight(
                ImageFlowSizes.buttonHeight,
              ),
            ),
            child: Text(AppStrings.addPage),
          ),
        ),
        SizedBox(width: ImageFlowSpacing.md),
        Expanded(
          child: ImageFlowButton(
            label: AppStrings.savePdf,
            onPressed: isBusy ? null : onExport,
            isLoading: isSaving,
          ),
        ),
      ],
    );
  }
}

class _PageTile extends StatelessWidget {
  const _PageTile({
    super.key,
    required this.index,
    required this.page,
    required this.isSelected,
    required this.onSelect,
    required this.onRemove,
  });

  final int index;
  final DocumentPage page;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: ImageFlowSpacing.sm),
      decoration: ImageFlowDecorations.card(
        border: Border.all(
          color: isSelected
              ? ImageFlowColors.primaryStart
              : ImageFlowColors.border,
        ),
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: ImageFlowShapes.roundedMedium(),
        child: Padding(
          padding: const EdgeInsets.all(ImageFlowSpacing.sm),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: ImageFlowShapes.roundedSmall(),
                child: Image.memory(
                  page.processedBytes,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: ImageFlowSpacing.sm),
              Expanded(
                child: Text(
                  '${AppStrings.pageLabel} ${index + 1}',
                  style: ImageFlowTextStyles.bodyMedium,
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(
                  Icons.delete_outline,
                  color: ImageFlowColors.textSecondary,
                ),
              ),
              ReorderableDragStartListener(
                index: index,
                child: const Icon(
                  Icons.drag_handle,
                  color: ImageFlowColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
