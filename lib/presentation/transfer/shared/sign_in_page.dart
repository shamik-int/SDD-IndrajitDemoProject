import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/transfer_messages.dart';
import 'sign_in_controller.dart';

class SignInPage extends GetView<SignInController> {
  const SignInPage({super.key});

  Future<void> _submit() async {
    if (await controller.submit()) Get.offAllNamed(AppRoutes.entry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in'), automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(TransferMessages.pleaseSignIn),
            const SizedBox(height: 16),
            TextField(
              key: const Key('sign-in-email'),
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final hidden = controller.obscurePassword.value;
              return TextField(
                key: const Key('sign-in-password'),
                controller: controller.passwordController,
                obscureText: hidden,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    key: const Key('sign-in-password-toggle'),
                    icon: Icon(hidden ? Icons.visibility : Icons.visibility_off),
                    tooltip: hidden ? 'Show password' : 'Hide password',
                    onPressed: controller.togglePasswordVisibility,
                  ),
                ),
                onSubmitted: (_) => _submit(),
              );
            }),
            const SizedBox(height: 24),
            Obx(
              () => ElevatedButton(
                key: const Key('sign-in-submit'),
                onPressed: controller.isSubmitting.value ? null : _submit,
                child: const Text('Sign in'),
              ),
            ),
            Obx(
              () => controller.error.value == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        controller.error.value!,
                        key: const Key('sign-in-error'),
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
            const SizedBox(height: 24),
            Text(
              'Demo accounts only. This is demo-level sign-in, not production authentication.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
