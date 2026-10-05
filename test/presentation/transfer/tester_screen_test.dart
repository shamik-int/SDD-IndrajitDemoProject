// employee-internal-transfer.T06 — "Demo only: simulate stakeholder outcome".
// UT41, UT43, UT65 (task mark); AC24–AC26, AC29.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:employee_transfer_project/core/constants/transfer_messages.dart';
import 'package:employee_transfer_project/domain/transfer/entities/enums.dart';
import 'package:employee_transfer_project/domain/transfer/entities/org_values.dart';
import 'package:employee_transfer_project/presentation/transfer/tester/simulation_controller.dart';

import '../../support/transfer_fixtures.dart';
import 'test_app.dart';

void main() {
  String taskId(String requestId, StepId step) => '$requestId:${step.code}';

  testWidgets('UT41, UT43, AC24: tester lands on the labelled simulation screen; only valid outcomes for pending steps',
      (tester) async {
    late String pending, closed, inProgress;
    await bootApp(tester, signedInAs: testerUser.userId, arrange: (env) async {
      pending = (await env.submitAs(employeeA.userId)).requestId;
      closed = (await env.submitAs(employeeB.userId, proposed: changing(location: true))).requestId;
      await env.record(closed, StepId.managerApproval, Outcome.rejected, reason: 'No');
      // Location only, relative to employee B's own baseline → IT not required.
      inProgress = (await env.submitAs(employeeB.userId,
              submissionId: 's2',
              proposed: const OrgValues(departmentId: 'dept-hr', locationId: 'loc-mum', roleId: 'role-analyst')))
          .requestId;
      await env.approveManagerAndHr(inProgress);
    });

    expect(find.text(TransferMessages.simulationTitle), findsOneWidget);
    expect(find.text(TransferMessages.demoIndicator), findsOneWidget);

    final managerTask = taskId(pending, StepId.managerApproval);
    expect(find.byKey(Key('outcome-$managerTask-APPROVED')), findsOneWidget);
    expect(find.byKey(Key('outcome-$managerTask-REJECTED')), findsOneWidget);
    expect(find.byKey(Key('outcome-$managerTask-COMPLETED')), findsNothing);

    final orgTask = taskId(inProgress, StepId.orgRecordUpdate);
    expect(find.byKey(Key('outcome-$orgTask-COMPLETED')), findsOneWidget);
    expect(find.byKey(Key('outcome-$orgTask-FAILED')), findsOneWidget);
    expect(find.byKey(Key('outcome-$orgTask-APPROVED')), findsNothing);

    expect(find.byKey(Key('task-${taskId(inProgress, StepId.itAccessChange)}')), findsNothing); // NOT_REQUIRED
    expect(find.byKey(Key('task-${taskId(closed, StepId.managerApproval)}')), findsNothing); // closed
  });

  testWidgets('AC25: rejection needs a non-blank reason; then it is recorded and the task disappears', (tester) async {
    late String id;
    final env = await bootApp(tester, signedInAs: testerUser.userId, arrange: (env) async {
      id = (await env.submitAs(employeeA.userId)).requestId;
    });
    await env.signInAs(testerUser.userId);
    final task = taskId(id, StepId.managerApproval);

    await tapKey(tester, 'outcome-$task-REJECTED');
    ElevatedButton confirm() => tester.widget<ElevatedButton>(find.byKey(const Key('reject-confirm')));
    expect(confirm().onPressed, isNull);
    await tester.enterText(find.byKey(const Key('reject-reason-field')), '   ');
    await tester.pump();
    expect(confirm().onPressed, isNull);
    await tester.enterText(find.byKey(const Key('reject-reason-field')), 'Team is short-staffed');
    await tester.pump();
    await tapKey(tester, 'reject-confirm');

    expect(find.byKey(Key('task-$task')), findsNothing);
    await env.signInAs(employeeA.userId);
    final request = (await env.repository.getMyTransferRequest(id)).data!;
    expect(request.status, RequestStatus.rejectedByManager);
    expect(request.step(StepId.managerApproval)!.reason, 'Team is short-staffed');
  });

  testWidgets('approving the manager task shows the HR task next', (tester) async {
    late String id;
    await bootApp(tester, signedInAs: testerUser.userId, arrange: (env) async {
      id = (await env.submitAs(employeeA.userId)).requestId;
    });

    await tapKey(tester, 'outcome-${taskId(id, StepId.managerApproval)}-APPROVED');

    expect(find.byKey(Key('task-${taskId(id, StepId.managerApproval)}')), findsNothing);
    expect(find.byKey(Key('task-${taskId(id, StepId.hrEligibility)}')), findsOneWidget);
  });

  testWidgets('AC29: the IT task lists access to provision and to remove; payload names resolved', (tester) async {
    late String id;
    await bootApp(tester, signedInAs: testerUser.userId, arrange: (env) async {
      id = (await env.submitAs(employeeA.userId, proposed: changing(department: true))).requestId;
      await env.approveManagerAndHr(id);
    });

    final it = find.byKey(Key('task-${taskId(id, StepId.itAccessChange)}'));
    expect(find.descendant(of: it, matching: find.text('Provision: Sales, Software Engineer')), findsOneWidget);
    expect(find.descendant(of: it, matching: find.text('Remove: Engineering, Software Engineer')), findsOneWidget);
    expect(find.descendant(of: it, matching: find.textContaining(employeeA.displayName)), findsOneWidget);
  });

  testWidgets('UT65, AC33: a task whose effective date has passed is marked, and still accepts outcomes', (tester) async {
    late String id;
    await bootApp(tester, signedInAs: testerUser.userId, arrange: (env) async {
      id = (await env.submitAs(employeeA.userId, effectiveDate: DateTime(2026, 10, 10))).requestId;
      env.clock.set(DateTime(2026, 10, 12, 9));
    });

    final task = taskId(id, StepId.managerApproval);
    expect(find.descendant(of: find.byKey(Key('task-$task')), matching: find.text(TransferMessages.effectiveDatePassedMark)),
        findsOneWidget);
    await tapKey(tester, 'outcome-$task-APPROVED');
    expect(find.byKey(Key('task-${taskId(id, StepId.hrEligibility)}')), findsOneWidget);
  });

  testWidgets('G2-07, AC26: a refused outcome keeps the OP06 error on screen after the list reloads', (tester) async {
    late String id;
    final env = await bootApp(tester, signedInAs: testerUser.userId, arrange: (env) async {
      id = (await env.submitAs(employeeA.userId)).requestId;
    });
    // The screen still shows the manager task; it is approved behind it.
    await env.record(id, StepId.managerApproval, Outcome.approved);

    await tapKey(tester, 'outcome-${taskId(id, StepId.managerApproval)}-APPROVED');

    expect(find.text(TransferMessages.stepNotPending), findsOneWidget);
    expect(find.byKey(Key('task-${taskId(id, StepId.hrEligibility)}')), findsOneWidget);
  });

  testWidgets('outcome buttons are disabled while a call is in progress', (tester) async {
    late String id;
    await bootApp(tester, signedInAs: testerUser.userId, arrange: (env) async {
      id = (await env.submitAs(employeeA.userId)).requestId;
    });

    Get.find<SimulationController>().isBusy.value = true;
    await tester.pump();
    final button = tester.widget<OutlinedButton>(find.byKey(Key('outcome-${taskId(id, StepId.managerApproval)}-APPROVED')));
    expect(button.onPressed, isNull);
  });
}
