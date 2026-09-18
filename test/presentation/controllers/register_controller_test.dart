import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employee_transfer_project/core/result/result.dart';
import 'package:employee_transfer_project/domain/entities/employee_account.dart';
import 'package:employee_transfer_project/domain/entities/register_employee_input.dart';
import 'package:employee_transfer_project/domain/repositories/employee_account_repository.dart';
import 'package:employee_transfer_project/domain/usecases/register_employee.dart';
import 'package:employee_transfer_project/presentation/controllers/register_controller.dart';

class MockEmployeeAccountRepository extends Mock
    implements EmployeeAccountRepository {}

class FakeRegisterEmployeeInput extends Fake implements RegisterEmployeeInput {}

EmployeeAccount _account() {
  return EmployeeAccount(
    email: 'person@intglobal.com',
    name: 'Person One',
    currentDepartmentId: 'dept-eng',
    currentLocationId: 'loc-blr',
    currentRoleId: 'role-swe',
    registeredAt: DateTime(2026, 9, 18),
  );
}

void main() {
  late MockEmployeeAccountRepository repository;
  late RegisterController controller;

  setUpAll(() {
    registerFallbackValue(FakeRegisterEmployeeInput());
  });

  setUp(() {
    Get.testMode = true;
    repository = MockEmployeeAccountRepository();
    controller = RegisterController(registerEmployee: RegisterEmployee(repository));
  });

  group('AC4 — validation', () {
    test('blocks submission and sets a field error per empty mandatory field', () async {
      final result = await controller.submit();

      expect(result, isFalse);
      expect(controller.nameError.value, isNotNull);
      expect(controller.emailError.value, isNotNull);
      expect(controller.passwordError.value, isNotNull);
      expect(controller.departmentError.value, isNotNull);
      expect(controller.locationError.value, isNotNull);
      expect(controller.roleError.value, isNotNull);
      verifyNever(() => repository.register(any()));
    });

    test('rejects a malformed email with the valid-email message', () async {
      controller.nameController.text = 'Person One';
      controller.emailController.text = 'not-an-email';
      controller.passwordController.text = 'Password123';
      controller.setDepartment('dept-eng');
      controller.setLocation('loc-blr');
      controller.setRole('role-swe');

      final result = await controller.submit();

      expect(result, isFalse);
      expect(controller.emailError.value, 'Enter a valid email address.');
      verifyNever(() => repository.register(any()));
    });

    test('rejects a password that fails the complexity rule', () async {
      controller.nameController.text = 'Person One';
      controller.emailController.text = 'person@intglobal.com';
      controller.passwordController.text = 'ab1';
      controller.setDepartment('dept-eng');
      controller.setLocation('loc-blr');
      controller.setRole('role-swe');

      final result = await controller.submit();

      expect(result, isFalse);
      expect(
        controller.passwordError.value,
        'Password must be at least 8 characters and include a letter and a number.',
      );
    });

    test('clears a field error once a valid value is set', () async {
      await controller.submit();
      expect(controller.departmentError.value, isNotNull);

      controller.setDepartment('dept-eng');

      expect(controller.departmentError.value, isNull);
    });
  });

  group('AC3 — successful registration', () {
    test('calls the usecase with the entered fields and returns true', () async {
      when(
        () => repository.register(any()),
      ).thenAnswer((_) async => Result.success(_account()));

      controller.nameController.text = 'Person One';
      controller.emailController.text = 'person@intglobal.com';
      controller.passwordController.text = 'Password123';
      controller.setDepartment('dept-eng');
      controller.setLocation('loc-blr');
      controller.setRole('role-swe');

      final result = await controller.submit();

      expect(result, isTrue);
      expect(controller.submissionError.value, isNull);
      verify(
        () => repository.register(
          const RegisterEmployeeInput(
            name: 'Person One',
            email: 'person@intglobal.com',
            password: 'Password123',
            currentDepartmentId: 'dept-eng',
            currentLocationId: 'loc-blr',
            currentRoleId: 'role-swe',
          ),
        ),
      ).called(1);
    });
  });

  group('AC5 — duplicate email', () {
    test('surfaces the repository error as a submission-level error, not a field error', () async {
      when(() => repository.register(any())).thenAnswer(
        (_) async => Result.error('An account with this email already exists.'),
      );

      controller.nameController.text = 'Person One';
      controller.emailController.text = 'person@intglobal.com';
      controller.passwordController.text = 'Password123';
      controller.setDepartment('dept-eng');
      controller.setLocation('loc-blr');
      controller.setRole('role-swe');

      final result = await controller.submit();

      expect(result, isFalse);
      expect(controller.submissionError.value, 'An account with this email already exists.');
      expect(controller.emailError.value, isNull);
    });
  });
}
