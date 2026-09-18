import 'package:equatable/equatable.dart';

class EmployeeAccount extends Equatable {
  final String email;
  final String name;
  final String currentDepartmentId;
  final String currentLocationId;
  final String currentRoleId;
  final DateTime registeredAt;

  const EmployeeAccount({
    required this.email,
    required this.name,
    required this.currentDepartmentId,
    required this.currentLocationId,
    required this.currentRoleId,
    required this.registeredAt,
  });

  @override
  List<Object?> get props => [
        email,
        name,
        currentDepartmentId,
        currentLocationId,
        currentRoleId,
        registeredAt,
      ];
}
