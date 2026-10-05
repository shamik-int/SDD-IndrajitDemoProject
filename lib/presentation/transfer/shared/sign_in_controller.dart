import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/transfer/portal/portal_contracts.dart';
import 'session_state.dart';

/// Demo-level sign-in (D-01, PD-01). No sign-up: roles come from the demo
/// account data.
class SignInController extends GetxController {
  final SignInService signInService;
  final SessionState session;

  SignInController({required this.signInService, required this.session});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isSubmitting = false.obs;
  final error = RxnString();

  /// The password is hidden until the user taps the eye button.
  final obscurePassword = true.obs;

  void togglePasswordVisibility() => obscurePassword.toggle();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<bool> submit() async {
    if (isSubmitting.value) return false;
    isSubmitting.value = true;
    error.value = null;
    final result = await signInService.signIn(email: emailController.text, password: passwordController.text);
    isSubmitting.value = false;
    if (result.isError) {
      error.value = result.message;
      return false;
    }
    session.user.value = result.data;
    return true;
  }
}
