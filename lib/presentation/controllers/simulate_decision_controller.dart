import 'package:get/get.dart';

import '../../domain/entities/stakeholder.dart';
import '../../domain/entities/stakeholder_decision.dart';
import '../../domain/entities/transfer_request.dart';
import '../../domain/usecases/record_stakeholder_decision.dart';

/// Drives the Simulate Decision control (AC14) — a non-production stand-in
/// for real Manager/HR/Payroll/IT/Facilities action, since this project has
/// no backend (ADR-0004).
class SimulateDecisionController extends GetxController {
  final RecordStakeholderDecision recordStakeholderDecision;

  SimulateDecisionController({required this.recordStakeholderDecision});

  final isSubmitting = false.obs;
  final errorMessage = RxnString();

  Future<TransferRequest?> simulate({
    required String requestId,
    required Stakeholder stakeholder,
    required StakeholderDecision decision,
  }) async {
    isSubmitting.value = true;
    errorMessage.value = null;

    final result = await recordStakeholderDecision(
      requestId: requestId,
      stakeholder: stakeholder,
      decision: decision,
    );

    isSubmitting.value = false;

    if (result.isError) {
      errorMessage.value = result.message;
      return null;
    }
    return result.data;
  }
}
