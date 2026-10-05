// Gate 2 G2-09 — DemoAuthService when the session store fails. A failed
// sign-out is reported, not ignored (AC31); a failed session write on sign-in
// is not reported as wrong credentials.

import 'package:flutter_test/flutter_test.dart';

import 'package:employee_transfer_project/core/constants/transfer_messages.dart';
import 'package:employee_transfer_project/data/transfer/portal/demo_auth_service.dart';

import '../../support/failing_local_db_service.dart';
import '../../support/transfer_env.dart';
import '../../support/transfer_fixtures.dart';

void main() {
  const sessionBox = DemoAuthService.sessionBox;

  group('G2-09 DemoAuthService', () {
    test('signOut returns an error when the session cannot be deleted; the user stays signed in', () async {
      final db = FailingLocalDbService();
      final env = await TransferEnv.create(db);
      await env.signInAs(employeeA.userId);
      db.failDeletesOn.add(sessionBox);

      final result = await env.auth.signOut();

      expect(result.message, TransferMessages.signOutFailed);
      expect(await env.auth.currentUser(), employeeA);
    });

    test('signOut succeeds when the session is deleted', () async {
      final env = await TransferEnv.create(FailingLocalDbService());
      await env.signInAs(employeeA.userId);

      expect((await env.auth.signOut()).isSuccess, isTrue);
      expect(await env.auth.currentUser(), isNull);
    });

    test('a failed session write on sign-in is not reported as wrong credentials', () async {
      final db = FailingLocalDbService();
      final env = await TransferEnv.create(db);
      db.failWritesOn.add(sessionBox);

      final result = await env.auth.signIn(email: 'a@demo.test', password: testPassword);

      expect(result.message, TransferMessages.signInFailed);
      expect(await env.auth.currentUser(), isNull);
    });
  });

}
