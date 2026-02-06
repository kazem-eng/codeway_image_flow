import 'dart:convert';

/// Helpers for face batch metadata stored in ProcessedImage.metadata.
class FaceBatchMetadata {
  FaceBatchMetadata._();

  static const String _itemPrefix = 'face_batch_item:';

  static String item(String groupId) => '$_itemPrefix$groupId';

  static bool isBatchItem(String? metadata) {
    if (metadata == null) return false;
    return metadata.startsWith(_itemPrefix);
  }

  static String? groupIdFromItem(String? metadata) {
    if (!isBatchItem(metadata)) return null;
    return metadata!.substring(_itemPrefix.length);
  }

  static String group(List<String> ids) {
    return jsonEncode(<String, dynamic>{'ids': ids});
  }

  static List<String> parseGroup(String? metadata) {
    if (metadata == null || metadata.isEmpty) return <String>[];
    try {
      final decoded = jsonDecode(metadata);
      if (decoded is Map<String, dynamic> && decoded['ids'] is List) {
        return List<String>.from(decoded['ids'] as List);
      }
    } catch (_) {}
    return <String>[];
  }
}
