import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/reference_data.dart';
import '../controllers/register_controller.dart';

class RegisterPage extends GetView<RegisterController> {
  const RegisterPage({super.key});

  Future<void> _submit() async {
    final ok = await controller.submit();
    if (ok) Get.offNamed(AppRoutes.placeholder);
  }

  void _goToLogin() {
    Get.toNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(
              () => TextField(
                key: const Key('register-name-field'),
                controller: controller.nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  errorText: controller.nameError.value,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => TextField(
                key: const Key('register-email-field'),
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: controller.emailError.value,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => TextField(
                key: const Key('register-password-field'),
                controller: controller.passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  errorText: controller.passwordError.value,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => DropdownButtonFormField<String>(
                key: const Key('register-department-dropdown'),
                initialValue: controller.departmentId.value,
                decoration: InputDecoration(
                  labelText: 'Current department',
                  errorText: controller.departmentError.value,
                ),
                items: ReferenceData.departments
                    .map((o) => DropdownMenuItem(value: o.id, child: Text(o.label)))
                    .toList(),
                onChanged: controller.setDepartment,
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => DropdownButtonFormField<String>(
                key: const Key('register-location-dropdown'),
                initialValue: controller.locationId.value,
                decoration: InputDecoration(
                  labelText: 'Current location',
                  errorText: controller.locationError.value,
                ),
                items: ReferenceData.locations
                    .map((o) => DropdownMenuItem(value: o.id, child: Text(o.label)))
                    .toList(),
                onChanged: controller.setLocation,
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => DropdownButtonFormField<String>(
                key: const Key('register-role-dropdown'),
                initialValue: controller.roleId.value,
                decoration: InputDecoration(
                  labelText: 'Current role',
                  errorText: controller.roleError.value,
                ),
                items: ReferenceData.roles
                    .map((o) => DropdownMenuItem(value: o.id, child: Text(o.label)))
                    .toList(),
                onChanged: controller.setRole,
              ),
            ),
            const SizedBox(height: 24),
            Obx(
              () => ElevatedButton(
                onPressed: controller.isSubmitting.value ? null : _submit,
                child: controller.isSubmitting.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Register'),
              ),
            ),
            Obx(
              () => controller.submissionError.value == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        controller.submissionError.value!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _goToLogin,
              child: const Text('Log In'),
            ),
          ],
        ),
      ),
    );
  }
}
