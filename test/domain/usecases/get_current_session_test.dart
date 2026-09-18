import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employee_transfer_project/core/result/result.dart';
import 'package:employee_transfer_project/domain/entities/employee_account.dart';
import 'package:employee_transfer_project/domain/repositories/employee_account_repository.dart';
import 'package:employee_transfer_project/domain/usecases/get_current_session.dart';

class MockEmployeeAccountRepository extends Mock
    implements EmployeeAccountRepository {}

void main() {
  late MockEmployeeAccountRepository repository;
  late GetCurrentSession usecase;

  setUp(() {
    repository = MockEmployeeAccountRepository();
    usecase = GetCurrentSession(repository);
  });

  test('returns success(null) when no session exists (AC1)', () async {
    when(
      () => repository.getCurrentSession(),
    ).thenAnswer((_) async => Result<EmployeeAccount?>.success(null));

    final result = await usecase();

    expect(result.isSuccess, isTrue);
    expect(result.data, isNull);
    verify(() => repository.getCurrentSession()).called(1);
  });

  test('returns the logged-in account when a session exists', () async {
    final account = EmployeeAccount(
      email: 'person@intglobal.com',
      name: 'Person One',
      currentDepartmentId: 'dept-eng',
      currentLocationId: 'loc-blr',
      currentRoleId: 'role-swe',
      registeredAt: DateTime(2026, 9, 18),
    );
    when(
      () => repository.getCurrentSession(),
    ).thenAnswer((_) async => Result<EmployeeAccount?>.success(account));

    final result = await usecase();

    expect(result.data, account);
  });
}
