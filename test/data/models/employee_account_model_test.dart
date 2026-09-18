import 'package:flutter_test/flutter_test.dart';

import 'package:employee_transfer_project/data/models/employee_account_model.dart';
import 'package:employee_transfer_project/domain/entities/employee_account.dart';

void main() {
  final model = EmployeeAccountModel(
    name: 'Person One',
    email: 'person@intglobal.com',
    passwordHash: 'deadbeef',
    passwordSalt: 'salt123',
    currentDepartmentId: 'dept-eng',
    currentLocationId: 'loc-blr',
    currentRoleId: 'role-swe',
    registeredAt: DateTime(2026, 9, 18),
  );

  test('toMap/fromMap round-trips every field, including password fields', () {
    final map = EmployeeAccountModel.toMap(model);
    final restored = EmployeeAccountModel.fromMap(map);

    expect(restored.name, model.name);
    expect(restored.email, model.email);
    expect(restored.passwordHash, model.passwordHash);
    expect(restored.passwordSalt, model.passwordSalt);
    expect(restored.currentDepartmentId, model.currentDepartmentId);
    expect(restored.currentLocationId, model.currentLocationId);
    expect(restored.currentRoleId, model.currentRoleId);
    expect(restored.registeredAt, model.registeredAt);
  });

  test('toEntity never carries the password hash or salt', () {
    final entity = model.toEntity();

    expect(
      entity,
      EmployeeAccount(
        email: 'person@intglobal.com',
        name: 'Person One',
        currentDepartmentId: 'dept-eng',
        currentLocationId: 'loc-blr',
        currentRoleId: 'role-swe',
        registeredAt: DateTime(2026, 9, 18),
      ),
    );
  });
}
