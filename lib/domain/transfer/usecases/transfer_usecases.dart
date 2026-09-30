import '../../../core/result/result.dart';
import '../entities/history_entry.dart';
import '../entities/inputs.dart';
import '../entities/org_values.dart';
import '../entities/stakeholder_task.dart';
import '../entities/transfer_request.dart';
import '../repositories/transfer_request_repository.dart';

/// One usecase per Local Data Contract operation (plan v4.0, step 3). They
/// only delegate: the rules live in `TransferWorkflow` and the repository.

class SubmitTransferRequest {
  final TransferRequestRepository repository;
  const SubmitTransferRequest(this.repository);
  Future<Result<TransferRequest>> call(SubmitTransferInput input) => repository.submitTransferRequest(input);
}

class GetMyActiveTransferRequest {
  final TransferRequestRepository repository;
  const GetMyActiveTransferRequest(this.repository);
  Future<Result<ActiveState>> call() => repository.getMyActiveTransferRequest();
}

class ListMyTransferRequests {
  final TransferRequestRepository repository;
  const ListMyTransferRequests(this.repository);
  Future<Result<List<TransferRequestSummary>>> call() => repository.listMyTransferRequests();
}

class GetMyTransferRequest {
  final TransferRequestRepository repository;
  const GetMyTransferRequest(this.repository);
  Future<Result<TransferRequest>> call(String requestId) => repository.getMyTransferRequest(requestId);
}

class GetRequestHistory {
  final TransferRequestRepository repository;
  const GetRequestHistory(this.repository);
  Future<Result<List<HistoryEntry>>> call(String requestId) => repository.getRequestHistory(requestId);
}

class RecordStakeholderOutcome {
  final TransferRequestRepository repository;
  const RecordStakeholderOutcome(this.repository);
  Future<Result<TransferRequest>> call(RecordOutcomeInput input) => repository.recordStakeholderOutcome(input);
}

class ListOpenStakeholderTasks {
  final TransferRequestRepository repository;
  const ListOpenStakeholderTasks(this.repository);
  Future<Result<List<OpenStakeholderTask>>> call() => repository.listOpenStakeholderTasks();
}

class GetMyCurrentValues {
  final TransferRequestRepository repository;
  const GetMyCurrentValues(this.repository);
  Future<Result<EmployeeCurrentValues>> call() => repository.getMyCurrentValues();
}
