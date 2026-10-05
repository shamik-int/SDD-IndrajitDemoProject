// employee-internal-transfer.T05 — employee screens, through the real app.
// UT37–UT40, UT42, UT43, UT45, UT49, UT64 (form), UT65 (note), UT66, UT69;
// AC01–AC09, AC19, AC20, AC23, AC27, AC28, AC30, AC33, AC34.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:employee_transfer_project/core/constants/transfer_messages.dart';
import 'package:employee_transfer_project/domain/transfer/entities/enums.dart';
import 'package:employee_transfer_project/presentation/transfer/employee/transfer_form_controller.dart';

import '../../support/transfer_fixtures.dart';
import 'test_app.dart';

void main() {
  Future<void> openRequest(WidgetTester tester, String requestId) => tapKey(tester, 'request-tile-$requestId');

  group('sign-in (AC27)', () {
    testWidgets('UT42: nobody signed in → sign-in prompt, no request data', (tester) async {
      await bootApp(tester, arrange: (env) async => env.submitAs(employeeA.userId));

      expect(find.text('Sign in'), findsWidgets);
      expect(find.text(TransferMessages.pleaseSignIn), findsOneWidget);
      expect(find.text('My transfer requests'), findsNothing);
      expect(find.textContaining('Pending manager approval'), findsNothing);
    });

    testWidgets('sign-in with a wrong password shows one generic error; right password opens My requests', (tester) async {
      await bootApp(tester);

      await tester.enterText(find.byKey(const Key('sign-in-email')), 'a@demo.test');
      await tester.enterText(find.byKey(const Key('sign-in-password')), 'wrong');
      await tapKey(tester, 'sign-in-submit');
      expect(find.text(TransferMessages.invalidCredentials), findsOneWidget);

      await signInThroughUi(tester, 'a@demo.test');
      expect(find.text('My transfer requests'), findsOneWidget);
      expect(find.text('Register'), findsNothing);
    });
  });

  testWidgets('password is hidden by default; the eye button shows and hides it', (tester) async {
    await bootApp(tester);
    bool obscured() => tester
        .widget<EditableText>(find.descendant(of: find.byKey(const Key('sign-in-password')), matching: find.byType(EditableText)))
        .obscureText;

    expect(obscured(), isTrue);
    expect(find.byIcon(Icons.visibility), findsOneWidget);

    await tapKey(tester, 'sign-in-password-toggle');
    expect(obscured(), isFalse);
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    expect(find.byTooltip('Hide password'), findsOneWidget);

    await tapKey(tester, 'sign-in-password-toggle');
    expect(obscured(), isTrue);
    expect(find.byTooltip('Show password'), findsOneWidget);
  });

  group('form', () {
    testWidgets('AC02, UT40, AC01, AC03: current values read-only; lists from D-03; submit without a reason', (tester) async {
      final env = await bootApp(tester, signedInAs: employeeA.userId);
      await tapKey(tester, 'new-request-button');

      final current = find.byKey(const Key('current-values'));
      for (final text in ['Engineering', 'Bengaluru', 'Software Engineer', 'Manager A']) {
        expect(find.descendant(of: current, matching: find.textContaining(text)), findsOneWidget);
      }

      await selectDropdown(tester, 'form-role', 'Team Lead');
      Get.find<TransferFormController>().setEffectiveDate(DateTime(2026, 10, 15));
      await tester.pumpAndSettle();
      expect(find.text('15 Oct 2026'), findsOneWidget);
      await tapKey(tester, 'form-submit');

      expect(find.text(TransferMessages.requestSubmitted), findsOneWidget);
      expect(find.text('Pending manager approval'), findsWidgets);
      expect(find.textContaining('Manager approval'), findsWidgets);

      await env.signInAs(employeeA.userId);
      final list = (await env.repository.listMyTransferRequests()).data!;
      expect(list, hasLength(1));
      final request = (await env.repository.getMyTransferRequest(list.single.requestId)).data!;
      expect(request.reason, isNull);
      expect(request.proposed.roleId, 'role-tl');
    });

    testWidgets('AC04: missing fields show field-level messages; no request is created', (tester) async {
      final env = await bootApp(tester, signedInAs: employeeA.userId);
      await tapKey(tester, 'new-request-button');
      await tapKey(tester, 'form-submit');

      expect(find.text(TransferMessages.selectDepartment), findsNothing); // department prefilled with current
      expect(find.text(TransferMessages.enterEffectiveDate), findsOneWidget);
      expect(find.text(TransferMessages.changeAtLeastOne), findsOneWidget);
      expect((await env.repository.listMyTransferRequests()).data, isEmpty);
    });

    testWidgets('AC05: an effective date of today is rejected on the form', (tester) async {
      await bootApp(tester, signedInAs: employeeA.userId);
      await tapKey(tester, 'new-request-button');
      await selectDropdown(tester, 'form-location', 'Mumbai');
      Get.find<TransferFormController>().setEffectiveDate(DateTime(2026, 10, 1));
      await tapKey(tester, 'form-submit');

      expect(find.text(TransferMessages.effectiveDateInFuture), findsOneWidget);
    });

    testWidgets('UT37, AC08: submit disabled while processing; two quick taps → one request', (tester) async {
      final env = await bootApp(tester, signedInAs: employeeA.userId);
      await tapKey(tester, 'new-request-button');
      await selectDropdown(tester, 'form-role', 'Team Lead');
      final controller = Get.find<TransferFormController>();
      controller.setEffectiveDate(DateTime(2026, 10, 15));

      controller.isSubmitting.value = true;
      await tester.pump();
      expect(tester.widget<ElevatedButton>(find.byKey(const Key('form-submit'))).onPressed, isNull);
      controller.isSubmitting.value = false;
      await tester.pump();

      final submit = find.byKey(const Key('form-submit'));
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.tap(submit, warnIfMissed: false);
      await tester.pumpAndSettle();

      await env.signInAs(employeeA.userId);
      final list = (await env.repository.listMyTransferRequests()).data!;
      expect(list, hasLength(1));
      expect((await env.repository.getRequestHistory(list.single.requestId)).data, hasLength(1));
    });

    testWidgets('AC07: a request in progress blocks the form with its message', (tester) async {
      await bootApp(tester, signedInAs: employeeA.userId, arrange: (env) async => env.submitAs(employeeA.userId));
      await tapKey(tester, 'new-request-button');

      expect(find.text(TransferMessages.alreadyInProgress), findsOneWidget);
      expect(find.byKey(const Key('form-submit')), findsNothing);
    });

    testWidgets('UT64, AC34: a COMPLETED request awaiting effect blocks the form with its date', (tester) async {
      await bootApp(tester, signedInAs: employeeA.userId, arrange: (env) async {
        final r = await env.submitAs(employeeA.userId, proposed: changing(role: true));
        await env.approveManagerAndHr(r.requestId);
        for (final s in [StepId.orgRecordUpdate, StepId.payrollUpdate, StepId.itAccessChange]) {
          await env.record(r.requestId, s, Outcome.completed);
        }
      });
      await tapKey(tester, 'new-request-button');

      expect(
        find.text('Your previous transfer takes effect on 15 Oct 2026. You can submit a new request from that date.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('form-submit')), findsNothing);
    });
  });

  group('list and detail', () {
    testWidgets('UT45, AC30: own requests newest first with submitted date and status label', (tester) async {
      final ids = <String>[];
      await bootApp(tester, signedInAs: employeeA.userId, arrange: (env) async {
        for (var i = 1; i <= 3; i++) {
          final r = await env.submitAs(employeeA.userId, submissionId: 's$i');
          ids.add(r.requestId);
          if (i < 3) await env.record(r.requestId, StepId.managerApproval, Outcome.rejected, reason: 'No');
          env.clock.advance(const Duration(hours: 1));
        }
        await env.submitAs(employeeB.userId, proposed: changing(location: true));
      });

      final tiles = find.byKey(const Key('request-list')).evaluate().single;
      expect(tiles, isNotNull);
      final positions = [for (final id in ids) tester.getTopLeft(find.byKey(Key('request-tile-$id'))).dy];
      expect(positions[2] < positions[1] && positions[1] < positions[0], isTrue);
      expect(find.byType(ListTile), findsNWidgets(3));
      expect(find.text('Rejected by Manager'), findsNWidgets(2));
      expect(find.textContaining('Submitted 1 Oct 2026'), findsNWidgets(3));
    });

    testWidgets('UT38, UT39, AC09, AC19: detail shows values, pending actions, no edit or withdraw', (tester) async {
      late String id;
      await bootApp(tester, signedInAs: employeeA.userId, arrange: (env) async {
        final r = await env.submitAs(employeeA.userId,
            proposed: changing(department: true, location: true, role: true), reason: 'Growth');
        id = r.requestId;
        await env.approveManagerAndHr(id);
      });
      await openRequest(tester, id);

      expect(find.text('In progress'), findsWidgets);
      expect(find.textContaining('Sales'), findsWidgets);
      expect(find.textContaining('15 Oct 2026'), findsWidgets);
      expect(find.textContaining('Growth'), findsWidgets);
      for (final step in StepId.downstream) {
        expect(find.descendant(of: find.byKey(Key('step-${step.code}')), matching: find.textContaining(step.pendingAction)),
            findsWidgets);
      }
      expect(find.text('Completed (Approved)'), findsNWidgets(2));
      for (final word in ['Edit', 'Withdraw', 'Cancel request', 'Delete']) {
        expect(find.text(word), findsNothing);
      }
    });

    testWidgets('UT39: a rejected step shows its reason; confirmation for REJECTED_BY_MANAGER', (tester) async {
      late String id;
      await bootApp(tester, signedInAs: employeeA.userId, arrange: (env) async {
        id = (await env.submitAs(employeeA.userId)).requestId;
        await env.record(id, StepId.managerApproval, Outcome.rejected, reason: 'Team is short-staffed');
      });
      await openRequest(tester, id);

      expect(find.descendant(of: find.byKey(const Key('step-MANAGER_APPROVAL')), matching: find.textContaining('Team is short-staffed')),
          findsOneWidget);
      final confirmation = find.byKey(const Key('detail-confirmation'));
      expect(find.descendant(of: confirmation, matching: find.text('You may submit a new request.')), findsOneWidget);
    });

    testWidgets('UT49, UT69, AC17, AC20: FAILED after Org completed — not undone, no retry/undo, profile unchanged', (tester) async {
      late String id;
      await bootApp(tester, signedInAs: employeeA.userId, arrange: (env) async {
        id = (await env.submitAs(employeeA.userId, proposed: changing(department: true, location: true))).requestId;
        await env.approveManagerAndHr(id);
        await env.record(id, StepId.orgRecordUpdate, Outcome.completed);
        await env.record(id, StepId.itAccessChange, Outcome.completed);
        await env.record(id, StepId.payrollUpdate, Outcome.failed);
      });
      await openRequest(tester, id);

      final confirmation = find.byKey(const Key('detail-confirmation'));
      String text() => tester.widgetList<Text>(find.descendant(of: confirmation, matching: find.byType(Text)))
          .map((t) => t.data)
          .join('\n');
      expect(text(), contains('Payroll update'));
      expect(text(), contains('Completed steps (not undone): Manager approval; HR eligibility check; '
          'Organisational record update; IT access change: provision new access, remove old access.'));
      expect(text(), contains('Stopped steps: Facilities: workspace at the new location'));
      expect(text(), contains('Your department, location and role have not changed.'));
      for (final word in ['Retry', 'Undo', 'Compensate']) {
        expect(find.text(word), findsNothing);
      }
    });

    testWidgets('UT65, AC33: effective date passed while pending → note shown, status unchanged', (tester) async {
      late String id;
      await bootApp(tester, signedInAs: employeeA.userId, now: DateTime(2026, 10, 1), arrange: (env) async {
        id = (await env.submitAs(employeeA.userId, effectiveDate: DateTime(2026, 10, 10))).requestId;
        await env.record(id, StepId.managerApproval, Outcome.approved);
        env.clock.set(DateTime(2026, 10, 12, 9));
      });
      await openRequest(tester, id);

      expect(find.text(TransferMessages.effectiveDatePassedNote(DateTime(2026, 10, 10))), findsOneWidget);
      expect(find.text('Pending HR eligibility check'), findsWidgets);
    });

    testWidgets('UT66: completed after its effective date → confirmation adds the "date had passed" line', (tester) async {
      late String id;
      await bootApp(tester, signedInAs: employeeA.userId, arrange: (env) async {
        id = (await env.submitAs(employeeA.userId, proposed: changing(role: true), effectiveDate: DateTime(2026, 10, 10))).requestId;
        env.clock.set(DateTime(2026, 10, 14, 11));
        await env.approveManagerAndHr(id);
        for (final s in [StepId.orgRecordUpdate, StepId.payrollUpdate, StepId.itAccessChange]) {
          await env.record(id, s, Outcome.completed);
        }
      });
      await openRequest(tester, id);

      final confirmation = find.byKey(const Key('detail-confirmation'));
      expect(find.descendant(of: confirmation, matching: find.text('Effective from 10 Oct 2026.')), findsOneWidget);
      expect(
        find.descendant(
          of: confirmation,
          matching: find.text(
              'This date had passed when your transfer completed, so the new values show in your profile from 14 Oct 2026.'),
        ),
        findsOneWidget,
      );
      expect(find.descendant(of: confirmation, matching: find.text('You may submit a new request.')), findsOneWidget);
    });

    testWidgets('AC23: history oldest first with actors; no edit or delete', (tester) async {
      late String id;
      await bootApp(tester, signedInAs: employeeA.userId, arrange: (env) async {
        id = (await env.submitAs(employeeA.userId)).requestId;
        await env.record(id, StepId.managerApproval, Outcome.approved);
      });
      await openRequest(tester, id);

      final first = tester.getTopLeft(find.byKey(const Key('history-entry-1'))).dy;
      final last = tester.getTopLeft(find.byKey(const Key('history-entry-4'))).dy;
      expect(first, lessThan(last));
      expect(find.descendant(of: find.byKey(const Key('history-entry-1')), matching: find.textContaining('Employee')),
          findsOneWidget);
      expect(find.descendant(of: find.byKey(const Key('history-entry-2')), matching: find.textContaining('Manager')),
          findsWidgets);
      expect(find.descendant(of: find.byKey(const Key('history-entry-3')), matching: find.textContaining('System')),
          findsOneWidget);
      expect(find.byIcon(Icons.delete), findsNothing);
      expect(find.byIcon(Icons.edit), findsNothing);
    });
  });

  testWidgets('UT43, AC28: the demo indicator shows on the list, form and request screens', (tester) async {
    late String id;
    await bootApp(tester, signedInAs: employeeA.userId, arrange: (env) async {
      id = (await env.submitAs(employeeA.userId)).requestId;
    });
    expect(find.text(TransferMessages.demoIndicator), findsOneWidget);

    await openRequest(tester, id);
    expect(find.text(TransferMessages.demoIndicator), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tapKey(tester, 'new-request-button');
    expect(find.text(TransferMessages.demoIndicator), findsOneWidget);
  });
}
