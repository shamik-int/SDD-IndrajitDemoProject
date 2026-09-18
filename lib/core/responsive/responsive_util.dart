import 'package:flutter/material.dart';

/// ScreenUtil (bootstrapped in `lib/app/app.dart` via `ScreenUtilInit`) scales
/// dimensions against a design reference size — it does not re-layout. This
/// helper adds the phone/tablet distinction ADR-0001 §5 calls for.
class ResponsiveUtil {
  ResponsiveUtil._();

  /// Tablet breakpoint: shortest side >= 600dp (standard Material breakpoint).
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;

  static bool isMobile(BuildContext context) => !isTablet(context);
}
