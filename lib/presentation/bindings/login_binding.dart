import 'package:get/get.dart';

import '../../domain/usecases/login_employee.dart';
import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(
      () => LoginController(loginEmployee: Get.find<LoginEmployee>()),
    );
  }
}
