import 'package:equatable/equatable.dart';

import 'stakeholder.dart';
import 'stakeholder_state.dart';
import 'transfer_request_status.dart';

/// Pure business object — no JSON/Hive concerns (those live in `data/models/`).
class TransferRequest extends Equatable {
  final String id;
  final String departmentId;
  final String locationId;
  final String roleId;
  final DateTime effectiveDate;
  final String? reason;
  final TransferRequestStatus status;
  final Map<Stakeholder, StakeholderState> stakeholders;
  final DateTime submittedAt;
  final DateTime updatedAt;

  const TransferRequest({
    required this.id,
    required this.departmentId,
    required this.locationId,
    required this.roleId,
    required this.effectiveDate,
    this.reason,
    required this.status,
    required this.stakeholders,
    required this.submittedAt,
    required this.updatedAt,
  });

  /// Stakeholders currently in `pending` state, in the map's insertion order
  /// — this is the `pendingStakeholders` field the spec's OP02/OP03 describe.
  List<Stakeholder> get pendingStakeholders => stakeholders.entries
      .where((entry) => entry.value == StakeholderState.pending)
      .map((entry) => entry.key)
      .toList();

  TransferRequest copyWith({
    TransferRequestStatus? status,
    Map<Stakeholder, StakeholderState>? stakeholders,
    DateTime? updatedAt,
  }) {
    return TransferRequest(
      id: id,
      departmentId: departmentId,
      locationId: locationId,
      roleId: roleId,
      effectiveDate: effectiveDate,
      reason: reason,
      status: status ?? this.status,
      stakeholders: stakeholders ?? this.stakeholders,
      submittedAt: submittedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    departmentId,
    locationId,
    roleId,
    effectiveDate,
    reason,
    status,
    stakeholders,
    submittedAt,
    updatedAt,
  ];
}
