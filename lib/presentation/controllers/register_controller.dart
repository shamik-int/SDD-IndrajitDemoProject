import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/validators.dart';
import '../../domain/entities/register_employee_input.dart';
import '../../domain/usecases/register_employee.dart';

/// Drives the Register screen — AC2 (capture fields), AC3 (successful
/// registration + auto-login), AC4 (field-level validation). AC5 (duplicate
/// email) is surfaced as [submissionError], not a field error — uniqueness
/// is the repository's own concern, not something re-derivable client-side.
class RegisterController extends GetxController {
  final RegisterEmployee registerEmployee;

  RegisterController({required this.registerEmployee});

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final departmentId = RxnString();
  final locationId = RxnString();
  final roleId = RxnString();

  final nameError = RxnString();
  final emailError = RxnString();
  final passwordError = RxnString();
  final departmentError = RxnString();
  final locationError = RxnString();
  final roleError = RxnString();

  final isSubmitting = false.obs;
  final submissionError = RxnString();

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void setDepartment(String? value) {
    departmentId.value = value;
    departmentError.value = null;
  }

  void setLocation(String? value) {
    locationId.value = value;
    locationError.value = null;
  }

  void setRole(String? value) {
    roleId.value = value;
    roleError.value = null;
  }

  bool _validate() {
    var valid = true;

    nameError.value = Validators.required(nameController.text, fieldName: 'Name');
    if (nameError.value != null) valid = false;

    emailError.value = Validators.email(emailController.text);
    if (emailError.value != null) valid = false;

    passwordError.value = Validators.password(passwordController.text);
    if (passwordError.value != null) valid = false;

    departmentError.value = Validators.required(departmentId.value, fieldName: 'Department');
    if (departmentError.value != null) valid = false;

    locationError.value = Validators.required(locationId.value, fieldName: 'Location');
    if (locationError.value != null) valid = false;

    roleError.value = Validators.required(roleId.value, fieldName: 'Role');
    if (roleError.value != null) valid = false;

    return valid;
  }

  Future<bool> submit() async {
    if (!_validate()) return false;

    isSubmitting.value = true;
    submissionError.value = null;

    final result = await registerEmployee(
      RegisterEmployeeInput(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        currentDepartmentId: departmentId.value!,
        currentLocationId: locationId.value!,
        currentRoleId: roleId.value!,
      ),
    );
    isSubmitting.value = false;

    if (result.isError) {
      submissionError.value = result.message;
      return false;
    }

    return true;
  }
}
