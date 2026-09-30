// employee-internal-transfer.T03 — TransferWorkflow (pure). Covers the
// spec-v2.4 acceptance scenarios that need no storage: submission rules,
// every OP06 effect and error, the triggers table, stakeholder task payloads
// and the history actors (SD-19).

import 'package:flutter_test/flutter_test.dart';

import 'package:employee_transfer_project/core/constants/transfer_messages.dart';
import 'package:employee_transfer_project/domain/transfer/entities/enums.dart';
import 'package:employee_transfer_project/domain/transfer/entities/history_entry.dart';
import 'package:employee_transfer_project/domain/transfer/entities/inputs.dart';
import 'package:employee_transfer_project/domain/transfer/entities/org_values.dart';
import 'package:employee_transfer_project/domain/transfer/entities/transfer_request.dart';
import 'package:employee_transfer_project/domain/transfer/workflow/transfer_workflow.dart';

import '../../support/transfer_fixtures.dart';

void main() {
  final now = DateTime(2026, 10, 1, 9);
  const refs = FixtureReferenceLists();

  TransferRequest submitOk({OrgValues? proposed, DateTime? effectiveDate, String? reason}) {
    final result = TransferWorkflow.submit(
      input: submitInput(proposed: proposed, effectiveDate: effectiveDate, reason: reason),
      employee: employeeA,
      current: baseCurrent,
      active: const ActiveState(),
      refs: refs,
      requestId: 'req-1',
      now: now,
    );
    expect(result.isSuccess, isTrue, reason: result.message);
    return result.data!;
  }

  String? submitError(SubmitTransferInput input, {ActiveState active = const ActiveState()}) {
    return TransferWorkflow.submit(
      input: input,
      employee: employeeA,
      current: baseCurrent,
      active: active,
      refs: refs,
      requestId: 'req-1',
      now: now,
    ).message;
  }

  TransferRequest apply(TransferRequest r, StepId step, Outcome outcome, {String? reason, DateTime? at}) {
    final result = TransferWorkflow.recordOutcome(
      request: r,
      input: RecordOutcomeInput(requestId: r.requestId, stepId: step, outcome: outcome, reason: reason),
      testerId: testerUser.userId,
      now: at ?? now,
    );
    expect(result.isSuccess, isTrue, reason: result.message);
    return result.data!.request;
  }

  String? applyError(TransferRequest r, StepId step, Outcome outcome, {String? reason}) {
    return TransferWorkflow.recordOutcome(
      request: r,
      input: RecordOutcomeInput(requestId: r.requestId, stepId: step, outcome: outcome, reason: reason),
      testerId: testerUser.userId,
      now: now,
    ).message;
  }

  TransferRequest toInProgress({OrgValues? proposed}) {
    var r = submitOk(proposed: proposed);
    r = apply(r, StepId.managerApproval, Outcome.approved);
    return apply(r, StepId.hrEligibility, Outcome.approved);
  }

  Map<StepId, StepState> downstreamStates(TransferRequest r) =>
      {for (final id in StepId.downstream) id: r.step(id)!.state};

  group('submit (OP01)', () {
    test('UT01: valid request changing role only → PENDING_MANAGER_APPROVAL, one SUBMITTED entry by EMPLOYEE', () {
      final r = submitOk();

      expect(r.status, RequestStatus.pendingManagerApproval);
      expect(r.employeeId, employeeA.userId);
      expect(r.steps.single.stepId, StepId.managerApproval);
      expect(r.steps.single.state, StepState.pending);
      expect(r.steps.single.stepId.pendingAction, 'Manager approval');
      expect(r.history, hasLength(1));
      expect(r.history.single.type, HistoryType.submitted);
      expect(r.history.single.actor, Actor.employee);
      expect(r.history.single.toStatus, RequestStatus.pendingManagerApproval);
      expect(r.history.single.sequence, 1);
    });

    test('UT02 (pure part): snapshot equals the current values passed in', () {
      expect(submitOk().current, baseCurrent);
    });

    test('UT03: department missing → "Select a department."', () {
      expect(submitError(submitInput(omitDepartment: true)), TransferMessages.selectDepartment);
    });

    test('UT04: location not in the reference list → field error', () {
      expect(submitError(submitInput(locationId: 'loc-mars')), TransferMessages.selectLocation);
      expect(submitError(submitInput(roleId: '')), TransferMessages.selectRole);
    });

    test('AC04: effective date missing → "Enter an effective date."', () {
      expect(submitError(submitInput(noEffectiveDate: true)), TransferMessages.enterEffectiveDate);
    });

    test('UT05, UT06: effective date today or yesterday → must be in the future', () {
      expect(submitError(submitInput(effectiveDate: DateTime(2026, 10, 1))), TransferMessages.effectiveDateInFuture);
      expect(submitError(submitInput(effectiveDate: DateTime(2026, 9, 30))), TransferMessages.effectiveDateInFuture);
    });

    test('UT07: effective date tomorrow → accepted (no minimum lead time)', () {
      expect(submitOk(effectiveDate: DateTime(2026, 10, 2)).effectiveDate, DateTime(2026, 10, 2));
    });

    test('UT47: effective date 5 years ahead → accepted (SD-11)', () {
      expect(submitOk(effectiveDate: DateTime(2031, 10, 1)).status, RequestStatus.pendingManagerApproval);
    });

    test('UT08: proposed values equal current values → "Change at least one…"', () {
      expect(submitError(submitInput(proposed: baseValues)), TransferMessages.changeAtLeastOne);
    });

    test('UT09 (pure part): a request in progress blocks submission', () {
      final active = ActiveState(inProgress: submitOk());
      expect(submitError(submitInput(submissionId: 'sub-2'), active: active), TransferMessages.alreadyInProgress);
    });

    test('OP01 error 6: a COMPLETED request awaiting effect blocks submission with its date', () {
      final completed = submitOk().copyWith(status: RequestStatus.completed);
      expect(
        submitError(submitInput(submissionId: 'sub-2'), active: ActiveState(awaitingEffect: completed)),
        'Your previous transfer takes effect on 15 Oct 2026. You can submit a new request from that date.',
      );
    });

    test('UT46: reason of 501 characters → "Reason must be 500 characters or fewer."; 500 accepted', () {
      expect(submitError(submitInput(reason: 'x' * 501)), TransferMessages.reasonTooLong);
      expect(submitOk(reason: 'x' * 500).reason, hasLength(500));
    });

    test('UT40 (pure part): no reason, or only spaces, is stored as no reason', () {
      expect(submitOk().reason, isNull);
      expect(submitOk(reason: '   ').reason, isNull);
      expect(submitOk(reason: '  Closer to family  ').reason, 'Closer to family');
    });

    test('errors are checked in the spec order (field before date before same-values)', () {
      expect(
        submitError(SubmitTransferInput(
          submissionId: 's',
          departmentId: null,
          locationId: baseValues.locationId,
          roleId: baseValues.roleId,
          effectiveDate: DateTime(2026, 9, 1),
        )),
        TransferMessages.selectDepartment,
      );
      expect(submitError(submitInput(proposed: baseValues, effectiveDate: DateTime(2026, 9, 1))),
          TransferMessages.effectiveDateInFuture);
    });
  });

  group('manager and HR outcomes', () {
    test('UT11, AC10: manager approves → PENDING_HR_ELIGIBILITY, HR step PENDING, manager Completed (Approved)', () {
      final r = apply(submitOk(), StepId.managerApproval, Outcome.approved);

      expect(r.status, RequestStatus.pendingHrEligibility);
      expect(r.step(StepId.managerApproval)!.state, StepState.completed);
      expect(r.step(StepId.managerApproval)!.stateLabel, 'Completed (Approved)');
      expect(r.step(StepId.hrEligibility)!.state, StepState.pending);
      expect(r.step(StepId.hrEligibility)!.stepId.pendingAction, 'HR eligibility check');
    });

    test('UT55, XF04: manager approval history — MANAGER with simulatedBy, then SYSTEM, SYSTEM', () {
      final before = submitOk();
      final result = TransferWorkflow.recordOutcome(
        request: before,
        input: RecordOutcomeInput(requestId: before.requestId, stepId: StepId.managerApproval, outcome: Outcome.approved),
        testerId: testerUser.userId,
        now: now,
      ).data!;

      final added = result.added;
      expect(added.map((e) => (e.type, e.actor)), [
        (HistoryType.stepOutcome, Actor.manager),
        (HistoryType.statusChanged, Actor.system),
        (HistoryType.stepSet, Actor.system),
      ]);
      expect(added[0].simulatedBy, testerUser.userId);
      expect(added[0].outcome, Outcome.approved);
      expect(added[1].fromStatus, RequestStatus.pendingManagerApproval);
      expect(added[1].toStatus, RequestStatus.pendingHrEligibility);
      expect(added[2].stepId, StepId.hrEligibility);
      expect(added[2].toState, StepState.pending);
      expect(added.map((e) => e.sequence), [2, 3, 4]);
      expect(added.any((e) => e.actor == Actor.employee), isFalse);
      expect(result.request.history, [...before.history, ...added]);
    });

    test('UT12, AC11: manager rejects with reason → REJECTED_BY_MANAGER; reason on step and history; nothing else starts', () {
      final r = apply(submitOk(), StepId.managerApproval, Outcome.rejected, reason: 'Team is short-staffed');

      expect(r.status, RequestStatus.rejectedByManager);
      expect(r.step(StepId.managerApproval)!.state, StepState.rejected);
      expect(r.step(StepId.managerApproval)!.reason, 'Team is short-staffed');
      expect(r.steps, hasLength(1));
      final outcome = r.history.firstWhere((e) => e.type == HistoryType.stepOutcome);
      expect(outcome.reason, 'Team is short-staffed');
      expect(r.history.last.type, HistoryType.statusChanged);
      expect(r.history.last.actor, Actor.system);
    });

    test('UT13, UT36, AC25: blank rejection reason → "A rejection reason is required."', () {
      final r = submitOk();
      expect(applyError(r, StepId.managerApproval, Outcome.rejected), TransferMessages.rejectionReasonRequired);
      expect(applyError(r, StepId.managerApproval, Outcome.rejected, reason: '   '), TransferMessages.rejectionReasonRequired);

      final atHr = apply(r, StepId.managerApproval, Outcome.approved);
      expect(applyError(atHr, StepId.hrEligibility, Outcome.rejected, reason: ' '), TransferMessages.rejectionReasonRequired);
    });

    test('UT46: rejection reason of 501 characters → too long', () {
      expect(applyError(submitOk(), StepId.managerApproval, Outcome.rejected, reason: 'r' * 501),
          TransferMessages.reasonTooLong);
    });

    test('UT14, AC12: HR rejects with reason → REJECTED_BY_HR; reason stored; no downstream step', () {
      var r = apply(submitOk(), StepId.managerApproval, Outcome.approved);
      r = apply(r, StepId.hrEligibility, Outcome.rejected, reason: 'Not eligible yet');

      expect(r.status, RequestStatus.rejectedByHr);
      expect(r.step(StepId.hrEligibility)!.reason, 'Not eligible yet');
      expect(r.steps.map((s) => s.stepId), [StepId.managerApproval, StepId.hrEligibility]);
    });
  });

  group('triggers table (AC13, §5)', () {
    const p = StepState.pending;
    const n = StepState.notRequired;
    final cases = <String, (OrgValues, Map<StepId, StepState>)>{
      'UT15 department only': (
        changing(department: true),
        {StepId.orgRecordUpdate: p, StepId.payrollUpdate: n, StepId.itAccessChange: p, StepId.facilitiesWorkspace: n}
      ),
      'UT16 location only': (
        changing(location: true),
        {StepId.orgRecordUpdate: p, StepId.payrollUpdate: p, StepId.itAccessChange: n, StepId.facilitiesWorkspace: p}
      ),
      'UT17 role only': (
        changing(role: true),
        {StepId.orgRecordUpdate: p, StepId.payrollUpdate: p, StepId.itAccessChange: p, StepId.facilitiesWorkspace: n}
      ),
      'UT18 all three': (
        changing(department: true, location: true, role: true),
        {StepId.orgRecordUpdate: p, StepId.payrollUpdate: p, StepId.itAccessChange: p, StepId.facilitiesWorkspace: p}
      ),
      'UT33 department + location': (
        changing(department: true, location: true),
        {StepId.orgRecordUpdate: p, StepId.payrollUpdate: p, StepId.itAccessChange: p, StepId.facilitiesWorkspace: p}
      ),
      'UT34 department + role': (
        changing(department: true, role: true),
        {StepId.orgRecordUpdate: p, StepId.payrollUpdate: p, StepId.itAccessChange: p, StepId.facilitiesWorkspace: n}
      ),
      'UT35 location + role': (
        changing(location: true, role: true),
        {StepId.orgRecordUpdate: p, StepId.payrollUpdate: p, StepId.itAccessChange: p, StepId.facilitiesWorkspace: p}
      ),
    };

    cases.forEach((name, c) {
      test('$name → ${c.$2.values.map((s) => s.code).join(', ')}', () {
        final r = toInProgress(proposed: c.$1);
        expect(r.status, RequestStatus.inProgress);
        expect(downstreamStates(r), c.$2);
      });
    });

    test('UT56: HR approves, department only — four STEP_SET entries by SYSTEM in Steps-table order', () {
      final r = toInProgress(proposed: changing(department: true));
      final sets = r.history.where((e) => e.type == HistoryType.stepSet && e.stepId != StepId.hrEligibility).toList();

      expect(sets.map((e) => (e.stepId, e.toState, e.actor)), [
        (StepId.orgRecordUpdate, StepState.pending, Actor.system),
        (StepId.payrollUpdate, StepState.notRequired, Actor.system),
        (StepId.itAccessChange, StepState.pending, Actor.system),
        (StepId.facilitiesWorkspace, StepState.notRequired, Actor.system),
      ]);
    });

    test('SD-03: triggers use the snapshot at submission', () {
      final r = toInProgress(proposed: changing(location: true));
      expect(r.current, baseCurrent);
      expect(r.step(StepId.itAccessChange)!.state, StepState.notRequired);
    });
  });

  group('downstream outcomes', () {
    test('UT19, AC14: an outcome on a NOT_REQUIRED step → "This step is not pending."', () {
      final r = toInProgress(proposed: changing(department: true));
      expect(applyError(r, StepId.payrollUpdate, Outcome.completed), TransferMessages.stepNotPending);
    });

    test('UT58: org record completed first — nothing scheduled, no CHANGE_SCHEDULED', () {
      final r = toInProgress(proposed: changing(role: true));
      final result = TransferWorkflow.recordOutcome(
        request: r,
        input: RecordOutcomeInput(requestId: r.requestId, stepId: StepId.orgRecordUpdate, outcome: Outcome.completed),
        testerId: testerUser.userId,
        now: now,
      ).data!;

      expect(result.schedule, isNull);
      expect(result.request.status, RequestStatus.inProgress);
      expect(result.added.single.type, HistoryType.stepOutcome);
      expect(result.added.single.actor, Actor.hr);
    });

    test('UT20, AC15: required steps complete in any order → COMPLETED after the last, whichever it is', () {
      final orders = [
        [StepId.orgRecordUpdate, StepId.payrollUpdate, StepId.itAccessChange],
        [StepId.itAccessChange, StepId.orgRecordUpdate, StepId.payrollUpdate],
        [StepId.payrollUpdate, StepId.itAccessChange, StepId.orgRecordUpdate],
      ];
      for (final order in orders) {
        var r = toInProgress(proposed: changing(role: true));
        for (var i = 0; i < order.length; i++) {
          r = apply(r, order[i], Outcome.completed);
          expect(r.status, i == order.length - 1 ? RequestStatus.completed : RequestStatus.inProgress);
        }
      }
    });

    test('UT59: the last pending step completing asks for one schedule with the proposed values and effective date', () {
      var r = toInProgress(proposed: changing(role: true));
      r = apply(r, StepId.orgRecordUpdate, Outcome.completed);
      r = apply(r, StepId.itAccessChange, Outcome.completed);
      final result = TransferWorkflow.recordOutcome(
        request: r,
        input: RecordOutcomeInput(requestId: r.requestId, stepId: StepId.payrollUpdate, outcome: Outcome.completed),
        testerId: testerUser.userId,
        now: now,
      ).data!;

      expect(result.schedule!.requestId, r.requestId);
      expect(result.schedule!.values, changing(role: true));
      expect(result.schedule!.effectiveFrom, DateTime(2026, 10, 15));
      expect(result.added.map((e) => (e.type, e.actor)), [
        (HistoryType.stepOutcome, Actor.payroll),
        (HistoryType.statusChanged, Actor.system),
        (HistoryType.changeScheduled, Actor.system),
      ]);
      expect(result.added.last.effectiveFrom, DateTime(2026, 10, 15));
    });

    test('UT22, AC17: Payroll completes, then IT fails → IT FAILED, Org and Facilities STOPPED, Payroll stays COMPLETED', () {
      var r = toInProgress(proposed: changing(location: true, role: true));
      r = apply(r, StepId.payrollUpdate, Outcome.completed);
      final result = TransferWorkflow.recordOutcome(
        request: r,
        input: RecordOutcomeInput(requestId: r.requestId, stepId: StepId.itAccessChange, outcome: Outcome.failed),
        testerId: testerUser.userId,
        now: now,
      ).data!;

      expect(result.request.status, RequestStatus.failed);
      expect(downstreamStates(result.request), {
        StepId.orgRecordUpdate: StepState.stopped,
        StepId.payrollUpdate: StepState.completed,
        StepId.itAccessChange: StepState.failed,
        StepId.facilitiesWorkspace: StepState.stopped,
      });
      expect(result.schedule, isNull);
      expect(result.added.any((e) => e.type == HistoryType.changeScheduled), isFalse);
    });

    test('UT57: Facilities fails with Org and Payroll pending — STEP_SET STOPPED ×2 then STATUS_CHANGED, all SYSTEM', () {
      final r = toInProgress(proposed: changing(location: true));
      final added = TransferWorkflow.recordOutcome(
        request: r,
        input: RecordOutcomeInput(requestId: r.requestId, stepId: StepId.facilitiesWorkspace, outcome: Outcome.failed),
        testerId: testerUser.userId,
        now: now,
      ).data!.added;

      expect(added.map((e) => (e.type, e.actor, e.stepId, e.toState, e.toStatus)), [
        (HistoryType.stepOutcome, Actor.facilities, StepId.facilitiesWorkspace, null, null),
        (HistoryType.stepSet, Actor.system, StepId.orgRecordUpdate, StepState.stopped, null),
        (HistoryType.stepSet, Actor.system, StepId.payrollUpdate, StepState.stopped, null),
        (HistoryType.statusChanged, Actor.system, null, null, RequestStatus.failed),
      ]);
    });

    test('UT23: an outcome on a STOPPED step is refused', () {
      var r = toInProgress(proposed: changing(location: true));
      r = apply(r, StepId.facilitiesWorkspace, Outcome.failed);
      expect(applyError(r, StepId.orgRecordUpdate, Outcome.completed), TransferMessages.requestClosed);
    });

    test('SD-09: a downstream failure carries no reason', () {
      var r = toInProgress(proposed: changing(location: true));
      r = apply(r, StepId.facilitiesWorkspace, Outcome.failed, reason: 'ignored');
      expect(r.step(StepId.facilitiesWorkspace)!.reason, isNull);
    });
  });

  group('refusals (AC26)', () {
    test('UT25: any outcome on a closed request → "This request is already closed."', () {
      final rejected = apply(submitOk(), StepId.managerApproval, Outcome.rejected, reason: 'No');
      expect(applyError(rejected, StepId.managerApproval, Outcome.approved), TransferMessages.requestClosed);
      expect(applyError(rejected, StepId.hrEligibility, Outcome.approved), TransferMessages.requestClosed);
    });

    test('UT26: HR outcome while PENDING_MANAGER_APPROVAL → "This step is not pending."', () {
      expect(applyError(submitOk(), StepId.hrEligibility, Outcome.approved), TransferMessages.stepNotPending);
    });

    test('UT27: COMPLETED on MANAGER_APPROVAL → "This outcome is not valid for this step."', () {
      expect(applyError(submitOk(), StepId.managerApproval, Outcome.completed), TransferMessages.outcomeNotValid);
      final r = toInProgress();
      expect(applyError(r, StepId.orgRecordUpdate, Outcome.approved), TransferMessages.outcomeNotValid);
    });

    test('UT50: a second response to a task whose step is no longer pending is refused', () {
      final once = apply(submitOk(), StepId.managerApproval, Outcome.approved);
      expect(applyError(once, StepId.managerApproval, Outcome.approved), TransferMessages.stepNotPending);
    });

    test('UT31: a refused outcome returns no request and no history', () {
      final result = TransferWorkflow.recordOutcome(
        request: submitOk(),
        input: const RecordOutcomeInput(requestId: 'req-1', stepId: StepId.managerApproval, outcome: Outcome.rejected),
        testerId: testerUser.userId,
        now: now,
      );
      expect(result.isError, isTrue);
      expect(result.data, isNull);
    });
  });

  group('full journey audit (UT30, AC23)', () {
    test('UT30: role only → history entries, types and actors in order', () {
      var r = toInProgress(proposed: changing(role: true));
      r = apply(r, StepId.orgRecordUpdate, Outcome.completed);
      r = apply(r, StepId.payrollUpdate, Outcome.completed);
      r = apply(r, StepId.itAccessChange, Outcome.completed);

      String row(HistoryEntry e) => '${e.type.code}:${e.actor.code}';
      expect(r.history.map(row), [
        'SUBMITTED:EMPLOYEE',
        'STEP_OUTCOME:MANAGER',
        'STATUS_CHANGED:SYSTEM',
        'STEP_SET:SYSTEM',
        'STEP_OUTCOME:HR',
        'STATUS_CHANGED:SYSTEM',
        'STEP_SET:SYSTEM',
        'STEP_SET:SYSTEM',
        'STEP_SET:SYSTEM',
        'STEP_SET:SYSTEM',
        'STEP_OUTCOME:HR',
        'STEP_OUTCOME:PAYROLL',
        'STEP_OUTCOME:IT',
        'STATUS_CHANGED:SYSTEM',
        'CHANGE_SCHEDULED:SYSTEM',
      ]);
      expect(r.history.map((e) => e.sequence), List.generate(15, (i) => i + 1));
      for (final e in r.history.where((e) => e.type == HistoryType.stepOutcome)) {
        expect(e.actor, isNot(anyOf(Actor.system, Actor.employee)));
        expect(e.simulatedBy, testerUser.userId);
      }
      expect(r.status, RequestStatus.completed);
    });
  });

  group('stakeholder tasks (UT44, AC29)', () {
    test('manager and HR tasks carry current and proposed values, date and reason', () {
      final r = submitOk(proposed: changing(department: true), reason: 'Growth');
      final task = r.step(StepId.managerApproval)!.task!;

      expect(task.taskId, '${r.requestId}:MANAGER_APPROVAL');
      expect(task.employeeId, employeeA.userId);
      expect(task.employeeName, employeeA.displayName);
      expect(task.effectiveDate, DateTime(2026, 10, 15));
      expect(task.payload, {
        'currentDepartmentId': 'dept-eng',
        'currentLocationId': 'loc-blr',
        'currentRoleId': 'role-swe',
        'proposedDepartmentId': 'dept-sales',
        'proposedLocationId': 'loc-blr',
        'proposedRoleId': 'role-swe',
        'reason': 'Growth',
      });

      final hr = apply(r, StepId.managerApproval, Outcome.approved).step(StepId.hrEligibility)!.task!;
      expect(hr.payload, task.payload);
    });

    test('downstream payloads match the Stakeholder contract; IT lists provision and remove', () {
      final r = toInProgress(proposed: changing(department: true, location: true, role: true));
      Map<String, String> payload(StepId id) => r.step(id)!.task!.payload;

      expect(payload(StepId.orgRecordUpdate),
          {'newDepartmentId': 'dept-sales', 'newLocationId': 'loc-mum', 'newRoleId': 'role-tl'});
      expect(payload(StepId.payrollUpdate), {'newRoleId': 'role-tl', 'newLocationId': 'loc-mum'});
      expect(payload(StepId.itAccessChange), {
        'provisionDepartmentId': 'dept-sales',
        'provisionRoleId': 'role-tl',
        'removeDepartmentId': 'dept-eng',
        'removeRoleId': 'role-swe',
      });
      expect(payload(StepId.facilitiesWorkspace), {'newLocationId': 'loc-mum'});
    });

    test('a NOT_REQUIRED step gets no task', () {
      final r = toInProgress(proposed: changing(department: true));
      expect(r.step(StepId.payrollUpdate)!.task, isNull);
    });
  });
}
