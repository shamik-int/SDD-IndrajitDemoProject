// Boots the real app (routes, bindings, middleware) over the in-memory store,
// because real Hive I/O does not settle under testWidgets.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:employee_transfer_project/app/app.dart';
import 'package:employee_transfer_project/app/bindings/initial_binding.dart';
import 'package:employee_transfer_project/core/local_db/in_memory_local_db_service.dart';

import '../../support/transfer_env.dart';

Future<TransferEnv> bootApp(
  WidgetTester tester, {
  DateTime? now,
  String? signedInAs,
  Future<void> Function(TransferEnv env)? arrange,
}) async {
  Get.testMode = true;
  Get.reset();
  tester.view.physicalSize = const Size(1200, 3200);
  tester.view.devicePixelRatio = 1.5;
  addTearDown(tester.view.reset);

  final env = await TransferEnv.create(InMemoryLocalDbService(), now: now);
  if (arrange != null) await arrange(env);
  if (signedInAs != null) {
    await env.signInAs(signedInAs);
  } else {
    await env.signOut();
  }

  await tester.pumpWidget(App(initialBinding: InitialBinding(localDb: env.db, clock: env.clock)));
  await tester.pumpAndSettle();
  return env;
}

Future<void> tapKey(WidgetTester tester, String key) async {
  final finder = find.byKey(Key(key));
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> signInThroughUi(WidgetTester tester, String email) async {
  await tester.enterText(find.byKey(const Key('sign-in-email')), email);
  await tester.enterText(find.byKey(const Key('sign-in-password')), testPassword);
  await tapKey(tester, 'sign-in-submit');
}

Future<void> selectDropdown(WidgetTester tester, String key, String label) async {
  await tapKey(tester, key);
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}
