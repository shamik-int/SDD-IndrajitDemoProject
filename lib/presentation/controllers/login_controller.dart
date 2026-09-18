import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/login_input.dart';
import '../../domain/usecases/login_employee.dart';

/// Drives the Login screen — AC6 (successful login), AC7 (a single generic
/// "invalid email or password" error covers both "no such email" and "wrong
/// password", so a failed attempt never reveals which was wrong).
class LoginController extends GetxController {
  final LoginEmployee loginEmployee;

  LoginController({required this.loginEmployee});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isSubmitting = false.obs;
  final formError = RxnString();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<bool> submit() async {
    isSubmitting.value = true;
    formError.value = null;

    final result = await loginEmployee(
      LoginInput(email: emailController.text, password: passwordController.text),
    );
    isSubmitting.value = false;

    if (result.isError) {
      formError.value = result.message;
      return false;
    }

    return true;
  }
}
