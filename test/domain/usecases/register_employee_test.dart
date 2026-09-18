import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employee_transfer_project/core/result/result.dart';
import 'package:employee_transfer_project/domain/entities/employee_account.dart';
import 'package:employee_transfer_project/domain/entities/register_employee_input.dart';
import 'package:employee_transfer_project/domain/repositories/employee_account_repository.dart';
import 'package:employee_transfer_project/domain/usecases/register_employee.dart';

class MockEmployeeAccountRepository extends Mock
    implements EmployeeAccountRepository {}

void main() {
  late MockEmployeeAccountRepository repository;
  late RegisterEmployee usecase;

  final input = RegisterEmployeeInput(
    name: 'Person One',
    email: 'person@intglobal.com',
    password: 'Password123',
    currentDepartmentId: 'dept-eng',
    currentLocationId: 'loc-blr',
    currentRoleId: 'role-swe',
  );

  setUp(() {
    repository = MockEmployeeAccountRepository();
    usecase = RegisterEmployee(repository);
  });

  test('delegates to repository.register with the given input', () async {
    final expected = EmployeeAccount(
      email: 'person@intglobal.com',
      name: 'Person One',
      currentDepartmentId: 'dept-eng',
      currentLocationId: 'loc-blr',
      currentRoleId: 'role-swe',
      registeredAt: DateTime(2026, 9, 18),
    );
    when(
      () => repository.register(input),
    ).thenAnswer((_) async => Result.success(expected));

    final result = await usecase(input);

    expect(result, Result<EmployeeAccount>.success(expected));
    verify(() => repository.register(input)).called(1);
  });

  test('propagates a Result.error from the repository unchanged', () async {
    when(() => repository.register(input)).thenAnswer(
      (_) async => Result.error('An account with this email already exists.'),
    );

    final result = await usecase(input);

    expect(result.isError, isTrue);
    expect(result.message, 'An account with this email already exists.');
  });
}
