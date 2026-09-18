import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employee_transfer_project/app/routes/app_routes.dart';
import 'package:employee_transfer_project/core/result/result.dart';
import 'package:employee_transfer_project/domain/entities/submit_transfer_request_input.dart';
import 'package:employee_transfer_project/domain/entities/transfer_request.dart';
import 'package:employee_transfer_project/domain/entities/transfer_request_status.dart';
import 'package:employee_transfer_project/domain/repositories/employee_account_repository.dart';
import 'package:employee_transfer_project/domain/repositories/transfer_request_repository.dart';
import 'package:employee_transfer_project/domain/usecases/get_active_transfer_request_status.dart';
import 'package:employee_transfer_project/domain/usecases/logout_employee.dart';
import 'package:employee_transfer_project/domain/usecases/submit_transfer_request.dart';
import 'package:employee_transfer_project/presentation/controllers/transfer_request_submission_controller.dart';
import 'package:employee_transfer_project/presentation/pages/transfer_request_submission_page.dart';

class MockTransferRequestRepository extends Mock
    implements TransferRequestRepository {}

class MockEmployeeAccountRepository extends Mock
    implements EmployeeAccountRepository {}

class FakeSubmitTransferRequestInput extends Fake
    implements SubmitTransferRequestInput {}

TransferRequest _request(DateTime effectiveDate) {
  final now = DateTime.now();
  return TransferRequest(
    id: 'req-1',
    departmentId: 'dept-eng',
    locationId: 'loc-blr',
    roleId: 'role-swe',
    effectiveDate: effectiveDate,
    status: TransferRequestStatus.pendingManagerApproval,
    stakeholders: const {},
    submittedAt: now,
    updatedAt: now,
  );
}

void main() {
  late MockTransferRequestRepository repository;
  late MockEmployeeAccountRepository accountRepository;

  setUpAll(() {
    registerFallbackValue(FakeSubmitTransferRequestInput());
  });

  setUp(() {
    Get.testMode = true;
    repository = MockTransferRequestRepository();
    accountRepository = MockEmployeeAccountRepository();
  });

  tearDown(() {
    Get.reset();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    Get.put<TransferRequestSubmissionController>(
      TransferRequestSubmissionController(
        submitTransferRequest: SubmitTransferRequest(repository),
        getActiveTransferRequestStatus: GetActiveTransferRequestStatus(repository),
      ),
    );
    Get.put<LogoutEmployee>(LogoutEmployee(accountRepository));
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.transferRequestSubmit,
        getPages: [
          GetPage(
            name: AppRoutes.transferRequestSubmit,
            page: () => const TransferRequestSubmissionPage(),
          ),
          GetPage(name: AppRoutes.placeholder, page: () => const Scaffold(body: Text('ENTRY'))),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('AC2: shows the blocking message when an active request exists', (
    tester,
  ) async {
    when(() => repository.getActive()).thenAnswer(
      (_) async => Result.success(_request(DateTime.now().add(const Duration(days: 30)))),
    );

    await pumpPage(tester);

    expect(
      find.textContaining('already have a transfer request in progress'),
      findsOneWidget,
    );
    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
  });

  testWidgets('AC1: shows the submission form when there is no active request', (
    tester,
  ) async {
    when(
      () => repository.getActive(),
    ).thenAnswer((_) async => Result<TransferRequest?>.success(null));

    await pumpPage(tester);

    expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(3));
    expect(find.widgetWithText(ElevatedButton, 'Submit'), findsOneWidget);
  });

  testWidgets('department dropdown shows the configured options when tapped', (
    tester,
  ) async {
    when(
      () => repository.getActive(),
    ).thenAnswer((_) async => Result<TransferRequest?>.success(null));

    await pumpPage(tester);

    await tester.tap(find.byKey(const Key('department-dropdown')));
    await tester.pumpAndSettle();

    expect(find.text('Engineering'), findsWidgets);
  });

  testWidgets(
    'AC4: blocks submission and shows field errors when nothing is filled in',
    (tester) async {
      when(
        () => repository.getActive(),
      ).thenAnswer((_) async => Result<TransferRequest?>.success(null));

      await pumpPage(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Submit'));
      await tester.pumpAndSettle();

      expect(find.text('Department is required.'), findsOneWidget);
      verifyNever(() => repository.submit(any()));
    },
  );

  testWidgets(
    'AC3: submits successfully and shows a confirmation once all fields are valid',
    (tester) async {
      when(
        () => repository.getActive(),
      ).thenAnswer((_) async => Result<TransferRequest?>.success(null));
      when(() => repository.submit(any())).thenAnswer(
        (_) async => Result.success(_request(DateTime.now().add(const Duration(days: 30)))),
      );

      await pumpPage(tester);

      final controller = Get.find<TransferRequestSubmissionController>();
      controller.setDepartment('dept-eng');
      controller.setLocation('loc-blr');
      controller.setRole('role-swe');
      controller.setEffectiveDate(DateTime.now().add(const Duration(days: 30)));
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Submit'));
      await tester.pumpAndSettle();

      verify(() => repository.submit(any())).called(1);
      expect(find.textContaining('submitted'), findsWidgets);
    },
  );

  group('Logout', () {
    testWidgets('calls LogoutEmployee and navigates to the entry route', (tester) async {
      when(
        () => repository.getActive(),
      ).thenAnswer((_) async => Result<TransferRequest?>.success(null));
      when(() => accountRepository.logout()).thenAnswer((_) async => Result.success(true));

      await pumpPage(tester);

      await tester.tap(find.byKey(const Key('logout-button')));
      await tester.pumpAndSettle();

      verify(() => accountRepository.logout()).called(1);
      expect(find.text('ENTRY'), findsOneWidget);
    });
  });
}
