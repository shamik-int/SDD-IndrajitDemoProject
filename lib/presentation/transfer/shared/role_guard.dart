import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../domain/transfer/entities/enums.dart';
import 'session_state.dart';

/// Keeps each role on its own screens (AC24, AC27, AC32). UI convenience
/// only: the repository enforces the same rules on every call.
class RoleGuard extends GetMiddleware {
  final UserRole role;

  RoleGuard(this.role);

  @override
  RouteSettings? redirect(String? route) {
    final user = Get.find<SessionState>().user.value;
    if (user == null) return const RouteSettings(name: AppRoutes.signIn);
    if (user.role != role) return const RouteSettings(name: AppRoutes.entry);
    return null;
  }
}
