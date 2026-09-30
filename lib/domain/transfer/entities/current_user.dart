import 'package:equatable/equatable.dart';

import 'enums.dart';

/// D-01: the signed-in user. The role comes from the demo account data and
/// is never chosen at sign-in (SD-18).
class CurrentUser extends Equatable {
  final String userId;
  final UserRole role;
  final String displayName;

  const CurrentUser({required this.userId, required this.role, required this.displayName});

  bool get isEmployee => role == UserRole.employee;
  bool get isTester => role == UserRole.tester;

  @override
  List<Object?> get props => [userId, role, displayName];
}
