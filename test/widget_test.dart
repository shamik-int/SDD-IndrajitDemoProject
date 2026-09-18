// App-shell smoke test — not a feature test. Verifies theme/routing/DI wiring
// boots correctly. Deliberately checks only content that renders on the
// first frame (AppEntryPage's loading spinner, before it decides which
// screen to redirect to), not anything behind an async active-request
// check: real Hive I/O reliably does not resolve within a
// `testWidgets`/`pumpAndSettle` body in this environment, even though the
// exact same calls work fine under plain `test()` (see
// test/data/repositories/transfer_request_repository_impl_test.dart, which
// exercises real Hive thoroughly). Waiting past this first frame isn't this
// test's job — T02/T03/T04's own tests already cover behavior after that,
// with a mocked repository and plain `test()` respectively.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import 'package:employee_transfer_project/app/app.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    Get.testMode = true;
    Get.reset();
    // Hive must be initialized before the widget tree builds — AppEntryPage's
    // active-request check runs synchronously-enough during onInit() that an
    // uninitialized Hive throws immediately, not asynchronously. A single
    // pump() is used below rather than pumpAndSettle() regardless, since real
    // Hive file I/O does not reliably resolve within pumpAndSettle here.
    tempDir = Directory.systemTemp.createTempSync('eit_app_shell_test_');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  testWidgets('App shell boots and shows the entry-page loading state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
