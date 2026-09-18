/// Static message copy shared across the app (ADR-0001 §7). Feature-specific
/// copy for `employee-internal-transfer` screens is added here once its spec
/// and tasks are approved — no per-feature duplicate string tables.
class AppStrings {
  AppStrings._();

  static const appName = 'One-Point Employee Portal';
  static const genericErrorMessage = 'Something went wrong. Please try again.';
  static const noConnectionMessage =
      'You appear to be offline. Check your connection and try again.';
}
