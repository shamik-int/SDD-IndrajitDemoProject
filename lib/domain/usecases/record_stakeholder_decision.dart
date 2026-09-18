import '../../core/result/result.dart';
import '../entities/stakeholder.dart';
import '../entities/stakeholder_decision.dart';
import '../entities/transfer_request.dart';
import '../repositories/transfer_request_repository.dart';

/// Backs the Simulate Decision control (spec AC14) only — not a real
/// stakeholder-facing operation (ADR-0004).
class RecordStakeholderDecision {
  final TransferRequestRepository repository;

  const RecordStakeholderDecision(this.repository);

  Future<Result<TransferRequest>> call({
    required String requestId,
    required Stakeholder stakeholder,
    required StakeholderDecision decision,
  }) {
    return repository.recordStakeholderDecision(
      requestId: requestId,
      stakeholder: stakeholder,
      decision: decision,
    );
  }
}
