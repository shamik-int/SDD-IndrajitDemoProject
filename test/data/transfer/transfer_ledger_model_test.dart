// employee-internal-transfer.T04 — TransferLedgerModel round trip, with every
// optional field set somewhere (rejection reason, tasks, schedule, STOPPED).

import 'package:flutter_test/flutter_test.dart';

import 'package:employee_transfer_project/data/transfer/models/transfer_ledger_model.dart';
import 'package:employee_transfer_project/domain/transfer/entities/enums.dart';
import 'package:employee_transfer_project/domain/transfer/entities/inputs.dart';
import 'package:employee_transfer_project/domain/transfer/entities/scheduled_change.dart';
import 'package:employee_transfer_project/domain/transfer/entities/transfer_ledger.dart';
import 'package:employee_transfer_project/domain/transfer/entities/transfer_request.dart';
import 'package:employee_transfer_project/domain/transfer/workflow/transfer_workflow.dart';

import '../../support/transfer_fixtures.dart';

void main() {
  final now = DateTime(2026, 10, 1, 9, 15, 30);

  TransferRequest request(String id, String submissionId, {String? reason}) => TransferWorkflow.submit(
        input: submitInput(submissionId: submissionId, proposed: changing(location: true), reason: reason),
        employee: employeeA,
        current: baseCurrent,
        active: const ActiveState(),
        refs: const FixtureReferenceLists(),
        requestId: id,
        now: now,
      ).data!;

  TransferRequest apply(TransferRequest r, StepId s, Outcome o, {String? reason}) => TransferWorkflow.recordOutcome(
        request: r,
        input: RecordOutcomeInput(requestId: r.requestId, stepId: s, outcome: o, reason: reason),
        testerId: testerUser.userId,
        now: now,
      ).data!.request;

  test('a ledger survives toMap → fromMap unchanged', () {
    var failed = request('r1', 's1', reason: 'Closer to home');
    failed = apply(failed, StepId.managerApproval, Outcome.approved);
    failed = apply(failed, StepId.hrEligibility, Outcome.approved);
    failed = apply(failed, StepId.payrollUpdate, Outcome.completed);
    failed = apply(failed, StepId.facilitiesWorkspace, Outcome.failed);

    final rejected = apply(request('r2', 's2'), StepId.managerApproval, Outcome.rejected, reason: 'Not now');

    final ledger = TransferLedger(
      employeeId: employeeA.userId,
      requests: [failed, rejected],
      scheduledChanges: [
        ScheduledChange(
          requestId: 'r0',
          employeeId: employeeA.userId,
          values: changing(role: true),
          effectiveFrom: DateTime(2026, 9, 1),
          scheduledAt: DateTime(2026, 8, 20, 14, 5),
        ),
      ],
    );

    expect(TransferLedgerModel.fromMap(TransferLedgerModel.toMap(ledger)), ledger);
    expect(TransferLedgerModel.toMap(ledger)['requests'][0]['effectiveDate'], '2026-10-15');
  });
}
