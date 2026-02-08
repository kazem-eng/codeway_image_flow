/// Helpers for formatting document metadata for display in the UI.
/// Normalizes document title metadata for display.
/// Converts "Document 2024-01-15 - 3 pages" to "Document - 3 pages".
/// If [metadata] is null or empty, returns it unchanged (caller should substitute a default).
String normalizeDocumentTitleForDisplay(String? metadata, String prefix) {
  if (metadata == null || metadata.isEmpty) return metadata ?? '';
  // Match: prefix + whitespace + YYYY-MM-DD + " - " at start; replace with "prefix - "
  final escaped = RegExp.escape(prefix);
  final pattern = RegExp('^$escaped\\s\\d{4}-\\d{2}-\\d{2}\\s-\\s');
  return metadata.replaceFirst(pattern, '$prefix - ');
}
