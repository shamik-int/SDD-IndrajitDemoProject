import 'package:flutter_test/flutter_test.dart';

import 'package:employee_transfer_project/domain/entities/employee_account.dart';

EmployeeAccount _account({String email = 'person@intglobal.com'}) {
  return EmployeeAccount(
    email: email,
    name: 'Person One',
    currentDepartmentId: 'dept-eng',
    currentLocationId: 'loc-blr',
    currentRoleId: 'role-swe',
    registeredAt: DateTime(2026, 9, 18),
  );
}

void main() {
  group('EmployeeAccount equality', () {
    test('two accounts with identical fields are equal', () {
      expect(_account(), equals(_account()));
    });

    test('accounts differing only in email are not equal', () {
      expect(
        _account(email: 'a@intglobal.com'),
        isNot(equals(_account(email: 'b@intglobal.com'))),
      );
    });
  });
}
