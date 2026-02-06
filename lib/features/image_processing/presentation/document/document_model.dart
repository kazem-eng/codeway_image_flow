import 'dart:typed_data';

/// Model for document builder.
class DocumentModel {
  const DocumentModel({
    this.pages = const [],
    this.selectedIndex = 0,
    this.isProcessingPage = false,
    this.isSaving = false,
    this.hasUnsavedChanges = false,
  });

  final List<DocumentPage> pages;
  final int selectedIndex;
  final bool isProcessingPage;
  final bool isSaving;
  final bool hasUnsavedChanges;

  DocumentModel copyWith({
    List<DocumentPage>? pages,
    int? selectedIndex,
    bool? isProcessingPage,
    bool? isSaving,
    bool? hasUnsavedChanges,
  }) {
    return DocumentModel(
      pages: pages ?? this.pages,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isProcessingPage: isProcessingPage ?? this.isProcessingPage,
      isSaving: isSaving ?? this.isSaving,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
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
