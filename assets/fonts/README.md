# assets/fonts/

Self-hosted Lato font files (downloaded from Google Fonts), per ADR-0001 — bundled
locally rather than fetched at runtime via the `google_fonts` package, so the app
never needs a network call for its own type.

Expected weights to place here:
- Lato-Regular.ttf
- Lato-Light.ttf
- Lato-Bold.ttf
- Lato-Italic.ttf

Declare as a local font family (`Lato`) in `pubspec.yaml` once the Flutter project
is scaffolded.
