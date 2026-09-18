// Full-journey integration test — employee-internal-transfer.T06.
// Per test_cases/_integration.md: submit → simulate manager → simulate HR →
// simulate downstream (any order) → Completed, plus both rejection branches.
//
// Runs via `integration_test` (a real Flutter engine, not the `flutter_tester`
// harness `flutter test` uses) specifically because real Hive file I/O does
// not reliably resolve within `pumpAndSettle()` under that harness in this
// environment (see test/widget_test.dart's note) — on a real device/desktop
// target, real async I/O behaves normally, which is exactly what this test
// needs since it exercises the actual Hive-backed repository end to end,
// nothing mocked.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';

import 'package:employee_transfer_project/app/app.dart';
import 'package:employee_transfer_project/data/datasources/local/transfer_request_local_datasource.dart';
import 'package:employee_transfer_project/presentation/controllers/transfer_request_submission_controller.dart';

Future<void> _resetLocalStorage() async {
  await Hive.initFlutter();
  for (final box in [
    TransferRequestLocalDataSource.requestsBox,
    TransferRequestLocalDataSource.appStateBox,
  ]) {
    if (await Hive.boxExists(box)) {
      await Hive.deleteBoxFromDisk(box);
    }
  }
}

Future<void> _submitAValidRequest(WidgetTester tester) async {
  // Tear down any previous test's widget tree (and its Obx subscriptions)
  // before touching Get's DI container — integration_test runs every
  // testWidgets in the same persistent app process, unlike flutter_tester,
  // so a stale Obx can otherwise try to rebuild against an already-reset
  // container.
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  Get.reset();

  await tester.pumpWidget(const App());
  await tester.pumpAndSettle();

  // AppEntryPage → submission screen (no active request in a freshly wiped store).
  expect(find.text('Request Internal Transfer'), findsOneWidget);

  final controller = Get.find<TransferRequestSubmissionController>();
  controller.setDepartment('dept-eng');
  controller.setLocation('loc-blr');
  controller.setRole('role-swe');
  controller.setEffectiveDate(DateTime.now().add(const Duration(days: 30)));
  await tester.pump();

  await tester.tap(find.widgetWithText(ElevatedButton, 'Submit'));
  await tester.pumpAndSettle();

  expect(find.textContaining('submitted'), findsWidgets);

  await tester.tap(find.widgetWithText(ElevatedButton, 'View Status'));
  await tester.pumpAndSettle();

  expect(find.text('Pending Manager Approval'), findsOneWidget);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    Get.testMode = true;
    await _resetLocalStorage();
  });

  testWidgets(
    'full journey: submit → manager approves → HR approves → '
    'Payroll/IT/Facilities all complete → Completed',
    (tester) async {
      await _submitAValidRequest(tester);

      // Manager approves.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Approve'));
      await tester.pumpAndSettle();
      expect(find.text('Pending HR Validation'), findsOneWidget);
      expect(find.text('HR'), findsWidgets);

      // HR approves — fans out to Payroll, IT, Facilities in parallel.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Approve'));
      await tester.pumpAndSettle();
      expect(find.text('Pending Downstream Updates'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Mark Complete'), findsNWidgets(3));

      // Complete Payroll, then IT — Facilities still pending in between.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Mark Complete').first);
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ElevatedButton, 'Mark Complete'), findsNWidgets(2));

      await tester.tap(find.widgetWithText(ElevatedButton, 'Mark Complete').first);
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ElevatedButton, 'Mark Complete'), findsOneWidget);

      // Complete Facilities — resolves to Completed, Simulate section disappears.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Mark Complete').first);
      await tester.pumpAndSettle();

      expect(find.text('Completed'), findsOneWidget);
      expect(find.byKey(const Key('simulate-decision-section')), findsNothing);
      expect(find.widgetWithText(ElevatedButton, 'Submit a New Transfer Request'), findsOneWidget);
    },
  );

  testWidgets('manager rejection: request ends at Rejected by Manager, frees the slot', (
    tester,
  ) async {
    await _submitAValidRequest(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Reject'));
    await tester.pumpAndSettle();

    expect(find.text('Rejected by Manager'), findsOneWidget);
    expect(find.byKey(const Key('simulate-decision-section')), findsNothing);

    // The single-in-flight-request rule no longer blocks a new submission.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit a New Transfer Request'));
    await tester.pumpAndSettle();
    expect(find.text('Request Internal Transfer'), findsOneWidget);
    expect(find.textContaining('already have a transfer request'), findsNothing);
  });

  testWidgets('HR rejection: request ends at Rejected by HR after manager approval', (
    tester,
  ) async {
    await _submitAValidRequest(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Approve')); // manager
    await tester.pumpAndSettle();
    expect(find.text('Pending HR Validation'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Reject')); // HR
    await tester.pumpAndSettle();

    expect(find.text('Rejected by HR'), findsOneWidget);
    expect(find.byKey(const Key('simulate-decision-section')), findsNothing);
  });
}
