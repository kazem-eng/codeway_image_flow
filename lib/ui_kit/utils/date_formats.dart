import 'package:intl/intl.dart';

/// Centralized date formats to avoid hardcoded format strings throughout the codebase.
/// This enables easier maintenance, consistency, and future localization.
class DateFormats {
  DateFormats._();

  /// Date format: "MMM dd, yyyy" (e.g., "Jan 15, 2024")
  /// Used for displaying dates without time in metadata displays.
  static const String dateOnly = 'MMM dd, yyyy';

  /// Date format: "MMM dd, yyyy • HH:mm" (e.g., "Jan 15, 2024 • 14:30")
  /// Used for displaying dates with time in history lists.
  static const String dateWithTime = 'MMM dd, yyyy • HH:mm';

  /// Date format: "yyyy-MM-dd" (e.g., "2024-01-15")
  /// Used for ISO date format in file names and document titles.
  static const String isoDate = 'yyyy-MM-dd';

  /// Formats a date from milliseconds since epoch using the date-only format.
  static String formatDateOnly(int millisecondsSinceEpoch) {
    return DateFormat(
      dateOnly,
    ).format(DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch));
  }

  /// Formats a date from milliseconds since epoch using the date-with-time format.
  static String formatDateWithTime(int millisecondsSinceEpoch) {
    return DateFormat(
      dateWithTime,
    ).format(DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch));
  }

  /// Formats a DateTime using the ISO date format (yyyy-MM-dd).
  /// Example: DateTime(2024, 1, 15) -> "2024-01-15"
  static String formatIsoDate(DateTime dateTime) {
    return DateFormat(isoDate).format(dateTime);
  }

  /// Formats the current date using the ISO date format (yyyy-MM-dd).
  /// Example: "2024-01-15"
  static String formatCurrentIsoDate() {
    return formatIsoDate(DateTime.now());
  }
}
