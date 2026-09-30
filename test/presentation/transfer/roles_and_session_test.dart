// employee-internal-transfer.T07 — role routing, route guards and sign-out.
// UT51, UT67, UT68; AC24, AC27, AC31, AC32; PD-07, PD-08.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:employee_transfer_project/app/routes/app_routes.dart';
import 'package:employee_transfer_project/core/constants/transfer_messages.dart';
import 'package:employee_transfer_project/core/security/threat_response.dart';
import 'package:employee_transfer_project/core/local_db/in_memory_local_db_service.dart';
import 'package:employee_transfer_project/presentation/transfer/shared/app_entry_controller.dart';
import 'package:employee_transfer_project/presentation/transfer/shared/session_state.dart';

import '../../support/transfer_env.dart';
import '../../support/transfer_fixtures.dart';
import 'test_app.dart';

void main() {
  group('PD-07 start-up routing', () {
    test('nobody → sign-in; EMPLOYEE → my requests; TESTER → simulation', () async {
      final env = await TransferEnv.create(InMemoryLocalDbService());
      final session = SessionState();
      final entry = AppEntryController(users: env.auth, session: session);

      expect(await entry.resolveInitialRoute(), AppRoutes.signIn);
      await env.signInAs(employeeA.userId);
      expect(await entry.resolveInitialRoute(), AppRoutes.myRequests);
      expect(session.user.value, employeeA);
      await env.signInAs(testerUser.userId);
      expect(await entry.resolveInitialRoute(), AppRoutes.simulate);
    });
  });

  testWidgets('UT51, AC24: as EMPLOYEE no simulation entry point; the route itself is refused', (tester) async {
    await bootApp(tester, signedInAs: employeeA.userId, arrange: (env) async => env.submitAs(employeeA.userId));

    expect(find.textContaining('simulate', findRichText: true), findsNothing);
    expect(find.textContaining('Demo only'), findsNothing);
    for (final label in ['Approve', 'Reject', 'Complete', 'Fail']) {
      expect(find.text(label), findsNothing);
    }

    Get.toNamed(AppRoutes.simulate);
    await tester.pumpAndSettle();
    expect(find.text(TransferMessages.simulationTitle), findsNothing);
    expect(find.text('My transfer requests'), findsOneWidget);
  });

  testWidgets('AC32: as TESTER no transfer form is offered; employee routes are refused', (tester) async {
    await bootApp(tester, signedInAs: testerUser.userId);
    expect(find.byKey(const Key('new-request-button')), findsNothing);

    Get.toNamed(AppRoutes.newRequest);
    await tester.pumpAndSettle();
    expect(find.text('New transfer request'), findsNothing);
    expect(find.text(TransferMessages.simulationTitle), findsOneWidget);
  });

  testWidgets('UT67, UT68, AC31: A signs out, B signs in — nothing of A is reachable', (tester) async {
    late String aRequest;
    final env = await bootApp(tester, signedInAs: employeeA.userId, arrange: (env) async {
      aRequest = (await env.submitAs(employeeA.userId, reason: 'A private reason')).requestId;
    });
    await tapKey(tester, 'request-tile-$aRequest');
    expect(find.textContaining('A private reason'), findsOneWidget);

    await tapKey(tester, 'sign-out-button');

    // UT68: signed out — sign-in screen only, nothing to go back to, every operation refused.
    expect(find.text(TransferMessages.pleaseSignIn), findsOneWidget);
    expect(find.textContaining('A private reason'), findsNothing);
    expect(Get.find<SessionState>().user.value, isNull);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
    expect(navigator.canPop(), isFalse);
    expect((await env.repository.getMyTransferRequest(aRequest)).message, TransferMessages.pleaseSignIn);
    expect((await env.repository.listMyTransferRequests()).message, TransferMessages.pleaseSignIn);

    await signInThroughUi(tester, 'b@demo.test');
    expect(find.text('My transfer requests'), findsOneWidget);
    expect(find.byKey(Key('request-tile-$aRequest')), findsNothing);

    await tester.pageBack().catchError((_) {});
    await tester.pumpAndSettle();
    expect(find.textContaining('A private reason'), findsNothing);

    Get.toNamed(AppRoutes.requestDetail, arguments: {'requestId': aRequest});
    await tester.pumpAndSettle();
    expect(find.text(TransferMessages.noRequestFound), findsOneWidget);
    expect(find.textContaining('A private reason'), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tapKey(tester, 'new-request-button');
    final current = find.byKey(const Key('current-values'));
    expect(find.descendant(of: current, matching: find.textContaining('Manager B')), findsOneWidget);
  });

  group('PD-08 threat response', () {
    test('UAT warns, PROD blocks', () {
      final calls = <String>[];
      final uat = ThreatResponse(env: 'uat', warn: (r) => calls.add('warn:$r'), block: (r) => calls.add('block:$r'));
      final prod = ThreatResponse(env: 'prod', warn: (r) => calls.add('warn:$r'), block: (r) => calls.add('block:$r'));

      uat.onThreat('Rooted');
      prod.onThreat('Rooted');

      expect(calls, ['warn:Rooted', 'block:Rooted']);
    });
  });
}
