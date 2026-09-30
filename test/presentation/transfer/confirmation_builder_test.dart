// employee-internal-transfer.T05 — UT32: confirmation content for each final
// outcome (AC20, BRD-001 §7), plus the awaiting-effect and date-passed lines.

import 'package:flutter_test/flutter_test.dart';

import 'package:employee_transfer_project/domain/transfer/entities/enums.dart';
import 'package:employee_transfer_project/domain/transfer/entities/inputs.dart';
import 'package:employee_transfer_project/domain/transfer/entities/transfer_request.dart';
import 'package:employee_transfer_project/domain/transfer/workflow/transfer_workflow.dart';
import 'package:employee_transfer_project/presentation/transfer/employee/confirmation_builder.dart';

import '../../support/transfer_fixtures.dart';

void main() {
  const refs = FixtureReferenceLists();
  final day1 = DateTime(2026, 10, 1, 9);

  TransferRequest submit() => TransferWorkflow.submit(
        input: submitInput(proposed: changing(location: true)),
        employee: employeeA,
        current: baseCurrent,
        active: const ActiveState(),
        refs: refs,
        requestId: 'r',
        now: day1,
      ).data!;

  TransferRequest apply(TransferRequest r, StepId s, Outcome o, {String? reason, DateTime? at}) =>
      TransferWorkflow.recordOutcome(
        request: r,
        input: RecordOutcomeInput(requestId: 'r', stepId: s, outcome: o, reason: reason),
        testerId: testerUser.userId,
        now: at ?? day1,
      ).data!.request;

  TransferRequest approved() =>
      apply(apply(submit(), StepId.managerApproval, Outcome.approved), StepId.hrEligibility, Outcome.approved);

  TransferRequest completed({DateTime? at}) {
    var r = approved();
    for (final s in [StepId.orgRecordUpdate, StepId.payrollUpdate, StepId.facilitiesWorkspace]) {
      r = apply(r, s, Outcome.completed, at: at);
    }
    return r;
  }

  test('UT32: COMPLETED while awaiting effect', () {
    final c = ConfirmationBuilder.build(completed(), today: DateTime(2026, 10, 2), refs: refs)!;
    expect(c.title, 'Transfer confirmed');
    expect(c.lines, [
      'New department: Engineering, location: Mumbai, role: Software Engineer.',
      'Effective from 15 Oct 2026.',
      'Completed steps: Manager approval, HR eligibility check, Organisational record update, Payroll update, '
          'Facilities: workspace at the new location.',
      'You can submit a new request from 15 Oct 2026.',
    ]);
  });

  test('UT32: COMPLETED from the effective date', () {
    final c = ConfirmationBuilder.build(completed(), today: DateTime(2026, 10, 15), refs: refs)!;
    expect(c.lines.last, 'You may submit a new request.');
  });

  test('UT32: COMPLETED after the effective date had passed adds the SD-05 line', () {
    final c = ConfirmationBuilder.build(completed(at: DateTime(2026, 10, 20, 8)), today: DateTime(2026, 10, 20), refs: refs)!;
    expect(c.lines, contains(
        'This date had passed when your transfer completed, so the new values show in your profile from 20 Oct 2026.'));
    expect(c.lines.last, 'You may submit a new request.');
  });

  test('UT32: REJECTED_BY_MANAGER and REJECTED_BY_HR', () {
    final m = ConfirmationBuilder.build(apply(submit(), StepId.managerApproval, Outcome.rejected, reason: 'Not now'),
        today: DateTime(2026, 10, 2), refs: refs)!;
    expect(m.title, 'Not approved by your manager');
    expect(m.lines, ['Reason: Not now', 'No further steps were taken.', 'You may submit a new request.']);

    final hr = ConfirmationBuilder.build(
        apply(apply(submit(), StepId.managerApproval, Outcome.approved), StepId.hrEligibility, Outcome.rejected,
            reason: 'Ineligible'),
        today: DateTime(2026, 10, 2),
        refs: refs)!;
    expect(hr.title, 'Not approved by HR');
    expect(hr.lines.first, 'Reason: Ineligible');
  });

  test('UT32: FAILED lists failed, completed (not undone) and stopped steps', () {
    var r = approved();
    r = apply(r, StepId.orgRecordUpdate, Outcome.completed);
    r = apply(r, StepId.payrollUpdate, Outcome.failed);
    final c = ConfirmationBuilder.build(r, today: DateTime(2026, 10, 2), refs: refs)!;

    expect(c.title, 'Transfer failed');
    expect(c.lines, [
      'Failed step: Payroll update.',
      'Completed steps (not undone): Organisational record update.',
      'Stopped steps: Facilities: workspace at the new location.',
      'Your department, location and role have not changed.',
      'You may submit a new request.',
    ]);
  });

  test('UT32: no confirmation while in progress', () {
    expect(ConfirmationBuilder.build(submit(), today: DateTime(2026, 10, 2), refs: refs), isNull);
  });
}
