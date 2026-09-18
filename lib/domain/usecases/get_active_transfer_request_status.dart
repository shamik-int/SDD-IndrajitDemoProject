import '../../core/result/result.dart';
import '../entities/transfer_request.dart';
import '../repositories/transfer_request_repository.dart';

class GetActiveTransferRequestStatus {
  final TransferRequestRepository repository;

  const GetActiveTransferRequestStatus(this.repository);

  Future<Result<TransferRequest?>> call() => repository.getActive();
}
