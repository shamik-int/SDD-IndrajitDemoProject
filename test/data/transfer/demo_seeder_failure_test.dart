// Gate 2 G2-14 — a failed read of the schema version is not "first run": the
// one-off clean-up (PD-06) must not run, so the session is not wiped.

import 'package:flutter_test/flutter_test.dart';

import 'package:employee_transfer_project/data/transfer/portal/demo_auth_service.dart';
import 'package:employee_transfer_project/data/transfer/portal/demo_data_seeder.dart';

import '../../support/failing_local_db_service.dart';
import '../../support/transfer_env.dart';

void main() {
  test('schema version read fails → no clean-up; the stored session survives; accounts still seeded', () async {
    final db = FailingLocalDbService();
    await db.write(DemoAuthService.sessionBox, DemoAuthService.currentUserKey, 'emp-a');
    db.failReadsOn.add(DemoDataSeeder.metaBox);

    await DemoDataSeeder(db, accounts: testAccounts).ensureSeeded();

    expect((await db.read<String>(DemoAuthService.sessionBox, DemoAuthService.currentUserKey)).data, 'emp-a');
    expect(db.writes, isNot(contains(DemoDataSeeder.metaBox)));
    expect((await db.readAll('demo_accounts')).data, hasLength(testAccounts.length));
  });

  test('schema version absent → first run: clean-up runs and the version is set', () async {
    final db = FailingLocalDbService();
    await db.write(DemoAuthService.sessionBox, DemoAuthService.currentUserKey, 'emp-a');

    await DemoDataSeeder(db, accounts: testAccounts).ensureSeeded();

    expect((await db.read<String>(DemoAuthService.sessionBox, DemoAuthService.currentUserKey)).isError, isTrue);
    expect((await db.read<int>(DemoDataSeeder.metaBox, DemoDataSeeder.schemaKey)).data, DemoDataSeeder.schemaVersion);
  });
}
