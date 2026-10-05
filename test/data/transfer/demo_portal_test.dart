// employee-internal-transfer.T02 — demo portal adapters (D-01..D-03) and the
// start-up seeder, over real Hive. Covers PD-01, PD-01a, PD-02, PD-03, PD-06,
// UT21 and UT60–UT62 through the public D-02 contract.

import 'package:flutter_test/flutter_test.dart';

import 'package:employee_transfer_project/core/constants/transfer_messages.dart';
import 'package:employee_transfer_project/core/local_db/local_db_service.dart';
import 'package:employee_transfer_project/data/transfer/portal/demo_accounts.dart';
import 'package:employee_transfer_project/data/transfer/portal/demo_data_seeder.dart';
import 'package:employee_transfer_project/domain/transfer/entities/enums.dart';

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

  group('D-01 sign-in (PD-01)', () {
    test('valid credentials sign in with the role from the account data', () async {
      final result = await env.auth.signIn(email: '  T@Demo.Test ', password: testPassword);

      expect(result.isSuccess, isTrue);
      expect(result.data!.role, UserRole.tester);
      expect(await env.auth.currentUser(), result.data);
    });

    test('a wrong password or unknown email gives one generic message and no session', () async {
      expect((await env.auth.signIn(email: 'a@demo.test', password: 'nope')).message,
          TransferMessages.invalidCredentials);
      expect((await env.auth.signIn(email: 'x@demo.test', password: testPassword)).message,
          TransferMessages.invalidCredentials);
      expect(await env.auth.currentUser(), isNull);
    });

    test('sign-out clears the session', () async {
      await env.signInAs(employeeA.userId);
      await env.signOut();
      expect(await env.auth.currentUser(), isNull);
    });

    test('PD-01a: the shipped seed holds only hashes and salts, never a plaintext password', () {
      for (final account in DemoAccounts.seed) {
        final map = account.toMap();
        expect(map.keys, isNot(contains('password')));
        expect(map['passwordHash'], matches(RegExp(r'^[0-9a-f]{64}$')));
        expect(map['passwordSalt'], isNotEmpty);
      }
      expect(DemoAccounts.seed.where((a) => a.role == UserRole.tester), hasLength(1));
      expect(DemoAccounts.seed.where((a) => a.role == UserRole.employee), hasLength(3));
      expect(DemoAccounts.seed.where((a) => a.role == UserRole.tester).single.baseline, isNull);
    });
  });

  group('D-02 profile (PD-02)', () {
    test('baseline current values; a tester has no profile', () async {
      expect(await env.profile.getCurrentValues(employeeA.userId, asOf: DateTime(2026, 10, 1)), baseCurrent);
      expect(await env.profile.getCurrentValues(testerUser.userId, asOf: DateTime(2026, 10, 1)), isNull);
    });

    test('UT21: completed change — old values before the effective date, new values on it', () async {
      final r = await env.submitAs(employeeA.userId, proposed: changing(role: true));
      await env.approveManagerAndHr(r.requestId);
      for (final step in [StepId.orgRecordUpdate, StepId.payrollUpdate, StepId.itAccessChange]) {
        expect(await env.record(r.requestId, step, Outcome.completed), isNull);
      }

      expect((await env.profile.getCurrentValues(employeeA.userId, asOf: DateTime(2026, 10, 14)))!.values, baseValues);
      expect((await env.profile.getCurrentValues(employeeA.userId, asOf: DateTime(2026, 10, 15)))!.values,
          changing(role: true));
      expect(await env.profile.pendingScheduledChange(employeeA.userId, asOf: DateTime(2026, 10, 14)), isNotNull);
      expect(await env.profile.pendingScheduledChange(employeeA.userId, asOf: DateTime(2026, 10, 15)), isNull);
    });

    test('UT60–UT62: public scheduleOrganisationalChange follows the SD-20 table and persists', () async {
      final first = await env.profile.scheduleOrganisationalChange(employeeA.userId,
          requestId: 'r1', values: changing(role: true), effectiveFrom: DateTime(2026, 10, 15));
      env.clock.advance(const Duration(hours: 2));
      final repeat = await env.profile.scheduleOrganisationalChange(employeeA.userId,
          requestId: 'r1', values: changing(role: true), effectiveFrom: DateTime(2026, 10, 15));
      final different = await env.profile.scheduleOrganisationalChange(employeeA.userId,
          requestId: 'r1', values: changing(location: true), effectiveFrom: DateTime(2026, 10, 15));
      final another = await env.profile.scheduleOrganisationalChange(employeeA.userId,
          requestId: 'r2', values: changing(location: true), effectiveFrom: DateTime(2026, 10, 30));

      expect(first.isSuccess, isTrue);
      expect(repeat.data!.scheduledAt, first.data!.scheduledAt);
      expect(different.message, TransferMessages.differentChangeScheduled);
      expect(another.message, TransferMessages.anotherTransferScheduled);
      expect((await env.ledgers.get(employeeA.userId)).data!.scheduledChanges, hasLength(1));
    });
  });

  group('D-03 reference lists (PD-03)', () {
    test('departments, locations and roles come from the demo lists', () {
      expect(env.refs.departments().map((d) => d.id), contains('dept-eng'));
      expect(env.refs.locations(), hasLength(5));
      expect(env.refs.roles().first.name, 'Software Engineer');
    });
  });

  group('start-up seeder (PD-06)', () {
    test('clears v1.5 and BRD-002 boxes once, seeds accounts, sets schemaVersion 2', () async {
      final db = LocalDbService();
      await db.write('transfer_requests', 'old', {'x': 1});
      await db.write('app_state', 'activeRequestId', 'old');
      await db.write('employees', 'someone@x.com', {'x': 1});
      await db.write(DemoDataSeeder.metaBox, DemoDataSeeder.schemaKey, 1);

      await DemoDataSeeder(db, accounts: testAccounts).ensureSeeded();

      expect((await db.readAll('transfer_requests')).data, isEmpty);
      expect((await db.readAll('app_state')).data, isEmpty);
      expect((await db.readAll('employees')).data, isEmpty);
      expect((await db.read<int>(DemoDataSeeder.metaBox, DemoDataSeeder.schemaKey)).data, 2);
      expect((await db.readAll(DemoAccountsStore.box)).data, hasLength(3));
    });

    test('at schemaVersion 2 it keeps existing transfer data', () async {
      final r = await env.submitAs(employeeA.userId);
      await DemoDataSeeder(env.db, accounts: testAccounts).ensureSeeded();

      await env.signInAs(employeeA.userId);
      expect((await env.repository.getMyTransferRequest(r.requestId)).isSuccess, isTrue);
    });
  });
}
