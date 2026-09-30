// Shared fixtures for employee-internal-transfer tests. Values match the
// static demo reference lists (plan PD-03).

import 'package:employee_transfer_project/core/constants/reference_data.dart';
import 'package:employee_transfer_project/domain/transfer/entities/current_user.dart';
import 'package:employee_transfer_project/domain/transfer/entities/enums.dart';
import 'package:employee_transfer_project/domain/transfer/entities/inputs.dart';
import 'package:employee_transfer_project/domain/transfer/entities/org_values.dart';
import 'package:employee_transfer_project/domain/transfer/portal/portal_contracts.dart';

const employeeA = CurrentUser(userId: 'emp-a', role: UserRole.employee, displayName: 'Employee A');
const employeeB = CurrentUser(userId: 'emp-b', role: UserRole.employee, displayName: 'Employee B');
const testerUser = CurrentUser(userId: 'tst-1', role: UserRole.tester, displayName: 'Demo Tester');

const baseValues = OrgValues(departmentId: 'dept-eng', locationId: 'loc-blr', roleId: 'role-swe');
const baseCurrent = EmployeeCurrentValues(values: baseValues, managerName: 'Manager A');

/// Proposed values changing exactly the named fields.
OrgValues changing({bool department = false, bool location = false, bool role = false}) => OrgValues(
      departmentId: department ? 'dept-sales' : baseValues.departmentId,
      locationId: location ? 'loc-mum' : baseValues.locationId,
      roleId: role ? 'role-tl' : baseValues.roleId,
    );

SubmitTransferInput submitInput({
  String submissionId = 'sub-1',
  OrgValues? proposed,
  DateTime? effectiveDate,
  bool noEffectiveDate = false,
  String? reason,
  String? departmentId,
  String? locationId,
  String? roleId,
  bool omitDepartment = false,
}) {
  final p = proposed ?? changing(role: true);
  return SubmitTransferInput(
    submissionId: submissionId,
    departmentId: omitDepartment ? null : (departmentId ?? p.departmentId),
    locationId: locationId ?? p.locationId,
    roleId: roleId ?? p.roleId,
    effectiveDate: noEffectiveDate ? null : (effectiveDate ?? DateTime(2026, 10, 15)),
    reason: reason,
  );
}

class FixtureReferenceLists implements ReferenceLists {
  const FixtureReferenceLists();

  static List<ReferenceItem> _items(List<ReferenceOption> options) =>
      [for (final o in options) ReferenceItem(o.id, o.label)];

  @override
  List<ReferenceItem> departments() => _items(ReferenceData.departments);
  @override
  List<ReferenceItem> locations() => _items(ReferenceData.locations);
  @override
  List<ReferenceItem> roles() => _items(ReferenceData.roles);
}
