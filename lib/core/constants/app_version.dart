/// App version constant, kept in sync with `pubspec.yaml`'s `version:` field.
/// Not read dynamically via package_info_plus yet — add that at Tasks stage
/// if runtime access (e.g. an "About" screen) is required by a spec AC.
class AppVersion {
  AppVersion._();

  static const value = '1.0.0+1';
}
