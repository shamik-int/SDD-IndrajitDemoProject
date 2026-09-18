import '../../../core/local_db/local_db_service.dart';
import '../../../core/result/result.dart';
import '../../../domain/entities/transfer_request.dart';
import '../../models/transfer_request_model.dart';

/// Raw Hive CRUD only — no business rules (validation, single-in-flight,
/// state machine) live here, that's `data/repositories/`'s job (ADR-0004).
class TransferRequestLocalDataSource {
  static const requestsBox = 'transfer_requests';
  static const appStateBox = 'app_state';
  static const activeRequestIdKey = 'activeRequestId';

  final LocalDbService localDb;

  const TransferRequestLocalDataSource(this.localDb);

  Future<Result<bool>> saveRequest(TransferRequest request) {
    return localDb.write(requestsBox, request.id, TransferRequestModel.toMap(request));
  }

  Future<Result<TransferRequest>> getRequestById(String requestId) async {
    final result = await localDb.read<Map>(requestsBox, requestId);
    if (result.isError) {
      return Result.error('No request found for this ID.');
    }
    return Result.success(TransferRequestModel.fromMap(result.data!));
  }

  Future<String?> getActiveRequestId() async {
    final result = await localDb.read<String>(appStateBox, activeRequestIdKey);
    return result.isSuccess ? result.data : null;
  }

  Future<Result<bool>> setActiveRequestId(String? requestId) {
    if (requestId == null) {
      return localDb.delete(appStateBox, activeRequestIdKey);
    }
    return localDb.write(appStateBox, activeRequestIdKey, requestId);
  }
}
