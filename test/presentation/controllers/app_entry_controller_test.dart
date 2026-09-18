import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employee_transfer_project/app/routes/app_routes.dart';
import 'package:employee_transfer_project/core/result/result.dart';
import 'package:employee_transfer_project/domain/entities/employee_account.dart';
import 'package:employee_transfer_project/domain/entities/transfer_request.dart';
import 'package:employee_transfer_project/domain/entities/transfer_request_status.dart';
import 'package:employee_transfer_project/domain/repositories/employee_account_repository.dart';
import 'package:employee_transfer_project/domain/repositories/transfer_request_repository.dart';
import 'package:employee_transfer_project/domain/usecases/get_active_transfer_request_status.dart';
import 'package:employee_transfer_project/domain/usecases/get_current_session.dart';
import 'package:employee_transfer_project/presentation/controllers/app_entry_controller.dart';

class MockTransferRequestRepository extends Mock
    implements TransferRequestRepository {}

class MockEmployeeAccountRepository extends Mock
    implements EmployeeAccountRepository {}

EmployeeAccount _account() {
  return EmployeeAccount(
    email: 'person@intglobal.com',
    name: 'Person One',
    currentDepartmentId: 'dept-eng',
    currentLocationId: 'loc-blr',
    currentRoleId: 'role-swe',
    registeredAt: DateTime(2026, 9, 18),
  );
}

void main() {
  late MockTransferRequestRepository transferRepository;
  late MockEmployeeAccountRepository accountRepository;
  late AppEntryController controller;

  setUp(() {
    transferRepository = MockTransferRequestRepository();
    accountRepository = MockEmployeeAccountRepository();
    controller = AppEntryController(
      getActiveTransferRequestStatus: GetActiveTransferRequestStatus(transferRepository),
      getCurrentSession: GetCurrentSession(accountRepository),
    );
  });

  group('AC1 — no session', () {
    test('resolves to the login route when no session is active', () async {
      when(
        () => accountRepository.getCurrentSession(),
      ).thenAnswer((_) async => Result<EmployeeAccount?>.success(null));

      final route = await controller.resolveInitialRoute();

      expect(route, AppRoutes.login);
      verifyNever(() => transferRepository.getActive());
    });

    test('resolves to the login route when the session check itself errors', () async {
      when(
        () => accountRepository.getCurrentSession(),
      ).thenAnswer((_) async => Result.error('Local read failed.'));

      final route = await controller.resolveInitialRoute();

      expect(route, AppRoutes.login);
    });
  });

  group('AC6/AC8 — a session exists, falls through to the existing status-vs-submit logic', () {
    setUp(() {
      when(
        () => accountRepository.getCurrentSession(),
      ).thenAnswer((_) async => Result.success(_account()));
    });

    test('resolves to the status route when an active request exists', () async {
      final now = DateTime.now();
      when(() => transferRepository.getActive()).thenAnswer(
        (_) async => Result.success(
          TransferRequest(
            id: 'req-1',
            departmentId: 'd',
            locationId: 'l',
            roleId: 'r',
            effectiveDate: now.add(const Duration(days: 10)),
            status: TransferRequestStatus.pendingManagerApproval,
            stakeholders: const {},
            submittedAt: now,
            updatedAt: now,
          ),
        ),
      );

      final route = await controller.resolveInitialRoute();

      expect(route, AppRoutes.transferRequestStatus);
    });

    test('resolves to the submission route when there is no active request', () async {
      when(
        () => transferRepository.getActive(),
      ).thenAnswer((_) async => Result<TransferRequest?>.success(null));

      final route = await controller.resolveInitialRoute();

      expect(route, AppRoutes.transferRequestSubmit);
    });

    test('resolves to the submission route if the active-request check errors', () async {
      when(
        () => transferRepository.getActive(),
      ).thenAnswer((_) async => Result.error('Local read failed.'));

      final route = await controller.resolveInitialRoute();

      expect(route, AppRoutes.transferRequestSubmit);
    });
  });
}
