import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employee_transfer_project/core/result/result.dart';
import 'package:employee_transfer_project/domain/entities/stakeholder.dart';
import 'package:employee_transfer_project/domain/entities/stakeholder_state.dart';
import 'package:employee_transfer_project/domain/entities/transfer_request.dart';
import 'package:employee_transfer_project/domain/entities/transfer_request_status.dart';
import 'package:employee_transfer_project/domain/repositories/transfer_request_repository.dart';
import 'package:employee_transfer_project/domain/usecases/get_active_transfer_request_status.dart';
import 'package:employee_transfer_project/domain/usecases/get_transfer_request_by_id.dart';
import 'package:employee_transfer_project/presentation/controllers/transfer_request_status_controller.dart';

class MockTransferRequestRepository extends Mock
    implements TransferRequestRepository {}

TransferRequest _request({
  required TransferRequestStatus status,
  Map<Stakeholder, StakeholderState> stakeholders = const {},
  String id = 'req-1',
}) {
  final now = DateTime.now();
  return TransferRequest(
    id: id,
    departmentId: 'dept-1',
    locationId: 'loc-1',
    roleId: 'role-1',
    effectiveDate: now.add(const Duration(days: 10)),
    status: status,
    stakeholders: stakeholders,
    submittedAt: now,
    updatedAt: now,
  );
}

void main() {
  late MockTransferRequestRepository repository;
  late TransferRequestStatusController controller;

  setUp(() {
    Get.testMode = true;
    repository = MockTransferRequestRepository();
    controller = TransferRequestStatusController(
      getActiveTransferRequestStatus: GetActiveTransferRequestStatus(repository),
      getTransferRequestById: GetTransferRequestById(repository),
    );
  });

  group('onInit — AC6/AC7', () {
    test('loads the active request via getActive', () async {
      final active = _request(
        status: TransferRequestStatus.pendingManagerApproval,
        stakeholders: const {Stakeholder.manager: StakeholderState.pending},
      );
      when(
        () => repository.getActive(),
      ).thenAnswer((_) async => Result.success(active));

      controller.onInit();
      await Future<void>.delayed(Duration.zero);

      expect(controller.isLoading.value, isFalse);
      expect(controller.request.value, active);
      expect(controller.request.value!.pendingStakeholders, [Stakeholder.manager]);
    });

    test('leaves request null when there is none', () async {
      when(
        () => repository.getActive(),
      ).thenAnswer((_) async => Result<TransferRequest?>.success(null));

      controller.onInit();
      await Future<void>.delayed(Duration.zero);

      expect(controller.request.value, isNull);
    });
  });

  group('refresh — AC9, AC10, AC11, AC12, AC13', () {
    test('re-fetches the same request by id, reflecting a manager rejection (AC9)', () async {
      final initial = _request(
        status: TransferRequestStatus.pendingManagerApproval,
        stakeholders: const {Stakeholder.manager: StakeholderState.pending},
      );
      when(
        () => repository.getActive(),
      ).thenAnswer((_) async => Result.success(initial));
      controller.onInit();
      await Future<void>.delayed(Duration.zero);

      final rejected = _request(
        status: TransferRequestStatus.rejectedByManager,
        stakeholders: const {Stakeholder.manager: StakeholderState.rejected},
      );
      when(
        () => repository.getById('req-1'),
      ).thenAnswer((_) async => Result.success(rejected));

      await controller.refreshStatus();

      expect(controller.request.value!.status, TransferRequestStatus.rejectedByManager);
      expect(controller.request.value!.pendingStakeholders, isEmpty);
    });

    test('reflects HR approval fanning out to downstream stakeholders (AC10)', () async {
      final initial = _request(status: TransferRequestStatus.pendingHrValidation);
      when(
        () => repository.getActive(),
      ).thenAnswer((_) async => Result.success(initial));
      controller.onInit();
      await Future<void>.delayed(Duration.zero);

      final downstream = _request(
        status: TransferRequestStatus.pendingDownstreamUpdates,
        stakeholders: const {
          Stakeholder.payroll: StakeholderState.pending,
          Stakeholder.it: StakeholderState.pending,
          Stakeholder.facilities: StakeholderState.pending,
        },
      );
      when(
        () => repository.getById('req-1'),
      ).thenAnswer((_) async => Result.success(downstream));

      await controller.refreshStatus();

      expect(controller.request.value!.pendingStakeholders, [
        Stakeholder.payroll,
        Stakeholder.it,
        Stakeholder.facilities,
      ]);
    });

    test('reflects partial downstream completion (AC13)', () async {
      final initial = _request(
        status: TransferRequestStatus.pendingDownstreamUpdates,
        stakeholders: const {
          Stakeholder.payroll: StakeholderState.pending,
          Stakeholder.it: StakeholderState.pending,
          Stakeholder.facilities: StakeholderState.pending,
        },
      );
      when(
        () => repository.getActive(),
      ).thenAnswer((_) async => Result.success(initial));
      controller.onInit();
      await Future<void>.delayed(Duration.zero);

      final partiallyDone = _request(
        status: TransferRequestStatus.pendingDownstreamUpdates,
        stakeholders: const {
          Stakeholder.payroll: StakeholderState.completed,
          Stakeholder.it: StakeholderState.pending,
          Stakeholder.facilities: StakeholderState.pending,
        },
      );
      when(
        () => repository.getById('req-1'),
      ).thenAnswer((_) async => Result.success(partiallyDone));

      await controller.refreshStatus();

      expect(controller.request.value!.pendingStakeholders, [
        Stakeholder.it,
        Stakeholder.facilities,
      ]);
    });

    test('reflects completion with nothing pending (AC12)', () async {
      final initial = _request(
        status: TransferRequestStatus.pendingDownstreamUpdates,
        stakeholders: const {
          Stakeholder.payroll: StakeholderState.pending,
          Stakeholder.it: StakeholderState.pending,
          Stakeholder.facilities: StakeholderState.pending,
        },
      );
      when(
        () => repository.getActive(),
      ).thenAnswer((_) async => Result.success(initial));
      controller.onInit();
      await Future<void>.delayed(Duration.zero);

      final completed = _request(
        status: TransferRequestStatus.completed,
        stakeholders: const {
          Stakeholder.payroll: StakeholderState.completed,
          Stakeholder.it: StakeholderState.completed,
          Stakeholder.facilities: StakeholderState.completed,
        },
      );
      when(
        () => repository.getById('req-1'),
      ).thenAnswer((_) async => Result.success(completed));

      await controller.refreshStatus();

      expect(controller.request.value!.status, TransferRequestStatus.completed);
      expect(controller.request.value!.pendingStakeholders, isEmpty);
    });

    test('reflects HR rejection (AC11)', () async {
      final initial = _request(status: TransferRequestStatus.pendingHrValidation);
      when(
        () => repository.getActive(),
      ).thenAnswer((_) async => Result.success(initial));
      controller.onInit();
      await Future<void>.delayed(Duration.zero);

      final rejected = _request(status: TransferRequestStatus.rejectedByHr);
      when(
        () => repository.getById('req-1'),
      ).thenAnswer((_) async => Result.success(rejected));

      await controller.refreshStatus();

      expect(controller.request.value!.status, TransferRequestStatus.rejectedByHr);
      expect(controller.request.value!.pendingStakeholders, isEmpty);
    });

    test('falls back to loadActive when there is no current request yet', () async {
      when(
        () => repository.getActive(),
      ).thenAnswer((_) async => Result<TransferRequest?>.success(null));

      await controller.refreshStatus();

      verify(() => repository.getActive()).called(1);
      verifyNever(() => repository.getById(any()));
    });
  });
}
