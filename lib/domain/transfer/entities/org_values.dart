import 'package:equatable/equatable.dart';

/// Department, location and role — the three values a transfer changes.
class OrgValues extends Equatable {
  final String departmentId;
  final String locationId;
  final String roleId;

  const OrgValues({required this.departmentId, required this.locationId, required this.roleId});

  bool sameAs(OrgValues other) =>
      departmentId == other.departmentId && locationId == other.locationId && roleId == other.roleId;

  @override
  List<Object?> get props => [departmentId, locationId, roleId];
}

/// D-02 `EmployeeCurrentValues`: the profile values plus the manager name
/// (demo data, not verified, grants no authority — BR-10).
class EmployeeCurrentValues extends Equatable {
  final OrgValues values;
  final String managerName;

  const EmployeeCurrentValues({required this.values, required this.managerName});

  String get departmentId => values.departmentId;
  String get locationId => values.locationId;
  String get roleId => values.roleId;

  @override
  List<Object?> get props => [values, managerName];
}
