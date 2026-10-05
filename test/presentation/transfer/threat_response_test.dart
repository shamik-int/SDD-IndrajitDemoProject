// Gate 2 G2-08 — PD-08 threat response: a threat reported before the app can
// navigate is held until it can; PROD block clears the stored session; a
// release build without ENV fails closed.

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:employee_transfer_project/core/constants/transfer_messages.dart';
import 'package:employee_transfer_project/core/security/threat_response.dart';
import 'package:employee_transfer_project/presentation/transfer/shared/blocked_page.dart';
import 'package:employee_transfer_project/presentation/transfer/shared/device_block.dart';
import 'package:employee_transfer_project/presentation/transfer/shared/session_state.dart';

import '../../support/transfer_fixtures.dart';
import 'test_app.dart';

void main() {
  group('ThreatResponse', () {
    test('a threat before markReady is held, then handled once ready', () {
      final calls = <String>[];
      final response = ThreatResponse(env: 'prod', warn: (r) => calls.add('warn:$r'), block: (r) => calls.add('block:$r'));

      response.onThreat('Rooted');
      expect(calls, isEmpty);

      response.markReady();
      expect(calls, ['block:Rooted']);

      response.onThreat('Hooks');
      expect(calls, ['block:Rooted', 'block:Hooks']);
    });

    test('ENV: an explicit value wins; a release build without one is prod (fails closed)', () {
      expect(ThreatResponse.resolveEnv('uat', releaseMode: true), 'uat');
      expect(ThreatResponse.resolveEnv('prod', releaseMode: false), 'prod');
      expect(ThreatResponse.resolveEnv('', releaseMode: true), 'prod');
      expect(ThreatResponse.resolveEnv('', releaseMode: false), 'uat');
    });
  });

  testWidgets('G2-08: PROD threat reported before the app is built → blocked screen; stored session cleared',
      (tester) async {
    final env = await bootApp(tester, signedInAs: employeeA.userId, beforePump: (env) {
      final response = Get.put(ThreatResponse(env: 'prod', warn: (_) {}, block: (_) => blockDevice()), permanent: true);
      response.onThreat('Rooted'); // before runApp, as at start-up
    });

    expect(find.byType(BlockedPage), findsOneWidget);
    expect(find.text('My transfer requests'), findsNothing);
    expect(await env.auth.currentUser(), isNull);
    expect(Get.find<SessionState>().user.value, isNull);
    expect(find.text(TransferMessages.pleaseSignIn), findsNothing);
  });
}
