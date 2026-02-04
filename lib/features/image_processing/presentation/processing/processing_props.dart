import 'dart:typed_data';

/// Arguments for processing screen.
class ProcessingProps {
  const ProcessingProps({required this.imageBytes});

  final Uint8List imageBytes;
}
