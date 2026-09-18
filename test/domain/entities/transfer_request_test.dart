import 'package:flutter_test/flutter_test.dart';

import 'package:employee_transfer_project/domain/entities/stakeholder.dart';
import 'package:employee_transfer_project/domain/entities/stakeholder_state.dart';
import 'package:employee_transfer_project/domain/entities/transfer_request.dart';
import 'package:employee_transfer_project/domain/entities/transfer_request_status.dart';

TransferRequest _buildRequest({
  required Map<Stakeholder, StakeholderState> stakeholders,
  TransferRequestStatus status = TransferRequestStatus.pendingDownstreamUpdates,
}) {
  final now = DateTime(2026, 9, 15);
  return TransferRequest(
    id: 'req-1',
    departmentId: 'dept-1',
    locationId: 'loc-1',
    roleId: 'role-1',
    effectiveDate: DateTime(2026, 11, 1),
    reason: null,
    status: status,
    stakeholders: stakeholders,
    submittedAt: now,
    updatedAt: now,
  );
}

void main() {
  group('TransferRequest.pendingStakeholders', () {
    test('returns only stakeholders in pending state, in insertion order', () {
      final request = _buildRequest(
        stakeholders: {
          Stakeholder.payroll: StakeholderState.pending,
          Stakeholder.it: StakeholderState.pending,
          Stakeholder.facilities: StakeholderState.completed,
        },
      );

      expect(request.pendingStakeholders, [Stakeholder.payroll, Stakeholder.it]);
    });

    test('returns an empty list when no stakeholder is pending', () {
      final request = _buildRequest(
        stakeholders: {Stakeholder.manager: StakeholderState.approved},
      );

      expect(request.pendingStakeholders, isEmpty);
    });
  });

  group('TransferRequest equality', () {
    test('two requests with identical field values are equal', () {
      final a = _buildRequest(
        stakeholders: {Stakeholder.manager: StakeholderState.pending},
      );
      final b = _buildRequest(
        stakeholders: {Stakeholder.manager: StakeholderState.pending},
      );

      expect(a, equals(b));
    });

    test('requests differing only in status are not equal', () {
      final a = _buildRequest(
        stakeholders: {Stakeholder.manager: StakeholderState.pending},
        status: TransferRequestStatus.pendingManagerApproval,
      );
      final b = _buildRequest(
        stakeholders: {Stakeholder.manager: StakeholderState.pending},
        status: TransferRequestStatus.pendingHrValidation,
      );

      expect(a, isNot(equals(b)));
    });
  });
}
