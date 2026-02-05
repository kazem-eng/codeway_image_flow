import 'dart:typed_data';

/// Model for multi-page document builder.
class MultiPageModel {
  const MultiPageModel({
    this.pages = const [],
    this.selectedIndex = 0,
    this.isProcessingPage = false,
    this.isSaving = false,
  });

  final List<DocumentPage> pages;
  final int selectedIndex;
  final bool isProcessingPage;
  final bool isSaving;

  MultiPageModel copyWith({
    List<DocumentPage>? pages,
    int? selectedIndex,
    bool? isProcessingPage,
    bool? isSaving,
  }) {
    return MultiPageModel(
      pages: pages ?? this.pages,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isProcessingPage: isProcessingPage ?? this.isProcessingPage,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

/// Represents a single scanned page.
class DocumentPage {
  const DocumentPage({
    required this.id,
    required this.originalBytes,
    required this.processedBytes,
  });

  final String id;
  final Uint8List originalBytes;
  final Uint8List processedBytes;
}
