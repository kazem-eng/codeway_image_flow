import 'package:flutter/material.dart';

import 'package:codeway_image_processing/features/image_processing/presentation/document/document_model.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/document/_widgets/_document_page_tile.dart';

class DocumentPageList extends StatelessWidget {
  const DocumentPageList({
    super.key,
    required this.pages,
    required this.selectedIndex,
    required this.onSelect,
    required this.onRemove,
    required this.onReorder,
  });

  final List<DocumentPage> pages;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final ValueChanged<int> onRemove;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      onReorder: onReorder,
      itemCount: pages.length,
      itemBuilder: (context, index) {
        final page = pages[index];
        return DocumentPageTile(
          key: ValueKey(page.id),
          index: index,
          page: page,
          isSelected: index == selectedIndex,
          onSelect: () => onSelect(index),
          onRemove: () => onRemove(index),
        );
      },
    );
  }
}
