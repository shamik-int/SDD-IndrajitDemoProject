import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employee_transfer_project/core/result/result.dart';
import 'package:employee_transfer_project/domain/entities/stakeholder.dart';
import 'package:employee_transfer_project/domain/entities/stakeholder_decision.dart';
import 'package:employee_transfer_project/domain/entities/stakeholder_state.dart';
import 'package:employee_transfer_project/domain/entities/transfer_request.dart';
import 'package:employee_transfer_project/domain/entities/transfer_request_status.dart';
import 'package:employee_transfer_project/domain/repositories/transfer_request_repository.dart';
import 'package:employee_transfer_project/domain/usecases/record_stakeholder_decision.dart';

class MockTransferRequestRepository extends Mock
    implements TransferRequestRepository {}

void main() {
  late MockTransferRequestRepository repository;
  late RecordStakeholderDecision usecase;

  setUp(() {
    repository = MockTransferRequestRepository();
    usecase = RecordStakeholderDecision(repository);
  });

  test('delegates to repository.recordStakeholderDecision with the given args', () async {
    final now = DateTime(2026, 9, 15);
    final expected = TransferRequest(
      id: 'req-1',
      departmentId: 'dept-1',
      locationId: 'loc-1',
      roleId: 'role-1',
      effectiveDate: DateTime(2026, 11, 1),
      status: TransferRequestStatus.pendingHrValidation,
      stakeholders: const {Stakeholder.hr: StakeholderState.pending},
      submittedAt: now,
      updatedAt: now,
    );
    when(
      () => repository.recordStakeholderDecision(
        requestId: 'req-1',
        stakeholder: Stakeholder.manager,
        decision: StakeholderDecision.approved,
      ),
    ).thenAnswer((_) async => Result.success(expected));

    final result = await usecase(
      requestId: 'req-1',
      stakeholder: Stakeholder.manager,
      decision: StakeholderDecision.approved,
    );

    expect(result, Result<TransferRequest>.success(expected));
    verify(
      () => repository.recordStakeholderDecision(
        requestId: 'req-1',
        stakeholder: Stakeholder.manager,
        decision: StakeholderDecision.approved,
      ),
    ).called(1);
  });

  test('propagates a Result.error for an invalid decision', () async {
    when(
      () => repository.recordStakeholderDecision(
        requestId: 'req-1',
        stakeholder: Stakeholder.hr,
        decision: StakeholderDecision.approved,
      ),
    ).thenAnswer(
      (_) async => Result.error('Invalid decision for the request\'s current state.'),
    );

    final result = await usecase(
      requestId: 'req-1',
      stakeholder: Stakeholder.hr,
      decision: StakeholderDecision.approved,
    );

    expect(result.isError, isTrue);
  });
}
