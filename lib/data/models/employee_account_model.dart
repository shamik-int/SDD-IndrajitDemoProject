import '../../domain/entities/employee_account.dart';

/// Serializes to/from the plain `Map<String, dynamic>` shape Hive stores
/// natively. Carries `passwordHash`/`passwordSalt` for the data layer's own
/// use — [toEntity] strips both before anything crosses into the domain
/// layer, per the spec's explicit contract note.
class EmployeeAccountModel {
  final String name;
  final String email;
  final String passwordHash;
  final String passwordSalt;
  final String currentDepartmentId;
  final String currentLocationId;
  final String currentRoleId;
  final DateTime registeredAt;

  const EmployeeAccountModel({
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.passwordSalt,
    required this.currentDepartmentId,
    required this.currentLocationId,
    required this.currentRoleId,
    required this.registeredAt,
  });

  EmployeeAccount toEntity() {
    return EmployeeAccount(
      email: email,
      name: name,
      currentDepartmentId: currentDepartmentId,
      currentLocationId: currentLocationId,
      currentRoleId: currentRoleId,
      registeredAt: registeredAt,
    );
  }

  static Map<String, dynamic> toMap(EmployeeAccountModel model) {
    return {
      'name': model.name,
      'email': model.email,
      'passwordHash': model.passwordHash,
      'passwordSalt': model.passwordSalt,
      'currentDepartmentId': model.currentDepartmentId,
      'currentLocationId': model.currentLocationId,
      'currentRoleId': model.currentRoleId,
      'registeredAt': model.registeredAt.toIso8601String(),
    };
  }

  static EmployeeAccountModel fromMap(Map<dynamic, dynamic> map) {
    return EmployeeAccountModel(
      name: map['name'] as String,
      email: map['email'] as String,
      passwordHash: map['passwordHash'] as String,
      passwordSalt: map['passwordSalt'] as String,
      currentDepartmentId: map['currentDepartmentId'] as String,
      currentLocationId: map['currentLocationId'] as String,
      currentRoleId: map['currentRoleId'] as String,
      registeredAt: DateTime.parse(map['registeredAt'] as String),
    );
  }
}
