import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employee_transfer_project/core/result/result.dart';
import 'package:employee_transfer_project/domain/entities/employee_account.dart';
import 'package:employee_transfer_project/domain/entities/login_input.dart';
import 'package:employee_transfer_project/domain/repositories/employee_account_repository.dart';
import 'package:employee_transfer_project/domain/usecases/login_employee.dart';

class MockEmployeeAccountRepository extends Mock
    implements EmployeeAccountRepository {}

void main() {
  late MockEmployeeAccountRepository repository;
  late LoginEmployee usecase;

  const input = LoginInput(email: 'person@intglobal.com', password: 'Password123');

  setUp(() {
    repository = MockEmployeeAccountRepository();
    usecase = LoginEmployee(repository);
  });

  test('delegates to repository.login with the given input', () async {
    final expected = EmployeeAccount(
      email: 'person@intglobal.com',
      name: 'Person One',
      currentDepartmentId: 'dept-eng',
      currentLocationId: 'loc-blr',
      currentRoleId: 'role-swe',
      registeredAt: DateTime(2026, 9, 18),
    );
    when(
      () => repository.login(input),
    ).thenAnswer((_) async => Result.success(expected));

    final result = await usecase(input);

    expect(result, Result<EmployeeAccount>.success(expected));
    verify(() => repository.login(input)).called(1);
  });

  test('propagates the generic invalid-credentials error unchanged (AC7)', () async {
    when(
      () => repository.login(input),
    ).thenAnswer((_) async => Result.error('Invalid email or password.'));

    final result = await usecase(input);

    expect(result.isError, isTrue);
    expect(result.message, 'Invalid email or password.');
  });
}
