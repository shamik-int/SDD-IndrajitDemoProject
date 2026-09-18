import '../../core/result/result.dart';
import '../entities/stakeholder.dart';
import '../entities/stakeholder_decision.dart';
import '../entities/submit_transfer_request_input.dart';
import '../entities/transfer_request.dart';

/// Abstract contract implemented in `data/repositories/` (Hive-backed, per
/// ADR-0004 — no backend, no remote datasource). Mirrors the spec's Local
/// Data Contract (OP01–OP04) one-to-one.
abstract class TransferRequestRepository {
  /// OP01 — creates a new request. Returns `Result.error` if a mandatory
  /// field is invalid, the effective date isn't in the future, or a
  /// non-terminal request already exists.
  Future<Result<TransferRequest>> submit(SubmitTransferRequestInput input);

  /// OP02 — returns `Result.error` if no request with this id exists locally.
  Future<Result<TransferRequest>> getById(String requestId);

  /// OP03 — `Result.success(null)` if there is no active (non-terminal)
  /// request locally.
  Future<Result<TransferRequest?>> getActive();

  /// OP04 — backs the Simulate Decision control only. Returns `Result.error`
  /// if the stakeholder/decision combination doesn't match the request's
  /// current valid next step.
  Future<Result<TransferRequest>> recordStakeholderDecision({
    required String requestId,
    required Stakeholder stakeholder,
    required StakeholderDecision decision,
  });
}
