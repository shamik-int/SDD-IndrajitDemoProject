// employee-internal-transfer.T04 — TransferRequestRepositoryImpl over real
// Hive: access rules (signed in → role → ownership), idempotent submit,
// active state, one-put atomic saves including the schedule, OP07.

import 'package:flutter_test/flutter_test.dart';

import 'package:employee_transfer_project/core/constants/transfer_messages.dart';
import 'package:employee_transfer_project/core/local_db/local_db_service.dart';
import 'package:employee_transfer_project/domain/transfer/entities/enums.dart';
import 'package:employee_transfer_project/domain/transfer/entities/inputs.dart';
import 'package:employee_transfer_project/domain/transfer/entities/scheduled_change.dart';

import '../../support/transfer_env.dart';
import '../../support/transfer_fixtures.dart';

void main() {
  final sandbox = HiveSandbox();
  late TransferEnv env;

  setUp(() async {
    sandbox.setUp();
    env = await TransferEnv.create(LocalDbService());
  });
  tearDown(sandbox.tearDown);

  Future<List<String?>> everyOperation() async {
    final repo = env.repository;
    return [
      (await repo.submitTransferRequest(submitInput())).message,
      (await repo.getMyActiveTransferRequest()).message,
      (await repo.listMyTransferRequests()).message,
      (await repo.getMyTransferRequest('any')).message,
      (await repo.getRequestHistory('any')).message,
      (await repo.recordStakeholderOutcome(
        const RecordOutcomeInput(requestId: 'any', stepId: StepId.managerApproval, outcome: Outcome.approved),
      )).message,
      (await repo.listOpenStakeholderTasks()).message,
    ];
  }

  group('access rules', () {
    test('UT29, AC27: nobody signed in → every operation OP01–OP07 returns "Please sign in."', () async {
      expect(await everyOperation(), List.filled(7, TransferMessages.pleaseSignIn));
      expect((await env.repository.getMyCurrentValues()).message, TransferMessages.pleaseSignIn);
    });

    test('UT54, AC32: TESTER calling OP01–OP05 → "This action is for employees only."; no request created', () async {
      await env.signInAs(testerUser.userId);
      final messages = await everyOperation();

      expect(messages.take(5), List.filled(5, TransferMessages.employeesOnly));
      expect((await env.ledgers.all()), isEmpty);
    });

    test('UT52, AC32: EMPLOYEE calling OP06 on their own pending request → tester-only; nothing changes', () async {
      final r = await env.submitAs(employeeA.userId);
      final result = await env.repository.recordStakeholderOutcome(
        RecordOutcomeInput(requestId: r.requestId, stepId: StepId.managerApproval, outcome: Outcome.approved),
      );

      expect(result.message, TransferMessages.testerOnly);
      final after = (await env.repository.getMyTransferRequest(r.requestId)).data!;
      expect(after, r);
    });

    test('UT53: EMPLOYEE calling OP07 → tester-only; no task returned', () async {
      await env.submitAs(employeeA.userId);
      final result = await env.repository.listOpenStakeholderTasks();
      expect(result.message, TransferMessages.testerOnly);
      expect(result.data, isNull);
    });

    test('UT28, AC22: employee B cannot list, open or read the history of A\'s request', () async {
      final a = await env.submitAs(employeeA.userId);
      await env.submitAs(employeeB.userId, proposed: changing(location: true));

      final list = (await env.repository.listMyTransferRequests()).data!;
      expect(list.map((s) => s.requestId), isNot(contains(a.requestId)));
      expect((await env.repository.getMyTransferRequest(a.requestId)).message, TransferMessages.noRequestFound);
      expect((await env.repository.getRequestHistory(a.requestId)).message, TransferMessages.noRequestFound);
      expect((await env.repository.getMyTransferRequest('missing')).message, TransferMessages.noRequestFound);
    });
  });

  group('OP01 submit', () {
    test('UT02, AC02: the snapshot equals the profile values as of today', () async {
      final r = await env.submitAs(employeeA.userId);
      expect(r.current, (await env.profile.getCurrentValues(employeeA.userId, asOf: env.clock.today())));
      expect((await env.repository.getMyCurrentValues()).data, baseCurrent);
    });

    test('UT09, AC07: submit while one is in progress → error; still one request', () async {
      await env.submitAs(employeeA.userId);
      final second = await env.repository.submitTransferRequest(submitInput(submissionId: 'sub-2'));

      expect(second.message, TransferMessages.alreadyInProgress);
      expect((await env.repository.listMyTransferRequests()).data, hasLength(1));
    });

    test('UT10, AC08: same submissionId twice → same request; 1 request, 1 history entry', () async {
      final first = await env.submitAs(employeeA.userId);
      final again = await env.repository.submitTransferRequest(submitInput(submissionId: 'sub-1'));

      expect(again.data, first);
      expect((await env.repository.listMyTransferRequests()).data, hasLength(1));
      expect((await env.repository.getRequestHistory(first.requestId)).data, hasLength(1));
    });

    test('AC08: the idempotency check comes before the errors (a repeat after the date passes still returns it)', () async {
      final first = await env.submitAs(employeeA.userId, effectiveDate: DateTime(2026, 10, 2));
      env.clock.set(DateTime(2026, 10, 3));
      final again = await env.repository.submitTransferRequest(
        submitInput(submissionId: 'sub-1', effectiveDate: DateTime(2026, 10, 2)),
      );
      expect(again.data!.requestId, first.requestId);
    });

    test('UT24, AC18: new submission accepted after REJECTED_BY_MANAGER, REJECTED_BY_HR and FAILED the same day', () async {
      var r = await env.submitAs(employeeA.userId, submissionId: 's1');
      await env.record(r.requestId, StepId.managerApproval, Outcome.rejected, reason: 'No');

      r = await env.submitAs(employeeA.userId, submissionId: 's2');
      await env.record(r.requestId, StepId.managerApproval, Outcome.approved);
      await env.record(r.requestId, StepId.hrEligibility, Outcome.rejected, reason: 'No');

      r = await env.submitAs(employeeA.userId, submissionId: 's3');
      await env.approveManagerAndHr(r.requestId);
      await env.record(r.requestId, StepId.payrollUpdate, Outcome.failed);

      await env.submitAs(employeeA.userId, submissionId: 's4');
      expect((await env.repository.listMyTransferRequests()).data, hasLength(4));
    });

    test('UT48, UT64, AC34: COMPLETED awaiting effect blocks until the effective date; then the snapshot has the new values', () async {
      final r = await env.submitAs(employeeA.userId, proposed: changing(role: true));
      await env.approveManagerAndHr(r.requestId);
      for (final s in [StepId.orgRecordUpdate, StepId.payrollUpdate, StepId.itAccessChange]) {
        await env.record(r.requestId, s, Outcome.completed);
      }

      await env.signInAs(employeeA.userId);
      final active = (await env.repository.getMyActiveTransferRequest()).data!;
      expect(active.awaitingEffect!.requestId, r.requestId);
      expect(active.inProgress, isNull);

      final blocked = await env.repository.submitTransferRequest(
        submitInput(submissionId: 's2', proposed: changing(location: true), effectiveDate: DateTime(2026, 10, 30)),
      );
      expect(blocked.message,
          'Your previous transfer takes effect on 15 Oct 2026. You can submit a new request from that date.');

      env.clock.set(DateTime(2026, 10, 15, 9));
      expect((await env.repository.getMyActiveTransferRequest()).data!.canSubmit, isTrue);
      final accepted = await env.repository.submitTransferRequest(
        submitInput(submissionId: 's3', proposed: changing(location: true), effectiveDate: DateTime(2026, 10, 30)),
      );
      expect(accepted.isSuccess, isTrue);
      expect(accepted.data!.current.values, changing(role: true));
    });

    test('OP02: a request in progress is reported as inProgress', () async {
      final r = await env.submitAs(employeeA.userId);
      final active = (await env.repository.getMyActiveTransferRequest()).data!;
      expect(active.inProgress!.requestId, r.requestId);
      expect(active.canSubmit, isFalse);
    });
  });

  group('OP03 / OP05', () {
    test('UT45, AC30: three own requests newest first; another employee\'s not listed', () async {
      final ids = <String>[];
      for (var i = 1; i <= 3; i++) {
        final r = await env.submitAs(employeeA.userId, submissionId: 's$i');
        ids.add(r.requestId);
        await env.record(r.requestId, StepId.managerApproval, Outcome.rejected, reason: 'No');
        env.clock.advance(const Duration(hours: 1));
      }
      final b = await env.submitAs(employeeB.userId, proposed: changing(location: true));

      await env.signInAs(employeeA.userId);
      final list = (await env.repository.listMyTransferRequests()).data!;
      expect(list.map((s) => s.requestId), ids.reversed.toList());
      expect(list.map((s) => s.requestId), isNot(contains(b.requestId)));
      expect(list.first.status, RequestStatus.rejectedByManager);
    });

    test('OP05: history oldest first, SUBMITTED first', () async {
      final r = await env.submitAs(employeeA.userId);
      await env.record(r.requestId, StepId.managerApproval, Outcome.approved);

      await env.signInAs(employeeA.userId);
      final history = (await env.repository.getRequestHistory(r.requestId)).data!;
      expect(history.first.type, HistoryType.submitted);
      expect(history.map((e) => e.sequence), [1, 2, 3, 4]);
    });
  });

  group('OP06 and the schedule', () {
    test('UT59, AC16, AC35: last step completing saves one schedule and one CHANGE_SCHEDULED entry', () async {
      final r = await env.submitAs(employeeA.userId, proposed: changing(role: true));
      await env.approveManagerAndHr(r.requestId);
      await env.record(r.requestId, StepId.orgRecordUpdate, Outcome.completed);
      expect((await env.ledgers.get(employeeA.userId))!.scheduledChanges, isEmpty); // UT58
      await env.record(r.requestId, StepId.payrollUpdate, Outcome.completed);
      await env.record(r.requestId, StepId.itAccessChange, Outcome.completed);

      final ledger = (await env.ledgers.get(employeeA.userId))!;
      expect(ledger.scheduledChanges, hasLength(1));
      expect(ledger.scheduledChanges.single.values, changing(role: true));
      expect(ledger.scheduledChanges.single.effectiveFrom, DateTime(2026, 10, 15));
      final stored = ledger.request(r.requestId)!;
      expect(stored.status, RequestStatus.completed);
      expect(stored.history.where((e) => e.type == HistoryType.changeScheduled), hasLength(1));
    });

    test('UT63: schedule error on the last step → OP06 returns it; step PENDING, IN_PROGRESS, no history added', () async {
      final r = await env.submitAs(employeeA.userId, proposed: changing(department: true));
      await env.approveManagerAndHr(r.requestId);
      await env.record(r.requestId, StepId.orgRecordUpdate, Outcome.completed);

      // Misuse the contract: another change for this employee not yet in effect.
      final ledger = (await env.ledgers.get(employeeA.userId))!;
      await env.ledgers.put(ledger.withScheduledChanges([
        ScheduledChange(
          requestId: 'other',
          employeeId: employeeA.userId,
          values: changing(location: true),
          effectiveFrom: DateTime(2026, 12, 1),
          scheduledAt: DateTime(2026, 10, 1),
        ),
      ]));
      final historyBefore = ledger.request(r.requestId)!.history;

      final error = await env.record(r.requestId, StepId.itAccessChange, Outcome.completed);

      expect(error, TransferMessages.anotherTransferScheduled);
      final after = (await env.ledgers.get(employeeA.userId))!.request(r.requestId)!;
      expect(after.step(StepId.itAccessChange)!.state, StepState.pending);
      expect(after.status, RequestStatus.inProgress);
      expect(after.history, historyBefore);
    });

    test('UT50, XF06: two quick OP06 calls on the last step — the second is refused; one schedule', () async {
      final r = await env.submitAs(employeeA.userId, proposed: changing(department: true));
      await env.approveManagerAndHr(r.requestId);
      await env.record(r.requestId, StepId.orgRecordUpdate, Outcome.completed);
      await env.signInAs(testerUser.userId);

      final input = RecordOutcomeInput(requestId: r.requestId, stepId: StepId.itAccessChange, outcome: Outcome.completed);
      final results = await Future.wait([
        env.repository.recordStakeholderOutcome(input),
        env.repository.recordStakeholderOutcome(input),
      ]);

      expect(results.where((x) => x.isSuccess), hasLength(1));
      expect(results.firstWhere((x) => x.isError).message, TransferMessages.requestClosed);
      final ledger = (await env.ledgers.get(employeeA.userId))!;
      expect(ledger.scheduledChanges, hasLength(1));
      final history = ledger.request(r.requestId)!.history;
      expect(history.where((e) => e.type == HistoryType.changeScheduled), hasLength(1));
      expect(history.where((e) => e.type == HistoryType.statusChanged && e.toStatus == RequestStatus.completed),
          hasLength(1));
    });

    test('UT31: a refused outcome adds no history entry', () async {
      final r = await env.submitAs(employeeA.userId);
      expect(await env.record(r.requestId, StepId.managerApproval, Outcome.rejected), TransferMessages.rejectionReasonRequired);
      expect(await env.record('missing', StepId.managerApproval, Outcome.approved), TransferMessages.noRequestFound);

      await env.signInAs(employeeA.userId);
      expect((await env.repository.getRequestHistory(r.requestId)).data, hasLength(1));
    });

    test('AC23: history is append-only — every earlier entry is unchanged after each outcome', () async {
      final r = await env.submitAs(employeeA.userId, proposed: changing(location: true));
      final snapshots = <List<Object>>[];
      Future<void> snap() async => snapshots.add((await env.ledgers.get(employeeA.userId))!.request(r.requestId)!.history);

      await snap();
      await env.record(r.requestId, StepId.managerApproval, Outcome.approved);
      await snap();
      await env.record(r.requestId, StepId.hrEligibility, Outcome.approved);
      await snap();
      await env.record(r.requestId, StepId.facilitiesWorkspace, Outcome.failed);
      await snap();

      for (var i = 1; i < snapshots.length; i++) {
        expect(snapshots[i].take(snapshots[i - 1].length), snapshots[i - 1]);
        expect(snapshots[i].length, greaterThan(snapshots[i - 1].length));
      }
    });
  });

  group('OP07', () {
    test('UT70: tester lists open tasks across two employees, oldest first, pending steps only', () async {
      final a = await env.submitAs(employeeA.userId);
      env.clock.advance(const Duration(minutes: 10));
      final b = await env.submitAs(employeeB.userId, proposed: changing(location: true));
      env.clock.advance(const Duration(minutes: 10));
      await env.record(a.requestId, StepId.managerApproval, Outcome.approved);

      await env.signInAs(testerUser.userId);
      final tasks = (await env.repository.listOpenStakeholderTasks()).data!;

      expect(tasks.map((t) => (t.task.requestId, t.task.stepId)), [
        (b.requestId, StepId.managerApproval),
        (a.requestId, StepId.hrEligibility),
      ]);
      expect(tasks.every((t) => !t.effectiveDatePassed), isTrue);
    });

    test('UT65 (task mark): a task whose effective date has passed is marked', () async {
      final r = await env.submitAs(employeeA.userId, effectiveDate: DateTime(2026, 10, 10));
      env.clock.set(DateTime(2026, 10, 12));

      await env.signInAs(testerUser.userId);
      final task = (await env.repository.listOpenStakeholderTasks()).data!.single;
      expect(task.task.requestId, r.requestId);
      expect(task.effectiveDatePassed, isTrue);
    });
  });

  test('performance: operations on a ledger with 20 requests finish well under 500 ms', () async {
    for (var i = 0; i < 20; i++) {
      final r = await env.submitAs(employeeA.userId, submissionId: 'p$i');
      await env.record(r.requestId, StepId.managerApproval, Outcome.rejected, reason: 'No');
    }
    await env.signInAs(employeeA.userId);

    final watch = Stopwatch()..start();
    await env.repository.submitTransferRequest(submitInput(submissionId: 'p-last'));
    await env.repository.listMyTransferRequests();
    watch.stop();

    expect(watch.elapsedMilliseconds, lessThan(500));
  });
}
