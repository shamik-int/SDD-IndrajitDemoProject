import '../../core/result/result.dart';
import '../entities/transfer_request.dart';
import '../repositories/transfer_request_repository.dart';

class GetTransferRequestById {
  final TransferRequestRepository repository;

  const GetTransferRequestById(this.repository);

  Future<Result<TransferRequest>> call(String requestId) {
    return repository.getById(requestId);
  }
}
