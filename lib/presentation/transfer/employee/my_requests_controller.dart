import 'package:get/get.dart';

import '../../../core/time/clock.dart';
import '../../../domain/transfer/entities/transfer_request.dart';
import '../../../domain/transfer/usecases/transfer_usecases.dart';

/// My transfer requests (OP03, AC30).
class MyRequestsController extends GetxController {
  final ListMyTransferRequests listMyTransferRequests;
  final Clock clock;

  MyRequestsController({required this.listMyTransferRequests, required this.clock});

  final requests = <TransferRequestSummary>[].obs;
  final isLoading = true.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    final result = await listMyTransferRequests();
    if (isClosed) return;
    error.value = result.isError ? result.message : null;
    requests.assignAll(result.data ?? const []);
    isLoading.value = false;
  }
}
