/// Centralized file size formatting utilities to avoid hardcoded formatting logic.
/// This enables easier maintenance, consistency, and future enhancements (MB, GB support).
class FileSizeFormats {
  FileSizeFormats._();

  /// Formats file size in bytes to a human-readable string (KB).
  /// Returns "—" if [bytes] is null.
  ///
  /// Example: 1024 bytes -> "1.0 KB"
  /// Example: null -> "—"
  static String formatFileSize(int? bytes) {
    if (bytes == null) {
      return '—';
    }
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
}
