// Builds the real employee-internal-transfer stack (demo portal adapters +
// repository) over any LocalDbService: real Hive in repository and
// cross-flow tests, the in-memory store in widget tests.

import 'dart:io';

import 'package:hive/hive.dart';

import 'package:employee_transfer_project/core/concurrency/async_lock.dart';
import 'package:employee_transfer_project/core/local_db/local_db_service.dart';
import 'package:employee_transfer_project/core/time/clock.dart';
import 'package:employee_transfer_project/data/transfer/datasources/transfer_ledger_local_datasource.dart';
import 'package:employee_transfer_project/data/transfer/portal/demo_accounts.dart';
import 'package:employee_transfer_project/data/transfer/portal/demo_auth_service.dart';
import 'package:employee_transfer_project/data/transfer/portal/demo_data_seeder.dart';
import 'package:employee_transfer_project/data/transfer/portal/demo_profile_service.dart';
import 'package:employee_transfer_project/data/transfer/portal/static_reference_lists.dart';
import 'package:employee_transfer_project/data/transfer/repositories/transfer_request_repository_impl.dart';
import 'package:employee_transfer_project/domain/transfer/entities/enums.dart';
import 'package:employee_transfer_project/domain/transfer/entities/inputs.dart';
import 'package:employee_transfer_project/domain/transfer/entities/org_values.dart';
import 'package:employee_transfer_project/domain/transfer/entities/transfer_request.dart';

import 'transfer_fixtures.dart';

const testPassword = 'Passw0rd-test';

final testAccounts = [
  DemoAccount.withPassword(
    userId: employeeA.userId,
    email: 'a@demo.test',
    displayName: employeeA.displayName,
    role: UserRole.employee,
    password: testPassword,
    salt: 'salt-a',
    baseline: baseCurrent,
  ),
  DemoAccount.withPassword(
    userId: employeeB.userId,
    email: 'b@demo.test',
    displayName: employeeB.displayName,
    role: UserRole.employee,
    password: testPassword,
    salt: 'salt-b',
    baseline: const EmployeeCurrentValues(
      values: OrgValues(departmentId: 'dept-hr', locationId: 'loc-del', roleId: 'role-analyst'),
      managerName: 'Manager B',
    ),
  ),
  DemoAccount.withPassword(
    userId: testerUser.userId,
    email: 't@demo.test',
    displayName: testerUser.displayName,
    role: UserRole.tester,
    password: testPassword,
    salt: 'salt-t',
  ),
];

class TransferEnv {
  final LocalDbService db;
  final AdjustableClock clock;
  final AsyncLock lock = AsyncLock();
  late final DemoAuthService auth = DemoAuthService(db);
  late final TransferLedgerLocalDataSource ledgers = TransferLedgerLocalDataSource(db);
  late final DemoProfileService profile = DemoProfileService(db, ledgers, lock, clock);
  final StaticReferenceLists refs = const StaticReferenceLists();
  late final TransferRequestRepositoryImpl repository = TransferRequestRepositoryImpl(
    users: auth,
    profile: profile,
    refs: refs,
    ledgers: ledgers,
    lock: lock,
    clock: clock,
  );

  TransferEnv(this.db, this.clock);

  static Future<TransferEnv> create(LocalDbService db, {DateTime? now}) async {
    final env = TransferEnv(db, AdjustableClock(now ?? DateTime(2026, 10, 1, 9)));
    await DemoDataSeeder(db, accounts: testAccounts).ensureSeeded();
    return env;
  }

  static const _emails = {'emp-a': 'a@demo.test', 'emp-b': 'b@demo.test', 'tst-1': 't@demo.test'};

  Future<void> signInAs(String userId) async {
    final result = await auth.signIn(email: _emails[userId]!, password: testPassword);
    if (result.isError) throw StateError('sign-in failed: ${result.message}');
  }

  Future<void> signOut() => auth.signOut();

  /// Signs in as [employee], submits, and returns the new request.
  Future<TransferRequest> submitAs(
    String employee, {
    String submissionId = 'sub-1',
    OrgValues? proposed,
    DateTime? effectiveDate,
    String? reason,
  }) async {
    await signInAs(employee);
    final result = await repository.submitTransferRequest(
      submitInput(submissionId: submissionId, proposed: proposed, effectiveDate: effectiveDate, reason: reason),
    );
    if (result.isError) throw StateError('submit failed: ${result.message}');
    return result.data!;
  }

  /// Signs in as the tester and records an outcome; returns the error message or null.
  Future<String?> record(String requestId, StepId step, Outcome outcome, {String? reason}) async {
    await signInAs(testerUser.userId);
    final result = await repository.recordStakeholderOutcome(
      RecordOutcomeInput(requestId: requestId, stepId: step, outcome: outcome, reason: reason),
    );
    return result.isError ? result.message : null;
  }

  Future<void> approveManagerAndHr(String requestId) async {
    await record(requestId, StepId.managerApproval, Outcome.approved);
    await record(requestId, StepId.hrEligibility, Outcome.approved);
  }
}

/// Real Hive in a temp directory, for plain `test()` bodies.
class HiveSandbox {
  late Directory _dir;

  void setUp() {
    _dir = Directory.systemTemp.createTempSync('eit_v2_hive_');
    Hive.init(_dir.path);
  }

  Future<void> tearDown() async {
    await Hive.deleteFromDisk();
    if (_dir.existsSync()) _dir.deleteSync(recursive: true);
  }
}
