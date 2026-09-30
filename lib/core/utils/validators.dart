/// Field validators shared by every screen's form validation (ADR-0001 §7,
/// §8). Client-side validation is a UX aid, never the sole security boundary
/// — the same field is re-validated at the repository/API boundary
/// (constitution.md Architectural Constraints).
class Validators {
  Validators._();

  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
  static final _phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required.';
    if (!_emailRegex.hasMatch(value.trim())) return 'Enter a valid email address.';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required.';
    if (!_phoneRegex.hasMatch(value.trim())) return 'Enter a valid phone number.';
    return null;
  }

  /// Placeholder complexity rule (employee-registration-login spec, flagged
  /// for Gate 1 as an engineering placeholder, not a final policy decision).
  static String? password(String? value) {
    const message = 'Password must be at least 8 characters and include a letter and a number.';
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < 8) return message;
    final hasLetter = value.contains(RegExp(r'[A-Za-z]'));
    final hasNumber = value.contains(RegExp(r'[0-9]'));
    if (!hasLetter || !hasNumber) return message;
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
