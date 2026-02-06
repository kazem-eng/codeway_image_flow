import 'dart:typed_data';

/// Arguments for processing.
class ProcessingProps {
  const ProcessingProps({required this.images});

  final List<Uint8List> images;
}
