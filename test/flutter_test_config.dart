// Leak checks for every widget test (constitution Testing Discipline,
// ADR-0002; Gate 2 G2-04). A Flutter object such as a TextEditingController,
// FocusNode or AnimationController that is created and not disposed fails the
// test that created it.

import 'dart:async';

import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  LeakTesting.enable();
  LeakTesting.settings = LeakTesting.settings.withIgnored(
    createdByTestHelpers: true,
    // Created and never disposed inside the `get` package's page route
    // (GetPageRouteTransitionMixin.buildPageTransitions and
    // .didChangePrevious), on every navigation. lib/ creates neither type
    // itself, so ignoring them hides no leak in this app's code.
    notDisposed: {'CurvedAnimation': null, 'ValueNotifier<String?>': null},
  );
  await testMain();
}
