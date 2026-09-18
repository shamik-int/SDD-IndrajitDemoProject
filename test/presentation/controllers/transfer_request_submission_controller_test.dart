import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employee_transfer_project/core/result/result.dart';
import 'package:employee_transfer_project/domain/entities/submit_transfer_request_input.dart';
import 'package:employee_transfer_project/domain/entities/transfer_request.dart';
import 'package:employee_transfer_project/domain/entities/transfer_request_status.dart';
import 'package:employee_transfer_project/domain/repositories/transfer_request_repository.dart';
import 'package:employee_transfer_project/domain/usecases/get_active_transfer_request_status.dart';
import 'package:employee_transfer_project/domain/usecases/submit_transfer_request.dart';
import 'package:employee_transfer_project/presentation/controllers/transfer_request_submission_controller.dart';

class MockTransferRequestRepository extends Mock
    implements TransferRequestRepository {}

class FakeSubmitTransferRequestInput extends Fake
    implements SubmitTransferRequestInput {}

TransferRequest _request(DateTime effectiveDate) {
  final now = DateTime.now();
  return TransferRequest(
    id: 'req-1',
    departmentId: 'dept-1',
    locationId: 'loc-1',
    roleId: 'role-1',
    effectiveDate: effectiveDate,
    status: TransferRequestStatus.pendingManagerApproval,
    stakeholders: const {},
    submittedAt: now,
    updatedAt: now,
  );
}

void main() {
  late MockTransferRequestRepository repository;
  late TransferRequestSubmissionController controller;

  setUpAll(() {
    registerFallbackValue(FakeSubmitTransferRequestInput());
  });

  setUp(() {
    Get.testMode = true;
    repository = MockTransferRequestRepository();
    controller = TransferRequestSubmissionController(
      submitTransferRequest: SubmitTransferRequest(repository),
      getActiveTransferRequestStatus: GetActiveTransferRequestStatus(repository),
    );
  });

  group('AC2 — active-request check on init', () {
    test('hasActiveRequest is true when the repository has an active request', () async {
      when(() => repository.getActive()).thenAnswer(
        (_) async => Result.success(_request(DateTime.now().add(const Duration(days: 10)))),
      );

      controller.onInit();
      await Future<void>.delayed(Duration.zero);

      expect(controller.isCheckingActiveRequest.value, isFalse);
      expect(controller.hasActiveRequest.value, isTrue);
    });

    test('hasActiveRequest is false when there is none', () async {
      when(
        () => repository.getActive(),
      ).thenAnswer((_) async => Result<TransferRequest?>.success(null));

      controller.onInit();
      await Future<void>.delayed(Duration.zero);

      expect(controller.hasActiveRequest.value, isFalse);
    });
  });

  group('AC4/AC5 — validation', () {
    test('blocks submission and sets a field error per empty mandatory field', () async {
      final result = await controller.submit();

      expect(result, isFalse);
      expect(controller.departmentError.value, isNotNull);
      expect(controller.locationError.value, isNotNull);
      expect(controller.roleError.value, isNotNull);
      expect(controller.effectiveDateError.value, isNotNull);
      verifyNever(() => repository.submit(any()));
    });

    test('blocks submission when effective date is today', () async {
      controller.setDepartment('dept-1');
      controller.setLocation('loc-1');
      controller.setRole('role-1');
      controller.setEffectiveDate(DateTime.now());

      final result = await controller.submit();

      expect(result, isFalse);
      expect(controller.effectiveDateError.value, contains('future'));
      verifyNever(() => repository.submit(any()));
    });

    test('clears a field error once a valid value is set', () async {
      await controller.submit();
      expect(controller.departmentError.value, isNotNull);

      controller.setDepartment('dept-1');

      expect(controller.departmentError.value, isNull);
    });
  });

  group('AC3 — successful submission', () {
    test('calls the usecase and returns true when all fields are valid', () async {
      final effectiveDate = DateTime.now().add(const Duration(days: 10));
      when(
        () => repository.submit(any()),
      ).thenAnswer((_) async => Result.success(_request(effectiveDate)));

      controller.setDepartment('dept-1');
      controller.setLocation('loc-1');
      controller.setRole('role-1');
      controller.setEffectiveDate(effectiveDate);

      final result = await controller.submit();

      expect(result, isTrue);
      expect(controller.submissionError.value, isNull);
      verify(() => repository.submit(any())).called(1);
    });

    test('surfaces a Result.error from the usecase without throwing', () async {
      when(() => repository.submit(any())).thenAnswer(
        (_) async =>
            Result.error('You already have a transfer request in progress.'),
      );

      controller.setDepartment('dept-1');
      controller.setLocation('loc-1');
      controller.setRole('role-1');
      controller.setEffectiveDate(DateTime.now().add(const Duration(days: 10)));

      final result = await controller.submit();

      expect(result, isFalse);
      expect(
        controller.submissionError.value,
        'You already have a transfer request in progress.',
      );
    });
  });
}
