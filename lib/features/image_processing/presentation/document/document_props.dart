import 'dart:typed_data';

/// Seed page for document builder.
class DocumentSeedPage {
  const DocumentSeedPage({
    required this.originalBytes,
    required this.processedBytes,
  });

  final Uint8List originalBytes;
  final Uint8List processedBytes;
}

/// Arguments for document builder.
class DocumentProps {
  const DocumentProps({required this.pages});

  factory DocumentProps.single({
    required Uint8List originalBytes,
    required Uint8List processedBytes,
  }) {
    return DocumentProps(
      pages: [
        DocumentSeedPage(
          originalBytes: originalBytes,
          processedBytes: processedBytes,
        ),
      ],
    );
  }

  final List<DocumentSeedPage> pages;
}
