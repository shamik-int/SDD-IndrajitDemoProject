import 'package:get/get.dart';

import '../../domain/entities/transfer_request.dart';
import '../../domain/usecases/get_active_transfer_request_status.dart';
import '../../domain/usecases/get_transfer_request_by_id.dart';

/// Drives the status screen — AC6/AC7 (status + pending stakeholders on
/// load), AC9–AC13 (reflecting every subsequent state transition on refresh).
class TransferRequestStatusController extends GetxController {
  final GetActiveTransferRequestStatus getActiveTransferRequestStatus;
  final GetTransferRequestById getTransferRequestById;

  TransferRequestStatusController({
    required this.getActiveTransferRequestStatus,
    required this.getTransferRequestById,
  });

  final isLoading = true.obs;
  final request = Rx<TransferRequest?>(null);
  final loadError = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadActive();
  }

  Future<void> loadActive() async {
    isLoading.value = true;
    loadError.value = null;

    final result = await getActiveTransferRequestStatus();
    if (result.isError) {
      loadError.value = result.message;
    } else {
      request.value = result.data;
    }
    isLoading.value = false;
  }

  /// Re-fetches the currently-tracked request by id, so a status that
  /// becomes terminal (Completed/Rejected) between views is still shown —
  /// `getActive()` alone would stop returning it once it's no longer
  /// non-terminal (spec's Status Definitions).
  Future<void> refreshStatus() async {
    final current = request.value;
    if (current == null) {
      await loadActive();
      return;
    }

    final result = await getTransferRequestById(current.id);
    if (result.isSuccess) {
      request.value = result.data;
    }
  }
}
