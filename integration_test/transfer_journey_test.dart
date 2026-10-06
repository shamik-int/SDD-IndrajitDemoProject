// employee-internal-transfer.T08 — IT01: the full journey through the real UI,
// real Hive and real routing on an iOS simulator or Android emulator:
// employee submits → signs out → tester records every outcome → employee
// sees the COMPLETED confirmation. Run: flutter test integration_test -d <device>

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:integration_test/integration_test.dart';

import 'package:employee_transfer_project/app/app.dart';
import 'package:employee_transfer_project/app/bindings/initial_binding.dart';
import 'package:employee_transfer_project/core/constants/transfer_messages.dart';
import 'package:employee_transfer_project/core/local_db/local_db_service.dart';
import 'package:employee_transfer_project/core/time/clock.dart';
import 'package:employee_transfer_project/data/transfer/portal/demo_data_seeder.dart';
import 'package:employee_transfer_project/domain/transfer/entities/enums.dart';
import 'package:employee_transfer_project/presentation/transfer/employee/transfer_form_controller.dart';

import '../test/support/transfer_env.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('eit_it01_');
    Hive.init(dir.path);
    await DemoDataSeeder(LocalDbService(), accounts: testAccounts).ensureSeeded();
    Get.reset();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  Future<void> tap(WidgetTester tester, String key) async {
    final f = find.byKey(Key(key));
    await tester.ensureVisible(f);
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  Future<void> signIn(WidgetTester tester, String email) async {
    await tester.enterText(find.byKey(const Key('sign-in-email')), email);
    await tester.enterText(find.byKey(const Key('sign-in-password')), testPassword);
    await tap(tester, 'sign-in-submit');
  }

  Future<void> tapFirstOutcome(WidgetTester tester, Outcome outcome) async {
    final f = find.byWidgetPredicate(
      (w) => w is OutlinedButton && (w.key as ValueKey<String>?)?.value.endsWith('-${outcome.code}') == true,
    );
    await tester.ensureVisible(f.first);
    await tester.tap(f.first);
    await tester.pumpAndSettle();
  }

  testWidgets('IT01: submit → tester completes every step → employee sees the confirmation', (tester) async {
    final clock = AdjustableClock(DateTime(2026, 10, 1, 9));
    await tester.pumpWidget(App(initialBinding: InitialBinding(localDb: LocalDbService(), clock: clock)));
    await tester.pumpAndSettle();

    // Employee A submits a role change.
    expect(find.text(TransferMessages.pleaseSignIn), findsOneWidget);
    await signIn(tester, 'a@demo.test');
    await tap(tester, 'new-request-button');
    await tap(tester, 'form-role');
    await tester.tap(find.text('Team Lead').last);
    await tester.pumpAndSettle();
    Get.find<TransferFormController>().setEffectiveDate(DateTime(2026, 10, 15));
    await tester.pumpAndSettle();
    await tap(tester, 'form-submit');
    expect(find.text(TransferMessages.requestSubmitted), findsOneWidget);
    await tap(tester, 'sign-out-button');

    // Tester: manager, HR, then Org, Payroll, IT (role only → Facilities not required).
    await signIn(tester, 't@demo.test');
    expect(find.text(TransferMessages.simulationTitle), findsOneWidget);
    await tapFirstOutcome(tester, Outcome.approved); // manager
    await tapFirstOutcome(tester, Outcome.approved); // HR
    for (var i = 0; i < 3; i++) {
      await tapFirstOutcome(tester, Outcome.completed);
    }
    expect(find.text('No open stakeholder tasks.'), findsOneWidget);
    await tap(tester, 'sign-out-button');

    // Employee A sees the completed, awaiting-effect confirmation.
    await signIn(tester, 'a@demo.test');
    expect(find.text('Completed: takes effect on 15 Oct 2026'), findsOneWidget);
    await tester.tap(find.text('Completed: takes effect on 15 Oct 2026'));
    await tester.pumpAndSettle();
    expect(find.text('Transfer confirmed'), findsOneWidget);
    expect(find.text('You can submit a new request from 15 Oct 2026.'), findsOneWidget);
  });
}
