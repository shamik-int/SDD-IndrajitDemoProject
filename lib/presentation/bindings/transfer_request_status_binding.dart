import 'package:get/get.dart';

import '../../domain/usecases/get_active_transfer_request_status.dart';
import '../../domain/usecases/get_transfer_request_by_id.dart';
import '../../domain/usecases/record_stakeholder_decision.dart';
import '../controllers/simulate_decision_controller.dart';
import '../controllers/transfer_request_status_controller.dart';

class TransferRequestStatusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransferRequestStatusController>(
      () => TransferRequestStatusController(
        getActiveTransferRequestStatus: Get.find<GetActiveTransferRequestStatus>(),
        getTransferRequestById: Get.find<GetTransferRequestById>(),
      ),
    );
    Get.lazyPut<SimulateDecisionController>(
      () => SimulateDecisionController(
        recordStakeholderDecision: Get.find<RecordStakeholderDecision>(),
      ),
    );
  }
}
