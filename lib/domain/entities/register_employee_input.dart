import 'package:equatable/equatable.dart';

class RegisterEmployeeInput extends Equatable {
  final String name;
  final String email;
  final String password;
  final String currentDepartmentId;
  final String currentLocationId;
  final String currentRoleId;

  const RegisterEmployeeInput({
    required this.name,
    required this.email,
    required this.password,
    required this.currentDepartmentId,
    required this.currentLocationId,
    required this.currentRoleId,
  });

  @override
  List<Object?> get props => [
        name,
        email,
        password,
        currentDepartmentId,
        currentLocationId,
        currentRoleId,
      ];
}
