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
import 'package:employee_transfer_project/presentation/controllers/simulate_decision_controller.dart';

class MockTransferRequestRepository extends Mock
    implements TransferRequestRepository {}

void main() {
  late MockTransferRequestRepository repository;
  late SimulateDecisionController controller;

  setUp(() {
    repository = MockTransferRequestRepository();
    controller = SimulateDecisionController(
      recordStakeholderDecision: RecordStakeholderDecision(repository),
    );
  });

  test('AC14: returns the updated request on success and clears any error', () async {
    final now = DateTime.now();
    final updated = TransferRequest(
      id: 'req-1',
      departmentId: 'd',
      locationId: 'l',
      roleId: 'r',
      effectiveDate: now.add(const Duration(days: 10)),
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
    ).thenAnswer((_) async => Result.success(updated));

    final result = await controller.simulate(
      requestId: 'req-1',
      stakeholder: Stakeholder.manager,
      decision: StakeholderDecision.approved,
    );

    expect(result, updated);
    expect(controller.isSubmitting.value, isFalse);
    expect(controller.errorMessage.value, isNull);
  });

  test('AC14: returns null and sets errorMessage on an invalid decision', () async {
    when(
      () => repository.recordStakeholderDecision(
        requestId: 'req-1',
        stakeholder: Stakeholder.hr,
        decision: StakeholderDecision.approved,
      ),
    ).thenAnswer(
      (_) async =>
          Result.error("Invalid decision for the request's current state."),
    );

    final result = await controller.simulate(
      requestId: 'req-1',
      stakeholder: Stakeholder.hr,
      decision: StakeholderDecision.approved,
    );

    expect(result, isNull);
    expect(
      controller.errorMessage.value,
      "Invalid decision for the request's current state.",
    );
  });
}
