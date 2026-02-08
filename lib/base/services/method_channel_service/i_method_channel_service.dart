import 'dart:typed_data';

/// Generic platform channel service; use for any MethodChannel (document, PDF, etc.).
abstract class IMethodChannelService {
  Future<Uint8List?> processDocument(Uint8List imageBytes);
  Future<Uint8List?> createPdfFromImage(Uint8List imageBytes, String title);
}
