// Gate 2 G2-09, G2-10 — sign-in and sign-out when storage fails, and leaving
// a pushed screen by signing out. AC27, AC31.

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:employee_transfer_project/core/constants/transfer_messages.dart';
import 'package:employee_transfer_project/data/transfer/portal/demo_auth_service.dart';
import 'package:employee_transfer_project/domain/transfer/entities/enums.dart';
import 'package:employee_transfer_project/presentation/transfer/shared/session_state.dart';

import '../../support/failing_local_db_service.dart';
import '../../support/transfer_fixtures.dart';
import 'test_app.dart';

void main() {
  const sessionBox = DemoAuthService.sessionBox;

  testWidgets('G2-09, AC31: sign-out that cannot clear the session keeps the user here with a message', (tester) async {
    final db = FailingLocalDbService();
    await bootApp(tester, db: db, signedInAs: employeeA.userId);
    db.failDeletesOn.add(sessionBox);

    await tapKey(tester, 'sign-out-button');

    expect(find.text(TransferMessages.signOutFailed), findsOneWidget);
    expect(find.text('My transfer requests'), findsOneWidget);
    expect(Get.find<SessionState>().user.value, employeeA);
  });

  for (final screen in ['detail', 'form']) {
    testWidgets('G2-10: signing out from the $screen screen raises no error from the list screen', (tester) async {
      late String id;
      await bootApp(tester, signedInAs: employeeA.userId, arrange: (env) async {
        // Rejected, so the form is open for a new request.
        id = (await env.submitAs(employeeA.userId)).requestId;
        await env.record(id, StepId.managerApproval, Outcome.rejected, reason: 'No');
      });
      await tapKey(tester, screen == 'detail' ? 'request-tile-$id' : 'new-request-button');

      await tapKey(tester, 'sign-out-button');

      expect(tester.takeException(), isNull);
      expect(find.text(TransferMessages.pleaseSignIn), findsOneWidget);
    });
  }
}
