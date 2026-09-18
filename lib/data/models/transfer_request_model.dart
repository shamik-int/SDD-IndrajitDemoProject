import '../../domain/entities/stakeholder.dart';
import '../../domain/entities/stakeholder_state.dart';
import '../../domain/entities/transfer_request.dart';
import '../../domain/entities/transfer_request_status.dart';

/// Serializes [TransferRequest] to/from the plain `Map<String, dynamic>`
/// shape Hive stores natively (enums aren't Hive-storable without a
/// TypeAdapter, so they're written out as their `.name` string).
class TransferRequestModel {
  TransferRequestModel._();

  static Map<String, dynamic> toMap(TransferRequest request) {
    return {
      'id': request.id,
      'departmentId': request.departmentId,
      'locationId': request.locationId,
      'roleId': request.roleId,
      'effectiveDate': request.effectiveDate.toIso8601String(),
      'reason': request.reason,
      'status': request.status.name,
      'stakeholders': request.stakeholders.map(
        (stakeholder, state) => MapEntry(stakeholder.name, state.name),
      ),
      'submittedAt': request.submittedAt.toIso8601String(),
      'updatedAt': request.updatedAt.toIso8601String(),
    };
  }

  static TransferRequest fromMap(Map<dynamic, dynamic> map) {
    final stakeholdersMap = (map['stakeholders'] as Map).map(
      (key, value) => MapEntry(
        Stakeholder.values.byName(key as String),
        StakeholderState.values.byName(value as String),
      ),
    );

    return TransferRequest(
      id: map['id'] as String,
      departmentId: map['departmentId'] as String,
      locationId: map['locationId'] as String,
      roleId: map['roleId'] as String,
      effectiveDate: DateTime.parse(map['effectiveDate'] as String),
      reason: map['reason'] as String?,
      status: TransferRequestStatus.values.byName(map['status'] as String),
      stakeholders: stakeholdersMap,
      submittedAt: DateTime.parse(map['submittedAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
