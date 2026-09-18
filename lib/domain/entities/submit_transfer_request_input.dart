import 'package:equatable/equatable.dart';

/// Input to `OP01` (`submitTransferRequest`) — see the spec's Local Data Contract.
class SubmitTransferRequestInput extends Equatable {
  final String departmentId;
  final String locationId;
  final String roleId;
  final DateTime effectiveDate;
  final String? reason;

  const SubmitTransferRequestInput({
    required this.departmentId,
    required this.locationId,
    required this.roleId,
    required this.effectiveDate,
    this.reason,
  });

  @override
  List<Object?> get props => [
    departmentId,
    locationId,
    roleId,
    effectiveDate,
    reason,
  ];
}
