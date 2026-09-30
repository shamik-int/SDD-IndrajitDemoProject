import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../domain/transfer/portal/portal_contracts.dart';
import 'session_state.dart';

/// Sign-out (AC31): clears the session, then removes every route so no
/// earlier screen, controller or held data survives for the next user.
class SignOutAction extends StatelessWidget {
  const SignOutAction({super.key});

  Future<void> _signOut() async {
    await Get.find<SignInService>().signOut();
    Get.find<SessionState>().clear();
    Get.offAllNamed(AppRoutes.signIn);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('sign-out-button'),
      icon: const Icon(Icons.logout),
      tooltip: 'Sign out',
      onPressed: _signOut,
    );
  }
}
