import 'package:flutter/services.dart';

import 'i_method_channel_service.dart';

/// MethodChannel implementation for document/PDF; returns null on [PlatformException].
class MethodChannelService implements IMethodChannelService {
  MethodChannelService({required String channelName, MethodChannel? channel})
    : _channel = channel ?? MethodChannel(channelName);

  final MethodChannel _channel;

  @override
  Future<Uint8List?> processDocument(Uint8List imageBytes) async {
    try {
      return await _channel.invokeMethod<Uint8List>(
        'processDocument',
        imageBytes,
      );
    } on PlatformException {
      return null;
    }
  }

  @override
  Future<Uint8List?> createPdfFromImage(
    Uint8List imageBytes,
    String title,
  ) async {
    try {
      return await _channel.invokeMethod<Uint8List>('createPdfFromImage', {
        'bytes': imageBytes,
        'title': title,
      });
    } on PlatformException {
      return null;
    }
  }
}
