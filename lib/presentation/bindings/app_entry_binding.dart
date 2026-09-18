import 'package:get/get.dart';

import '../../domain/usecases/get_active_transfer_request_status.dart';
import '../../domain/usecases/get_current_session.dart';
import '../controllers/app_entry_controller.dart';

class AppEntryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppEntryController>(
      () => AppEntryController(
        getActiveTransferRequestStatus: Get.find<GetActiveTransferRequestStatus>(),
        getCurrentSession: Get.find<GetCurrentSession>(),
      ),
    );
  }
}
