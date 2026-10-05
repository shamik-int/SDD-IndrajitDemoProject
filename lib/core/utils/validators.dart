/// Field validators shared by every screen's form validation (ADR-0001 §7,
/// §8). Client-side validation is a UX aid, never the sole security boundary
/// — the same field is re-validated at the repository/API boundary
/// (constitution.md Architectural Constraints).
class Validators {
  Validators._();

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  /// A selection from a reference list (employee-internal-transfer OP01 error 1).
  static String? requiredSelection(String? value, {required String message}) =>
      (value == null || value.trim().isEmpty) ? message : null;

  /// A date strictly after [today], compared as dates (OP01 errors 2 and 3).
  static String? futureDate(
    DateTime? value, {
    required DateTime today,
    required String missing,
    required String notFuture,
  }) {
    if (value == null) return missing;
    final day = DateTime(value.year, value.month, value.day);
    final base = DateTime(today.year, today.month, today.day);
    return day.isAfter(base) ? null : notFuture;
  }

  static String? maxLength(String? value, int max, {required String message}) =>
      (value != null && value.length > max) ? message : null;
}
