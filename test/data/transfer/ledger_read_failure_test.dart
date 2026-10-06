// Gate 2 G2-03 — a failed ledger read is an error, never "no data". No
// operation writes after a failed read, so stored requests, history and
// scheduled changes survive (AC23). Read-only operations report the failure
// instead of showing an empty list or "No request found."

import 'package:flutter_test/flutter_test.dart';

import 'package:employee_transfer_project/data/transfer/datasources/transfer_ledger_local_datasource.dart';
import 'package:employee_transfer_project/domain/transfer/entities/enums.dart';
import 'package:employee_transfer_project/domain/transfer/entities/inputs.dart';
import 'package:employee_transfer_project/domain/transfer/entities/transfer_request.dart';

import '../../support/failing_local_db_service.dart';
import '../../support/transfer_env.dart';
import '../../support/transfer_fixtures.dart';

void main() {
  const box = TransferLedgerLocalDataSource.box;
  const failure = FailingLocalDbService.readFailure;
  late FailingLocalDbService db;
  late TransferEnv env;
  late TransferRequest existing;

  setUp(() async {
    db = FailingLocalDbService();
    env = await TransferEnv.create(db);
    existing = await env.submitAs(employeeA.userId);
    db.writes.clear();
    db.failReadsOn.add(box);
  });

  /// Stored ledger for employee A once reads work again.
  Future<List<String>> storedRequestIds() async {
    db.failReadsOn.clear();
    final ledger = (await env.ledgers.get(employeeA.userId)).data!;
    return [for (final r in ledger.requests) r.requestId];
  }

  group('datasource', () {
    test('get: a failed read is an error; an absent ledger is success(null)', () async {
      expect((await env.ledgers.get(employeeA.userId)).message, failure);

      db.failReadsOn.clear();
      final absent = await env.ledgers.get(employeeB.userId);
      expect(absent.isSuccess, isTrue);
      expect(absent.data, isNull);
    });

    test('all: a failed read is an error, not an empty list', () async {
      expect((await env.ledgers.all()).message, failure);
    });
  });

  test('OP01: read fails → error, nothing written, earlier request kept', () async {
    await env.signInAs(employeeA.userId);
    final result = await env.repository.submitTransferRequest(submitInput(submissionId: 'sub-2'));

    expect(result.message, failure);
    expect(db.writes, isNot(contains(box)));
    expect(await storedRequestIds(), [existing.requestId]);
  });

  test('OP06: read fails → error (not "No request found."), nothing written', () async {
    await env.signInAs(testerUser.userId);
    final result = await env.repository.recordStakeholderOutcome(
      RecordOutcomeInput(requestId: existing.requestId, stepId: StepId.managerApproval, outcome: Outcome.approved),
    );

    expect(result.message, failure);
    expect(db.writes, isNot(contains(box)));
    db.failReadsOn.clear();
    final ledger = (await env.ledgers.get(employeeA.userId)).data!;
    expect(ledger.request(existing.requestId)!.step(StepId.managerApproval)!.state, StepState.pending);
  });

  test('OP07: read fails → error, not an empty task list', () async {
    await env.signInAs(testerUser.userId);
    expect((await env.repository.listOpenStakeholderTasks()).message, failure);
  });

  test('OP02–OP05: read fails → error, not "no active request", an empty list or "No request found."', () async {
    await env.signInAs(employeeA.userId);
    final repo = env.repository;

    expect((await repo.getMyActiveTransferRequest()).message, failure);
    expect((await repo.listMyTransferRequests()).message, failure);
    expect((await repo.getMyTransferRequest(existing.requestId)).message, failure);
    expect((await repo.getRequestHistory(existing.requestId)).message, failure);
  });

  test('Gate 2 re-review: current values read fails → the storage error, not "employees only"', () async {
    await env.signInAs(employeeA.userId);
    expect((await env.repository.getMyCurrentValues()).message, failure);
  });

  test('scheduleOrganisationalChange: read fails → error, nothing written', () async {
    final result = await env.profile.scheduleOrganisationalChange(
      employeeA.userId,
      requestId: existing.requestId,
      values: existing.proposed,
      effectiveFrom: existing.effectiveDate,
    );

    expect(result.message, failure);
    expect(db.writes, isNot(contains(box)));
    expect(await storedRequestIds(), [existing.requestId]);
  });
}
