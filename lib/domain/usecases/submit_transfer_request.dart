import '../../core/result/result.dart';
import '../entities/submit_transfer_request_input.dart';
import '../entities/transfer_request.dart';
import '../repositories/transfer_request_repository.dart';

class SubmitTransferRequest {
  final TransferRequestRepository repository;

  const SubmitTransferRequest(this.repository);

  Future<Result<TransferRequest>> call(SubmitTransferRequestInput input) {
    return repository.submit(input);
  }
}
