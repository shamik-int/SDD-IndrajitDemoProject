import '../../../core/result/result.dart';
import '../entities/history_entry.dart';
import '../entities/inputs.dart';
import '../entities/org_values.dart';
import '../entities/stakeholder_task.dart';
import '../entities/transfer_request.dart';

/// Local Data Contract of spec v2.4 (OP01–OP07). Every method applies the
/// Access rules first: signed in, then role, then ownership.
abstract class TransferRequestRepository {
  /// OP01
  Future<Result<TransferRequest>> submitTransferRequest(SubmitTransferInput input);

  /// OP02
  Future<Result<ActiveState>> getMyActiveTransferRequest();

  /// OP03 — newest first.
  Future<Result<List<TransferRequestSummary>>> listMyTransferRequests();

  /// OP04 — "No request found." for a missing or another employee's ID (SD-04).
  Future<Result<TransferRequest>> getMyTransferRequest(String requestId);

  /// OP05 — oldest first.
  Future<Result<List<HistoryEntry>>> getRequestHistory(String requestId);

  /// OP06 — demo-only, TESTER only.
  Future<Result<TransferRequest>> recordStakeholderOutcome(RecordOutcomeInput input);

  /// OP07 — demo-only, TESTER only; oldest first.
  Future<Result<List<OpenStakeholderTask>>> listOpenStakeholderTasks();

  /// The signed-in employee's current values as of today (D-02), for the
  /// read-only panel on the form (AC02). Same access rules as OP01–OP05.
  Future<Result<EmployeeCurrentValues>> getMyCurrentValues();
}
