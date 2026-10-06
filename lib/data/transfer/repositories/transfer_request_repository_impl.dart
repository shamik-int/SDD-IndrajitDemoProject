import 'package:uuid/uuid.dart';

import '../../../core/concurrency/async_lock.dart';
import '../../../core/constants/transfer_messages.dart';
import '../../../core/result/result.dart';
import '../../../core/time/clock.dart';
import '../../../domain/transfer/entities/current_user.dart';
import '../../../domain/transfer/entities/enums.dart';
import '../../../domain/transfer/entities/history_entry.dart';
import '../../../domain/transfer/entities/inputs.dart';
import '../../../domain/transfer/entities/org_values.dart';
import '../../../domain/transfer/entities/stakeholder_task.dart';
import '../../../domain/transfer/entities/transfer_ledger.dart';
import '../../../domain/transfer/entities/transfer_request.dart';
import '../../../domain/transfer/portal/portal_contracts.dart';
import '../../../domain/transfer/repositories/transfer_request_repository.dart';
import '../../../domain/transfer/workflow/schedule_book.dart';
import '../../../domain/transfer/workflow/transfer_workflow.dart';
import '../datasources/transfer_ledger_local_datasource.dart';

/// Implements OP01–OP07 (plan v4.0, "Repository call order"): access rules
/// first, then a lock-serialised read → pure workflow → one `put`. Holds no
/// per-user state: the signed-in user is read on every call (AC31).
///
/// Nothing here logs request content (constitution: no PII in logs).
class TransferRequestRepositoryImpl implements TransferRequestRepository {
  final CurrentUserProvider users;
  final EmployeeProfile profile;
  final ReferenceLists refs;
  final TransferLedgerLocalDataSource ledgers;
  final AsyncLock lock;
  final Clock clock;
  final String Function() newId;

  TransferRequestRepositoryImpl({
    required this.users,
    required this.profile,
    required this.refs,
    required this.ledgers,
    required this.lock,
    required this.clock,
    String Function()? newId,
  }) : newId = newId ?? const Uuid().v4;

  // ------------------------------------------------------ access rules

  /// OP01–OP05: signed in, then `EMPLOYEE`.
  Future<Result<CurrentUser>> _employee() async {
    final user = await users.currentUser();
    if (user == null) return Result.error(TransferMessages.pleaseSignIn);
    if (!user.isEmployee) return Result.error(TransferMessages.employeesOnly);
    return Result.success(user);
  }

  /// OP06–OP07: signed in, then `TESTER`.
  Future<Result<CurrentUser>> _tester() async {
    final user = await users.currentUser();
    if (user == null) return Result.error(TransferMessages.pleaseSignIn);
    if (!user.isTester) return Result.error(TransferMessages.testerOnly);
    return Result.success(user);
  }

  /// The employee's ledger, or empty if none is stored yet. A failed read is
  /// an error, never an empty ledger: writing after it would wipe the stored
  /// requests, history and scheduled changes (G2-03).
  Future<Result<TransferLedger>> _ledger(String employeeId) async {
    final stored = await ledgers.get(employeeId);
    if (stored.isError) return Result.error(stored.message!);
    return Result.success(stored.data ?? TransferLedger.empty(employeeId));
  }

  ActiveState _activeState(TransferLedger ledger) {
    final today = clock.today();
    TransferRequest? inProgress;
    TransferRequest? awaiting;
    for (final r in ledger.requests) {
      if (r.isInProgress) inProgress = r;
      if (r.isAwaitingEffect(today)) awaiting = r;
    }
    return inProgress != null ? ActiveState(inProgress: inProgress) : ActiveState(awaitingEffect: awaiting);
  }

  // -------------------------------------------------------------- OP01

  @override
  Future<Result<TransferRequest>> submitTransferRequest(SubmitTransferInput input) async {
    final access = await _employee();
    if (access.isError) return Result.error(access.message!);
    final employee = access.data!;

    return lock.synchronized(() async {
      final read = await _ledger(employee.userId);
      if (read.isError) return Result.error(read.message!);
      final ledger = read.data!;

      // Idempotency (BR-08) comes before every error.
      for (final r in ledger.requests) {
        if (r.submissionId == input.submissionId) return Result.success(r);
      }

      final now = clock.now();
      final values = await profile.getCurrentValues(employee.userId, asOf: clock.today());
      if (values.isError) return Result.error(values.message!);
      final current = values.data;
      if (current == null) return Result.error(TransferMessages.employeesOnly);

      final created = TransferWorkflow.submit(
        input: input,
        employee: employee,
        current: current,
        active: _activeState(ledger),
        refs: refs,
        requestId: newId(),
        now: now,
      );
      if (created.isError) return created;

      final saved = await ledgers.put(ledger.withRequest(created.data!));
      if (saved.isError) return Result.error(saved.message!);
      return created;
    });
  }

  // ---------------------------------------------------------- OP02–OP05

  @override
  Future<Result<ActiveState>> getMyActiveTransferRequest() async {
    final access = await _employee();
    if (access.isError) return Result.error(access.message!);
    final ledger = await _ledger(access.data!.userId);
    if (ledger.isError) return Result.error(ledger.message!);
    return Result.success(_activeState(ledger.data!));
  }

  @override
  Future<Result<List<TransferRequestSummary>>> listMyTransferRequests() async {
    final access = await _employee();
    if (access.isError) return Result.error(access.message!);
    final ledger = await _ledger(access.data!.userId);
    if (ledger.isError) return Result.error(ledger.message!);
    final summaries = [
      for (final r in ledger.data!.requests)
        TransferRequestSummary(
          requestId: r.requestId,
          submittedAt: r.submittedAt,
          status: r.status,
          effectiveDate: r.effectiveDate,
        ),
    ]..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return Result.success(summaries);
  }

  /// Own requests only; another employee's ID is indistinguishable from a
  /// missing one (SD-04), because only the caller's ledger is read.
  Future<Result<TransferRequest>> _ownRequest(String requestId) async {
    final access = await _employee();
    if (access.isError) return Result.error(access.message!);
    final ledger = await _ledger(access.data!.userId);
    if (ledger.isError) return Result.error(ledger.message!);
    final request = ledger.data!.request(requestId);
    if (request == null) return Result.error(TransferMessages.noRequestFound);
    return Result.success(request);
  }

  @override
  Future<Result<TransferRequest>> getMyTransferRequest(String requestId) => _ownRequest(requestId);

  @override
  Future<Result<List<HistoryEntry>>> getRequestHistory(String requestId) async {
    final request = await _ownRequest(requestId);
    if (request.isError) return Result.error(request.message!);
    final history = [...request.data!.history]..sort((a, b) => a.sequence.compareTo(b.sequence));
    return Result.success(history);
  }

  @override
  Future<Result<EmployeeCurrentValues>> getMyCurrentValues() async {
    final access = await _employee();
    if (access.isError) return Result.error(access.message!);
    final values = await profile.getCurrentValues(access.data!.userId, asOf: clock.today());
    if (values.isError) return Result.error(values.message!);
    if (values.data == null) return Result.error(TransferMessages.employeesOnly);
    return Result.success(values.data!);
  }

  // -------------------------------------------------------------- OP06

  @override
  Future<Result<TransferRequest>> recordStakeholderOutcome(RecordOutcomeInput input) async {
    final access = await _tester();
    if (access.isError) return Result.error(access.message!);
    final tester = access.data!;

    return lock.synchronized(() async {
      final all = await ledgers.all();
      if (all.isError) return Result.error(all.message!);
      TransferLedger? ledger;
      TransferRequest? request;
      for (final l in all.data!) {
        request = l.request(input.requestId);
        if (request != null) {
          ledger = l;
          break;
        }
      }
      if (ledger == null || request == null) return Result.error(TransferMessages.noRequestFound);

      final now = clock.now();
      final outcome = TransferWorkflow.recordOutcome(
        request: request,
        input: input,
        testerId: tester.userId,
        now: now,
      );
      if (outcome.isError) return Result.error(outcome.message!);

      var next = ledger.withRequest(outcome.data!.request);
      final intent = outcome.data!.schedule;
      if (intent != null) {
        // Same save as the last outcome and the status change (SD-20).
        final scheduled = ScheduleBook.schedule(
          next.scheduledChanges,
          employeeId: intent.employeeId,
          requestId: intent.requestId,
          values: intent.values,
          effectiveFrom: intent.effectiveFrom,
          now: now,
        );
        if (scheduled.isError) return Result.error(scheduled.message!);
        next = next.withScheduledChanges(scheduled.data!.changes);
      }

      final saved = await ledgers.put(next);
      if (saved.isError) return Result.error(saved.message!);
      return Result.success(outcome.data!.request);
    });
  }

  // -------------------------------------------------------------- OP07

  @override
  Future<Result<List<OpenStakeholderTask>>> listOpenStakeholderTasks() async {
    final access = await _tester();
    if (access.isError) return Result.error(access.message!);

    final all = await ledgers.all();
    if (all.isError) return Result.error(all.message!);
    final today = clock.today();
    final tasks = <OpenStakeholderTask>[];
    for (final ledger in all.data!) {
      for (final r in ledger.requests.where((r) => r.isInProgress)) {
        for (final s in r.steps) {
          if (s.state == StepState.pending && s.task != null) {
            tasks.add(OpenStakeholderTask(task: s.task!, effectiveDatePassed: r.isEffectiveDatePassed(today)));
          }
        }
      }
    }
    tasks.sort((a, b) {
      final byTime = a.task.createdAt.compareTo(b.task.createdAt);
      return byTime != 0 ? byTime : a.task.stepId.index.compareTo(b.task.stepId.index);
    });
    return Result.success(tasks);
  }
}
