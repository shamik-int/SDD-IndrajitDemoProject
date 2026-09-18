import 'package:get/get.dart';

import '../../domain/usecases/get_active_transfer_request_status.dart';
import '../../domain/usecases/submit_transfer_request.dart';
import '../controllers/transfer_request_submission_controller.dart';

class TransferRequestSubmissionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransferRequestSubmissionController>(
      () => TransferRequestSubmissionController(
        submitTransferRequest: Get.find<SubmitTransferRequest>(),
        getActiveTransferRequestStatus: Get.find<GetActiveTransferRequestStatus>(),
      ),
    );
  }
}
