// employee-internal-transfer.T08 — cross-flow scenarios XF01–XF09 (spec v2.4),
// end to end over the real repository, demo portal adapters and real Hive,
// with an adjustable clock. Dates are device local dates in 2026.

import 'package:flutter_test/flutter_test.dart';

import 'package:employee_transfer_project/core/constants/transfer_messages.dart';
import 'package:employee_transfer_project/core/local_db/local_db_service.dart';
import 'package:employee_transfer_project/domain/transfer/entities/enums.dart';
import 'package:employee_transfer_project/domain/transfer/entities/inputs.dart';
import 'package:employee_transfer_project/domain/transfer/entities/transfer_request.dart';
import 'package:employee_transfer_project/presentation/transfer/employee/confirmation_builder.dart';

import '../support/transfer_env.dart';
import '../support/transfer_fixtures.dart';

void main() {
  final sandbox = HiveSandbox();
  late TransferEnv env;

  setUp(() async {
    sandbox.setUp();
    env = await TransferEnv.create(LocalDbService(), now: DateTime(2026, 10, 1, 9));
  });
  tearDown(sandbox.tearDown);

  DateTime day(int d, [int m = 10]) => DateTime(2026, m, d, 9);

  Future<TransferRequest> own(String id) async {
    await env.signInAs(employeeA.userId);
    return (await env.repository.getMyTransferRequest(id)).data!;
  }

  Future<List<String>> confirmation(TransferRequest r) async =>
      ConfirmationBuilder.build(r, today: env.clock.today(), refs: env.refs)!.lines;

  Future<void> complete(String id, List<StepId> steps) async {
    for (final s in steps) {
      expect(await env.record(id, s, Outcome.completed), isNull, reason: s.code);
    }
  }

  test('XF01 — org record recorded, then Payroll fails: FAILED, nothing ever scheduled', () async {
    final a = await env.submitAs(employeeA.userId, proposed: changing(department: true, location: true));
    await env.approveManagerAndHr(a.requestId);
    await complete(a.requestId, [StepId.orgRecordUpdate, StepId.itAccessChange]);
    expect(await env.record(a.requestId, StepId.payrollUpdate, Outcome.failed), isNull);

    final r = await own(a.requestId);
    expect(r.status, RequestStatus.failed);
    expect(r.step(StepId.payrollUpdate)!.state, StepState.failed);
    expect(r.step(StepId.facilitiesWorkspace)!.state, StepState.stopped);
    expect(r.step(StepId.orgRecordUpdate)!.state, StepState.completed);
    expect(r.step(StepId.itAccessChange)!.state, StepState.completed);

    for (final asOf in [DateTime(2026, 10, 14), DateTime(2026, 10, 15), DateTime(2026, 11, 1)]) {
      expect(await env.profile.pendingScheduledChange(employeeA.userId, asOf: asOf), isNull);
      expect((await env.profile.getCurrentValues(employeeA.userId, asOf: asOf))!.values, baseValues);
    }
    expect(r.history.any((e) => e.type == HistoryType.changeScheduled), isFalse);
    final stopped = r.history.singleWhere((e) => e.type == HistoryType.stepSet && e.toState == StepState.stopped);
    expect(stopped.stepId, StepId.facilitiesWorkspace);
    expect(stopped.actor, Actor.system);
    expect(r.history.last.type, HistoryType.statusChanged);
    expect(r.history.last.actor, Actor.system);

    final lines = await confirmation(r);
    expect(lines, contains('Failed step: Payroll update.'));
    expect(lines.join('\n'), contains('Organisational record update'));
    expect(lines, contains('Stopped steps: Facilities: workspace at the new location.'));
    expect(lines, contains('Your department, location and role have not changed.'));

    await env.submitAs(employeeA.userId, submissionId: 'same-day');
  });

  test('XF02 — scheduled transfer, then a second request: blocked until 15 Oct, then accepted with A\'s values', () async {
    final a = await env.submitAs(employeeA.userId, proposed: changing(role: true));
    await env.approveManagerAndHr(a.requestId);
    await complete(a.requestId, [StepId.orgRecordUpdate, StepId.payrollUpdate, StepId.itAccessChange]);

    await env.signInAs(employeeA.userId);
    final blocked = await env.repository.submitTransferRequest(
      submitInput(submissionId: 'b', proposed: changing(role: true, location: true), effectiveDate: DateTime(2026, 10, 30)),
    );
    expect(blocked.message,
        'Your previous transfer takes effect on 15 Oct 2026. You can submit a new request from that date.');
    expect((await env.repository.listMyTransferRequests()).data, hasLength(1));
    expect((await env.ledgers.get(employeeA.userId))!.scheduledChanges, hasLength(1));

    env.clock.set(day(15));
    expect((await env.repository.getMyCurrentValues()).data!.values, changing(role: true));
    final b = await env.repository.submitTransferRequest(
      submitInput(submissionId: 'b', proposed: changing(role: true, location: true), effectiveDate: DateTime(2026, 10, 30)),
    );
    expect(b.isSuccess, isTrue);
    expect(b.data!.current.values, changing(role: true));

    final pending = (await env.ledgers.get(employeeA.userId))!
        .scheduledChanges
        .where((c) => DateTime(2026, 10, 15).isBefore(c.effectiveFrom));
    expect(pending, isEmpty);
  });

  test('XF03 — employee tries the simulation; tester approves; tester cannot submit', () async {
    final e = await env.submitAs(employeeA.userId);

    final approve = RecordOutcomeInput(requestId: e.requestId, stepId: StepId.managerApproval, outcome: Outcome.approved);
    expect((await env.repository.recordStakeholderOutcome(approve)).message, TransferMessages.testerOnly);
    expect((await env.repository.listOpenStakeholderTasks()).message, TransferMessages.testerOnly);
    expect(await own(e.requestId), e);

    await env.signInAs(testerUser.userId);
    final tasks = (await env.repository.listOpenStakeholderTasks()).data!;
    expect(tasks.single.task.requestId, e.requestId);
    expect((await env.repository.recordStakeholderOutcome(approve)).isSuccess, isTrue);
    expect((await env.repository.submitTransferRequest(submitInput(submissionId: 't'))).message,
        TransferMessages.employeesOnly);

    final outcome = (await own(e.requestId)).history.singleWhere((h) => h.type == HistoryType.stepOutcome);
    expect(outcome.actor, Actor.manager);
    expect(outcome.simulatedBy, testerUser.userId);
  });

  test('XF04 — manager approves: exactly MANAGER, SYSTEM, SYSTEM; no EMPLOYEE or tester actor', () async {
    final r = await env.submitAs(employeeA.userId);
    await env.record(r.requestId, StepId.managerApproval, Outcome.approved);

    final added = (await own(r.requestId)).history.skip(1).toList();
    expect(added.map((e) => (e.type, e.actor, e.stepId)), [
      (HistoryType.stepOutcome, Actor.manager, StepId.managerApproval),
      (HistoryType.statusChanged, Actor.system, null),
      (HistoryType.stepSet, Actor.system, StepId.hrEligibility),
    ]);
    expect(added[1].fromStatus, RequestStatus.pendingManagerApproval);
    expect(added[1].toStatus, RequestStatus.pendingHrEligibility);
    expect(added[2].toState, StepState.pending);
    expect(added.map((e) => e.actor), isNot(contains(Actor.employee)));
  });

  group('XF05 — effective date passes while HR is pending', () {
    late String id;

    setUp(() async {
      env.clock.set(day(1));
      id = (await env.submitAs(employeeA.userId, proposed: changing(role: true), effectiveDate: DateTime(2026, 10, 10)))
          .requestId;
      env.clock.set(day(8));
      await env.record(id, StepId.managerApproval, Outcome.approved);
      env.clock.set(day(12));
    });

    test('on 12 Oct: unchanged, marked, and still blocks a new request', () async {
      final r = await own(id);
      expect(r.status, RequestStatus.pendingHrEligibility);
      expect(r.effectiveDate, DateTime(2026, 10, 10));
      expect(r.isEffectiveDatePassed(env.clock.today()), isTrue);
      expect((await env.repository.submitTransferRequest(submitInput(submissionId: 'n', effectiveDate: DateTime(2026, 11, 1)))).message,
          TransferMessages.alreadyInProgress);

      await env.signInAs(testerUser.userId);
      final task = (await env.repository.listOpenStakeholderTasks()).data!.single;
      expect(task.task.stepId, StepId.hrEligibility);
      expect(task.effectiveDatePassed, isTrue);
    });

    test('(a) HR approves on 12 Oct, completes on 14 Oct → effectiveFrom 10 Oct, profile new from 14 Oct', () async {
      await env.record(id, StepId.hrEligibility, Outcome.approved);
      env.clock.set(day(14));
      await complete(id, [StepId.orgRecordUpdate, StepId.payrollUpdate, StepId.itAccessChange]);

      final change = (await env.ledgers.get(employeeA.userId))!.scheduledChanges.single;
      expect(change.effectiveFrom, DateTime(2026, 10, 10));
      expect((await env.profile.getCurrentValues(employeeA.userId, asOf: DateTime(2026, 10, 13)))!.values, baseValues);
      expect((await env.profile.getCurrentValues(employeeA.userId, asOf: DateTime(2026, 10, 14)))!.values,
          changing(role: true));

      final lines = await confirmation(await own(id));
      expect(lines, contains('Effective from 10 Oct 2026.'));
      expect(lines, contains(
          'This date had passed when your transfer completed, so the new values show in your profile from 14 Oct 2026.'));
      expect(lines.last, 'You may submit a new request.');
      await env.submitAs(employeeA.userId, submissionId: 'next', effectiveDate: DateTime(2026, 11, 1),
          proposed: changing(location: true));
    });

    test('(b) HR rejects on 12 Oct → REJECTED_BY_HR, nothing scheduled', () async {
      expect(await env.record(id, StepId.hrEligibility, Outcome.rejected, reason: 'Date passed'), isNull);
      expect((await own(id)).status, RequestStatus.rejectedByHr);
      expect((await env.ledgers.get(employeeA.userId))!.scheduledChanges, isEmpty);
    });
  });

  test('XF06 — same organisational change triggered twice: one change, one CHANGE_SCHEDULED, one → COMPLETED', () async {
    final r = await env.submitAs(employeeA.userId, proposed: changing(role: true));
    await env.approveManagerAndHr(r.requestId);
    await complete(r.requestId, [StepId.orgRecordUpdate, StepId.itAccessChange]);

    await env.signInAs(testerUser.userId);
    final input = RecordOutcomeInput(requestId: r.requestId, stepId: StepId.payrollUpdate, outcome: Outcome.completed);
    final both = await Future.wait([
      env.repository.recordStakeholderOutcome(input),
      env.repository.recordStakeholderOutcome(input),
    ]);
    expect(both.where((x) => x.isSuccess), hasLength(1));
    expect([TransferMessages.stepNotPending, TransferMessages.requestClosed], contains(both.firstWhere((x) => x.isError).message));

    final first = (await env.ledgers.get(employeeA.userId))!.scheduledChanges.single;
    final repeat = await env.profile.scheduleOrganisationalChange(employeeA.userId,
        requestId: r.requestId, values: changing(role: true), effectiveFrom: DateTime(2026, 10, 15));
    expect(repeat.data, first);

    final stored = (await env.ledgers.get(employeeA.userId))!;
    expect(stored.scheduledChanges, hasLength(1));
    final history = stored.request(r.requestId)!.history;
    expect(history.where((e) => e.type == HistoryType.changeScheduled), hasLength(1));
    expect(history.where((e) => e.type == HistoryType.statusChanged && e.toStatus == RequestStatus.completed), hasLength(1));
  });

  test('XF07 — A signs out, B signs in: only B\'s data; A\'s intact afterwards', () async {
    final a1 = await env.submitAs(employeeA.userId, submissionId: 'a1');
    await env.record(a1.requestId, StepId.managerApproval, Outcome.rejected, reason: 'No');
    final a2 = await env.submitAs(employeeA.userId, submissionId: 'a2');
    await env.signOut();

    for (final message in [
      (await env.repository.listMyTransferRequests()).message,
      (await env.repository.getMyTransferRequest(a2.requestId)).message,
      (await env.repository.getMyActiveTransferRequest()).message,
    ]) {
      expect(message, TransferMessages.pleaseSignIn);
    }

    final b = await env.submitAs(employeeB.userId, submissionId: 'b1', proposed: changing(location: true));
    final list = (await env.repository.listMyTransferRequests()).data!;
    expect(list.map((s) => s.requestId), [b.requestId]);
    for (final id in [a1.requestId, a2.requestId]) {
      expect((await env.repository.getMyTransferRequest(id)).message, TransferMessages.noRequestFound);
      expect((await env.repository.getRequestHistory(id)).message, TransferMessages.noRequestFound);
    }
    expect((await env.repository.getMyCurrentValues()).data!.managerName, 'Manager B');
    expect((await env.repository.getMyActiveTransferRequest()).data!.inProgress!.requestId, b.requestId);

    await env.signOut();
    await env.signInAs(employeeA.userId);
    expect((await env.repository.listMyTransferRequests()).data!.map((s) => s.requestId).toSet(),
        {a1.requestId, a2.requestId});
  });

  test('XF08 — one downstream step fails after the others completed: nothing stopped, nothing scheduled', () async {
    final r = await env.submitAs(employeeA.userId, proposed: changing(role: true, location: true));
    await env.approveManagerAndHr(r.requestId);
    await complete(r.requestId, [StepId.orgRecordUpdate, StepId.payrollUpdate, StepId.facilitiesWorkspace]);
    expect(await env.record(r.requestId, StepId.itAccessChange, Outcome.failed), isNull);

    final after = await own(r.requestId);
    expect(after.status, RequestStatus.failed);
    for (final s in [StepId.orgRecordUpdate, StepId.payrollUpdate, StepId.facilitiesWorkspace]) {
      expect(after.step(s)!.state, StepState.completed);
    }
    expect(after.step(StepId.itAccessChange)!.state, StepState.failed);
    expect(after.history.where((e) => e.toState == StepState.stopped), isEmpty);
    expect((await env.ledgers.get(employeeA.userId))!.scheduledChanges, isEmpty);
    expect((await env.profile.getCurrentValues(employeeA.userId, asOf: DateTime(2026, 11, 1)))!.values, baseValues);
    await env.submitAs(employeeA.userId, submissionId: 'again');
  });

  test('XF09 — future date, downstream failure, then a new request that completes', () async {
    final a = await env.submitAs(employeeA.userId, submissionId: 'a', proposed: changing(role: true));
    await env.approveManagerAndHr(a.requestId);
    await complete(a.requestId, [StepId.orgRecordUpdate]);
    await env.record(a.requestId, StepId.payrollUpdate, Outcome.failed);

    final b = await env.submitAs(employeeA.userId,
        submissionId: 'b', proposed: changing(location: true), effectiveDate: DateTime(2026, 10, 30));
    expect(b.current.values, baseValues);

    env.clock.set(day(5));
    await env.approveManagerAndHr(b.requestId);
    await complete(b.requestId, [StepId.orgRecordUpdate, StepId.payrollUpdate, StepId.facilitiesWorkspace]);

    final changes = (await env.ledgers.get(employeeA.userId))!.scheduledChanges;
    expect(changes.single.requestId, b.requestId);
    expect(changes.single.effectiveFrom, DateTime(2026, 10, 30));
    expect((await env.profile.getCurrentValues(employeeA.userId, asOf: DateTime(2026, 10, 15)))!.values, baseValues);
    expect((await env.profile.getCurrentValues(employeeA.userId, asOf: DateTime(2026, 10, 30)))!.values,
        changing(location: true));
  });

  test('UT24 end to end — after COMPLETED, a new request on its effective date is accepted', () async {
    final a = await env.submitAs(employeeA.userId, proposed: changing(role: true));
    await env.approveManagerAndHr(a.requestId);
    await complete(a.requestId, [StepId.orgRecordUpdate, StepId.payrollUpdate, StepId.itAccessChange]);
    env.clock.set(day(15));
    final next = await env.submitAs(employeeA.userId,
        submissionId: 'on-date', proposed: changing(role: true, location: true), effectiveDate: DateTime(2026, 11, 1));
    expect(next.status, RequestStatus.pendingManagerApproval);
  });
}
