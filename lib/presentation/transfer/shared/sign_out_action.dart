import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../domain/transfer/portal/portal_contracts.dart';
import 'session_state.dart';

/// Sign-out (AC31): clears the session, then removes every route so no
/// earlier screen, controller or held data survives for the next user. If the
/// stored session cannot be cleared, the user stays where they are and is
/// told: clearing only the screens would sign them back in on the next start.
/// The message shows in a SnackBar, so every screen using this action needs a
/// Scaffold.
class SignOutAction extends StatelessWidget {
  const SignOutAction({super.key});

  Future<void> _signOut(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await Get.find<SignInService>().signOut();
    if (result.isError) {
      messenger.showSnackBar(SnackBar(content: Text(result.message!)));
      return;
    }
    Get.find<SessionState>().clear();
    Get.offAllNamed(AppRoutes.signIn);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('sign-out-button'),
      icon: const Icon(Icons.logout),
      tooltip: 'Sign out',
      onPressed: () => _signOut(context),
    );
  }
}
