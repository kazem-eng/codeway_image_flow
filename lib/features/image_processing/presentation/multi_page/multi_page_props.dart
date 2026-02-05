import 'dart:typed_data';

/// Arguments for multi-page document builder.
class MultiPageProps {
  const MultiPageProps({
    required this.originalBytes,
    required this.processedBytes,
  });

  final Uint8List originalBytes;
  final Uint8List processedBytes;
}
