import 'package:intl/intl.dart';

/// Date-only helpers for the device local date (plan PD-05). Every "today",
/// "before" and "on or after" rule in `employee-internal-transfer` compares
/// dates through these, never raw [DateTime]s with a time part.
class LocalDate {
  LocalDate._();

  static final _display = DateFormat('d MMM yyyy');
  static final _iso = DateFormat('yyyy-MM-dd');

  static DateTime dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

  /// Storage form for date-only values (`effectiveDate`, `effectiveFrom`).
  static String toIso(DateTime value) => _iso.format(dateOnly(value));

  static DateTime parseIso(String value) => dateOnly(DateTime.parse(value));

  /// Display form used in messages, e.g. "15 Oct 2026" (PD-10).
  static String format(DateTime value) => _display.format(value);

  static bool isBefore(DateTime a, DateTime b) => dateOnly(a).isBefore(dateOnly(b));

  static bool isOnOrAfter(DateTime a, DateTime b) => !isBefore(a, b);
}
