import 'package:get/get.dart';

import '../../domain/usecases/register_employee.dart';
import '../controllers/register_controller.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterController>(
      () => RegisterController(registerEmployee: Get.find<RegisterEmployee>()),
    );
  }
}
