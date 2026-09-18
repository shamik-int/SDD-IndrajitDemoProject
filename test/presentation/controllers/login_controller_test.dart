import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employee_transfer_project/core/result/result.dart';
import 'package:employee_transfer_project/domain/entities/employee_account.dart';
import 'package:employee_transfer_project/domain/entities/login_input.dart';
import 'package:employee_transfer_project/domain/repositories/employee_account_repository.dart';
import 'package:employee_transfer_project/domain/usecases/login_employee.dart';
import 'package:employee_transfer_project/presentation/controllers/login_controller.dart';

class MockEmployeeAccountRepository extends Mock
    implements EmployeeAccountRepository {}

class FakeLoginInput extends Fake implements LoginInput {}

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
  late LoginController controller;

  setUpAll(() {
    registerFallbackValue(FakeLoginInput());
  });

  setUp(() {
    Get.testMode = true;
    repository = MockEmployeeAccountRepository();
    controller = LoginController(loginEmployee: LoginEmployee(repository));
  });

  group('AC6 — successful login', () {
    test('calls the usecase with the entered credentials and returns true', () async {
      when(() => repository.login(any())).thenAnswer((_) async => Result.success(_account()));

      controller.emailController.text = 'person@intglobal.com';
      controller.passwordController.text = 'Password123';

      final result = await controller.submit();

      expect(result, isTrue);
      expect(controller.formError.value, isNull);
      verify(
        () => repository.login(
          const LoginInput(email: 'person@intglobal.com', password: 'Password123'),
        ),
      ).called(1);
    });
  });

  group('AC7 — generic invalid-credentials error', () {
    test('surfaces the repository error unchanged for an unregistered email', () async {
      when(
        () => repository.login(any()),
      ).thenAnswer((_) async => Result.error('Invalid email or password.'));

      controller.emailController.text = 'nobody@intglobal.com';
      controller.passwordController.text = 'Password123';

      final result = await controller.submit();

      expect(result, isFalse);
      expect(controller.formError.value, 'Invalid email or password.');
    });

    test('surfaces the same generic error for a registered email with the wrong password', () async {
      when(
        () => repository.login(any()),
      ).thenAnswer((_) async => Result.error('Invalid email or password.'));

      controller.emailController.text = 'person@intglobal.com';
      controller.passwordController.text = 'WrongPass1';

      final result = await controller.submit();

      expect(result, isFalse);
      expect(controller.formError.value, 'Invalid email or password.');
    });

    test('clears a previous formError once submit is retried', () async {
      when(
        () => repository.login(any()),
      ).thenAnswer((_) async => Result.error('Invalid email or password.'));
      controller.emailController.text = 'person@intglobal.com';
      controller.passwordController.text = 'WrongPass1';
      await controller.submit();
      expect(controller.formError.value, isNotNull);

      when(() => repository.login(any())).thenAnswer((_) async => Result.success(_account()));
      controller.passwordController.text = 'Password123';
      final result = await controller.submit();

      expect(result, isTrue);
      expect(controller.formError.value, isNull);
    });
  });
}
