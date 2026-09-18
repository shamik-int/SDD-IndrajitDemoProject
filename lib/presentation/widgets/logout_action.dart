import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../domain/usecases/logout_employee.dart';

/// AppBar action shared by every screen a logged-in employee can land on
/// (status and submission) — clears the session and routes back through
/// `AppEntryPage`, which will now correctly resolve to Login (AC8).
class LogoutAction extends StatelessWidget {
  const LogoutAction({super.key});

  Future<void> _logout() async {
    await Get.find<LogoutEmployee>()();
    Get.offNamed(AppRoutes.placeholder);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('logout-button'),
      icon: const Icon(Icons.logout),
      tooltip: 'Log Out',
      onPressed: _logout,
    );
  }
}
