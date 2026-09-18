import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../core/local_db/local_db_service.dart';
import '../../core/network/api_client.dart';
import '../../data/datasources/local/employee_account_local_datasource.dart';
import '../../data/datasources/local/transfer_request_local_datasource.dart';
import '../../data/repositories/employee_account_repository_impl.dart';
import '../../data/repositories/transfer_request_repository_impl.dart';
import '../../domain/repositories/employee_account_repository.dart';
import '../../domain/repositories/transfer_request_repository.dart';
import '../../domain/usecases/get_active_transfer_request_status.dart';
import '../../domain/usecases/get_current_session.dart';
import '../../domain/usecases/get_transfer_request_by_id.dart';
import '../../domain/usecases/login_employee.dart';
import '../../domain/usecases/logout_employee.dart';
import '../../domain/usecases/record_stakeholder_decision.dart';
import '../../domain/usecases/register_employee.dart';
import '../../domain/usecases/submit_transfer_request.dart';

/// Root-level singletons available for the lifetime of the app. Feature-
/// specific presentation bindings (controllers) get their own files under
/// `presentation/bindings/`, registered lazily per route — but the
/// repository/usecases below are cheap, stateless, and shared by every
/// screen that touches `employee-internal-transfer`, so they live here
/// rather than being duplicated per route binding.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<Dio>(Dio(), permanent: true);
    Get.put<ApiClient>(ApiClient(Get.find<Dio>()), permanent: true);
    Get.put<LocalDbService>(LocalDbService(), permanent: true);

    Get.put<TransferRequestLocalDataSource>(
      TransferRequestLocalDataSource(Get.find<LocalDbService>()),
      permanent: true,
    );
    Get.put<TransferRequestRepository>(
      TransferRequestRepositoryImpl(Get.find<TransferRequestLocalDataSource>()),
      permanent: true,
    );
    Get.put(SubmitTransferRequest(Get.find<TransferRequestRepository>()), permanent: true);
    Get.put(
      GetActiveTransferRequestStatus(Get.find<TransferRequestRepository>()),
      permanent: true,
    );
    Get.put(GetTransferRequestById(Get.find<TransferRequestRepository>()), permanent: true);
    Get.put(RecordStakeholderDecision(Get.find<TransferRequestRepository>()), permanent: true);

    Get.put<EmployeeAccountLocalDataSource>(
      EmployeeAccountLocalDataSource(Get.find<LocalDbService>()),
      permanent: true,
    );
    Get.put<EmployeeAccountRepository>(
      EmployeeAccountRepositoryImpl(Get.find<EmployeeAccountLocalDataSource>()),
      permanent: true,
    );
    Get.put(RegisterEmployee(Get.find<EmployeeAccountRepository>()), permanent: true);
    Get.put(LoginEmployee(Get.find<EmployeeAccountRepository>()), permanent: true);
    Get.put(GetCurrentSession(Get.find<EmployeeAccountRepository>()), permanent: true);
    Get.put(LogoutEmployee(Get.find<EmployeeAccountRepository>()), permanent: true);
  }
}
