import '../../../core/concurrency/async_lock.dart';
import '../../../core/local_db/local_db_service.dart';
import '../../../core/result/result.dart';
import '../../../core/time/clock.dart';
import '../../../domain/transfer/entities/org_values.dart';
import '../../../domain/transfer/entities/scheduled_change.dart';
import '../../../domain/transfer/entities/transfer_ledger.dart';
import '../../../domain/transfer/portal/portal_contracts.dart';
import '../../../domain/transfer/workflow/schedule_book.dart';
import '../datasources/transfer_ledger_local_datasource.dart';
import 'demo_accounts.dart';

/// D-02 in V1 (plan PD-02): the demo account's baseline plus the scheduled
/// changes held in the employee's ledger. Scheduled changes live in the
/// ledger so that OP06 can save the last outcome and the schedule together.
class DemoProfileService implements EmployeeProfile {
  final DemoAccountsStore _accounts;
  final TransferLedgerLocalDataSource ledgers;
  final AsyncLock lock;
  final Clock clock;

  DemoProfileService(LocalDbService localDb, this.ledgers, this.lock, this.clock)
      : _accounts = DemoAccountsStore(localDb);

  @override
  Future<EmployeeCurrentValues?> getCurrentValues(String employeeId, {required DateTime asOf}) async {
    final baseline = (await _accounts.byUserId(employeeId))?.baseline;
    if (baseline == null) return null;
    final ledger = await ledgers.get(employeeId);
    // Unknown, not the baseline: a failed read may hide a change in effect.
    if (ledger.isError) return null;
    return ScheduleBook.currentValues(baseline, ledger.data?.scheduledChanges ?? const [], asOf);
  }

  @override
  Future<ScheduledChange?> pendingScheduledChange(String employeeId, {required DateTime asOf}) async {
    final ledger = await ledgers.get(employeeId);
    return ScheduleBook.pending(ledger.data?.scheduledChanges ?? const [], asOf);
  }

  @override
  Future<Result<ScheduledChange>> scheduleOrganisationalChange(
    String employeeId, {
    required String requestId,
    required OrgValues values,
    required DateTime effectiveFrom,
  }) {
    return lock.synchronized(() async {
      final read = await ledgers.get(employeeId);
      if (read.isError) return Result.error(read.message!);
      final ledger = read.data ?? TransferLedger.empty(employeeId);
      final result = ScheduleBook.schedule(
        ledger.scheduledChanges,
        employeeId: employeeId,
        requestId: requestId,
        values: values,
        effectiveFrom: effectiveFrom,
        now: clock.now(),
      );
      if (result.isError) return Result.error(result.message!);
      if (result.data!.created) {
        final saved = await ledgers.put(ledger.withScheduledChanges(result.data!.changes));
        if (saved.isError) return Result.error(saved.message!);
      }
      return Result.success(result.data!.change);
    });
  }
}
