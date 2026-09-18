import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employee_transfer_project/core/result/result.dart';
import 'package:employee_transfer_project/domain/repositories/employee_account_repository.dart';
import 'package:employee_transfer_project/domain/usecases/logout_employee.dart';

class MockEmployeeAccountRepository extends Mock
    implements EmployeeAccountRepository {}

void main() {
  late MockEmployeeAccountRepository repository;
  late LogoutEmployee usecase;

  setUp(() {
    repository = MockEmployeeAccountRepository();
    usecase = LogoutEmployee(repository);
  });

  test('delegates to repository.logout and returns success(true) (AC8)', () async {
    when(() => repository.logout()).thenAnswer((_) async => Result.success(true));

    final result = await usecase();

    expect(result.isSuccess, isTrue);
    expect(result.data, isTrue);
    verify(() => repository.logout()).called(1);
  });
}
