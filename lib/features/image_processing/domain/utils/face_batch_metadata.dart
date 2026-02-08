import 'dart:convert';

/// Helpers for face batch metadata stored in [ProcessedImage.metadata].
/// Item format: "face_batch_item:{groupId}". Group format: JSON {"ids": [...]}.
class FaceBatchMetadata {
  FaceBatchMetadata._();

  static const String _itemPrefix = 'face_batch_item:';

  /// Encodes metadata for a single face in a batch (links it to [groupId]).
  static String item(String groupId) => '$_itemPrefix$groupId';

  /// True if [metadata] is the item format (single face belonging to a batch).
  static bool isBatchItem(String? metadata) {
    if (metadata == null) return false;
    return metadata.startsWith(_itemPrefix);
  }

  /// Extracts the batch group id from an item's metadata; null if not an item.
  static String? groupIdFromItem(String? metadata) {
    if (!isBatchItem(metadata)) return null;
    return metadata!.substring(_itemPrefix.length);
  }

  /// Encodes metadata for a faceBatch record: list of face [ids] in the group.
  static String group(List<String> ids) {
    return jsonEncode(<String, dynamic>{'ids': ids});
  }

  /// Parses a faceBatch record's metadata into the list of face ids; empty if invalid.
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
