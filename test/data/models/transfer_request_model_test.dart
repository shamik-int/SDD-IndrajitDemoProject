import 'package:flutter_test/flutter_test.dart';

import 'package:employee_transfer_project/data/models/transfer_request_model.dart';
import 'package:employee_transfer_project/domain/entities/stakeholder.dart';
import 'package:employee_transfer_project/domain/entities/stakeholder_state.dart';
import 'package:employee_transfer_project/domain/entities/transfer_request.dart';
import 'package:employee_transfer_project/domain/entities/transfer_request_status.dart';

void main() {
  test('toMap/fromMap round-trips a TransferRequest exactly', () {
    final original = TransferRequest(
      id: 'req-1',
      departmentId: 'dept-1',
      locationId: 'loc-1',
      roleId: 'role-1',
      effectiveDate: DateTime(2026, 11, 1),
      reason: 'Relocating',
      status: TransferRequestStatus.pendingDownstreamUpdates,
      stakeholders: const {
        Stakeholder.manager: StakeholderState.approved,
        Stakeholder.hr: StakeholderState.approved,
        Stakeholder.payroll: StakeholderState.pending,
        Stakeholder.it: StakeholderState.completed,
        Stakeholder.facilities: StakeholderState.pending,
      },
      submittedAt: DateTime(2026, 9, 15, 10),
      updatedAt: DateTime(2026, 9, 16, 8),
    );

    final roundTripped = TransferRequestModel.fromMap(
      TransferRequestModel.toMap(original),
    );

    expect(roundTripped, original);
  });

  test('round-trips a null reason', () {
    final original = TransferRequest(
      id: 'req-2',
      departmentId: 'dept-1',
      locationId: 'loc-1',
      roleId: 'role-1',
      effectiveDate: DateTime(2026, 11, 1),
      status: TransferRequestStatus.pendingManagerApproval,
      stakeholders: const {Stakeholder.manager: StakeholderState.pending},
      submittedAt: DateTime(2026, 9, 15),
      updatedAt: DateTime(2026, 9, 15),
    );

    final roundTripped = TransferRequestModel.fromMap(
      TransferRequestModel.toMap(original),
    );

    expect(roundTripped.reason, isNull);
    expect(roundTripped, original);
  });
}
