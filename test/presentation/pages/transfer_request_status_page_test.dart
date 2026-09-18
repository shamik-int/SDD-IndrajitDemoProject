import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employee_transfer_project/app/routes/app_routes.dart';
import 'package:employee_transfer_project/core/result/result.dart';
import 'package:employee_transfer_project/domain/entities/stakeholder.dart';
import 'package:employee_transfer_project/domain/entities/stakeholder_decision.dart';
import 'package:employee_transfer_project/domain/entities/stakeholder_state.dart';
import 'package:employee_transfer_project/domain/entities/transfer_request.dart';
import 'package:employee_transfer_project/domain/entities/transfer_request_status.dart';
import 'package:employee_transfer_project/domain/repositories/employee_account_repository.dart';
import 'package:employee_transfer_project/domain/repositories/transfer_request_repository.dart';
import 'package:employee_transfer_project/domain/usecases/get_active_transfer_request_status.dart';
import 'package:employee_transfer_project/domain/usecases/get_transfer_request_by_id.dart';
import 'package:employee_transfer_project/domain/usecases/logout_employee.dart';
import 'package:employee_transfer_project/domain/usecases/record_stakeholder_decision.dart';
import 'package:employee_transfer_project/presentation/controllers/simulate_decision_controller.dart';
import 'package:employee_transfer_project/presentation/controllers/transfer_request_status_controller.dart';
import 'package:employee_transfer_project/presentation/pages/transfer_request_status_page.dart';

class MockTransferRequestRepository extends Mock
    implements TransferRequestRepository {}

class MockEmployeeAccountRepository extends Mock
    implements EmployeeAccountRepository {}

TransferRequest _request({
  required TransferRequestStatus status,
  Map<Stakeholder, StakeholderState> stakeholders = const {},
}) {
  final now = DateTime.now();
  return TransferRequest(
    id: 'req-1',
    departmentId: 'dept-eng',
    locationId: 'loc-blr',
    roleId: 'role-swe',
    effectiveDate: now.add(const Duration(days: 10)),
    reason: 'Relocating',
    status: status,
    stakeholders: stakeholders,
    submittedAt: now,
    updatedAt: now,
  );
}

void main() {
  late MockTransferRequestRepository repository;
  late MockEmployeeAccountRepository accountRepository;

  setUp(() {
    Get.testMode = true;
    repository = MockTransferRequestRepository();
    accountRepository = MockEmployeeAccountRepository();
  });

  tearDown(() {
    Get.reset();
  });

  Future<void> pumpStatusPage(WidgetTester tester) async {
    Get.put<TransferRequestStatusController>(
      TransferRequestStatusController(
        getActiveTransferRequestStatus: GetActiveTransferRequestStatus(repository),
        getTransferRequestById: GetTransferRequestById(repository),
      ),
    );
    Get.put<SimulateDecisionController>(
      SimulateDecisionController(
        recordStakeholderDecision: RecordStakeholderDecision(repository),
      ),
    );
    Get.put<LogoutEmployee>(LogoutEmployee(accountRepository));
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.transferRequestStatus,
        getPages: [
          GetPage(
            name: AppRoutes.transferRequestStatus,
            page: () => const TransferRequestStatusPage(),
          ),
          GetPage(name: AppRoutes.placeholder, page: () => const Scaffold(body: Text('ENTRY'))),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('AC7: shows Manager as the sole pending stakeholder', (tester) async {
    when(() => repository.getActive()).thenAnswer(
      (_) async => Result.success(
        _request(
          status: TransferRequestStatus.pendingManagerApproval,
          stakeholders: const {Stakeholder.manager: StakeholderState.pending},
        ),
      ),
    );

    await pumpStatusPage(tester);

    expect(find.textContaining('Manager'), findsWidgets);
    expect(find.textContaining('dept-eng'), findsNothing); // ids aren't shown raw
  });

  testWidgets('AC10: shows Payroll, IT, and Facilities pending after HR approval', (
    tester,
  ) async {
    when(() => repository.getActive()).thenAnswer(
      (_) async => Result.success(
        _request(
          status: TransferRequestStatus.pendingDownstreamUpdates,
          stakeholders: const {
            Stakeholder.payroll: StakeholderState.pending,
            Stakeholder.it: StakeholderState.pending,
            Stakeholder.facilities: StakeholderState.pending,
          },
        ),
      ),
    );

    await pumpStatusPage(tester);

    expect(find.textContaining('Payroll'), findsWidgets);
    expect(find.textContaining('IT'), findsWidgets);
    expect(find.textContaining('Facilities'), findsWidgets);
  });

  testWidgets('AC13: shows only IT and Facilities pending once Payroll completes', (
    tester,
  ) async {
    when(() => repository.getActive()).thenAnswer(
      (_) async => Result.success(
        _request(
          status: TransferRequestStatus.pendingDownstreamUpdates,
          stakeholders: const {
            Stakeholder.payroll: StakeholderState.completed,
            Stakeholder.it: StakeholderState.pending,
            Stakeholder.facilities: StakeholderState.pending,
          },
        ),
      ),
    );

    await pumpStatusPage(tester);

    final pendingSection = find.byKey(const Key('pending-stakeholders'));
    expect(
      find.descendant(of: pendingSection, matching: find.textContaining('Payroll')),
      findsNothing,
    );
    expect(
      find.descendant(of: pendingSection, matching: find.textContaining('IT')),
      findsOneWidget,
    );
  });

  testWidgets('AC12: shows Completed with no pending stakeholders', (tester) async {
    when(() => repository.getActive()).thenAnswer(
      (_) async => Result.success(
        _request(
          status: TransferRequestStatus.completed,
          stakeholders: const {
            Stakeholder.payroll: StakeholderState.completed,
            Stakeholder.it: StakeholderState.completed,
            Stakeholder.facilities: StakeholderState.completed,
          },
        ),
      ),
    );

    await pumpStatusPage(tester);

    expect(find.textContaining('Completed'), findsWidgets);
    expect(find.byKey(const Key('pending-stakeholders')), findsNothing);
  });

  testWidgets('AC9: shows Rejected by Manager and a way to submit a new request', (
    tester,
  ) async {
    when(() => repository.getActive()).thenAnswer(
      (_) async => Result.success(
        _request(status: TransferRequestStatus.rejectedByManager),
      ),
    );

    await pumpStatusPage(tester);

    expect(find.textContaining('Rejected'), findsWidgets);
    expect(find.textContaining('Submit'), findsWidgets);
  });

  testWidgets('shows a prompt to submit when there is no request at all', (
    tester,
  ) async {
    when(
      () => repository.getActive(),
    ).thenAnswer((_) async => Result<TransferRequest?>.success(null));

    await pumpStatusPage(tester);

    expect(find.textContaining('Submit'), findsWidgets);
  });

  group('AC14 — Simulate Decision control', () {
    testWidgets('is clearly labeled as test/demo only, not a real feature', (
      tester,
    ) async {
      when(() => repository.getActive()).thenAnswer(
        (_) async => Result.success(
          _request(
            status: TransferRequestStatus.pendingManagerApproval,
            stakeholders: const {Stakeholder.manager: StakeholderState.pending},
          ),
        ),
      );

      await pumpStatusPage(tester);

      expect(find.byKey(const Key('simulate-decision-section')), findsOneWidget);
      expect(find.textContaining('TEST'), findsWidgets);
    });

    testWidgets('shows Approve/Reject for a pending Manager, and Approve advances to HR', (
      tester,
    ) async {
      final initial = _request(
        status: TransferRequestStatus.pendingManagerApproval,
        stakeholders: const {Stakeholder.manager: StakeholderState.pending},
      );
      final afterApprove = _request(
        status: TransferRequestStatus.pendingHrValidation,
        stakeholders: const {
          Stakeholder.manager: StakeholderState.approved,
          Stakeholder.hr: StakeholderState.pending,
        },
      );
      when(() => repository.getActive()).thenAnswer((_) async => Result.success(initial));
      when(
        () => repository.recordStakeholderDecision(
          requestId: 'req-1',
          stakeholder: Stakeholder.manager,
          decision: StakeholderDecision.approved,
        ),
      ).thenAnswer((_) async => Result.success(afterApprove));
      when(
        () => repository.getById('req-1'),
      ).thenAnswer((_) async => Result.success(afterApprove));

      await pumpStatusPage(tester);

      expect(find.widgetWithText(ElevatedButton, 'Approve'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Reject'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Approve'));
      await tester.pumpAndSettle();

      verify(
        () => repository.recordStakeholderDecision(
          requestId: 'req-1',
          stakeholder: Stakeholder.manager,
          decision: StakeholderDecision.approved,
        ),
      ).called(1);
      expect(find.textContaining('Pending HR Validation'), findsWidgets);
    });

    testWidgets('shows a single Mark Complete button per pending downstream stakeholder', (
      tester,
    ) async {
      when(() => repository.getActive()).thenAnswer(
        (_) async => Result.success(
          _request(
            status: TransferRequestStatus.pendingDownstreamUpdates,
            stakeholders: const {
              Stakeholder.payroll: StakeholderState.pending,
              Stakeholder.it: StakeholderState.pending,
              Stakeholder.facilities: StakeholderState.pending,
            },
          ),
        ),
      );

      await pumpStatusPage(tester);

      expect(find.widgetWithText(ElevatedButton, 'Mark Complete'), findsNWidgets(3));
    });

    testWidgets('is hidden when the request is terminal', (tester) async {
      when(() => repository.getActive()).thenAnswer(
        (_) async =>
            Result.success(_request(status: TransferRequestStatus.completed)),
      );

      await pumpStatusPage(tester);

      expect(find.byKey(const Key('simulate-decision-section')), findsNothing);
    });

    testWidgets('is hidden when there is no request at all', (tester) async {
      when(
        () => repository.getActive(),
      ).thenAnswer((_) async => Result<TransferRequest?>.success(null));

      await pumpStatusPage(tester);

      expect(find.byKey(const Key('simulate-decision-section')), findsNothing);
    });
  });

  group('Logout', () {
    testWidgets('calls LogoutEmployee and navigates to the entry route', (tester) async {
      when(
        () => repository.getActive(),
      ).thenAnswer((_) async => Result<TransferRequest?>.success(null));
      when(() => accountRepository.logout()).thenAnswer((_) async => Result.success(true));

      await pumpStatusPage(tester);

      await tester.tap(find.byKey(const Key('logout-button')));
      await tester.pumpAndSettle();

      verify(() => accountRepository.logout()).called(1);
      expect(find.text('ENTRY'), findsOneWidget);
    });
  });
}
