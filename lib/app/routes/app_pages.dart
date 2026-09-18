import 'package:get/get.dart';

import '../../presentation/bindings/app_entry_binding.dart';
import '../../presentation/bindings/login_binding.dart';
import '../../presentation/bindings/register_binding.dart';
import '../../presentation/bindings/transfer_request_status_binding.dart';
import '../../presentation/bindings/transfer_request_submission_binding.dart';
import '../../presentation/pages/login_page.dart';
import '../../presentation/pages/register_page.dart';
import '../../presentation/pages/transfer_request_status_page.dart';
import '../../presentation/pages/transfer_request_submission_page.dart';
import '../shell/app_entry_page.dart';
import 'app_routes.dart';

abstract class AppPages {
  AppPages._();

  // AppEntryPage decides, at runtime, whether to land on the status screen
  // or the submission screen (see AppEntryController).
  static const initial = AppRoutes.placeholder;

  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.placeholder,
      page: () => const AppEntryPage(),
      binding: AppEntryBinding(),
    ),
    GetPage(
      name: AppRoutes.transferRequestSubmit,
      page: () => const TransferRequestSubmissionPage(),
      binding: TransferRequestSubmissionBinding(),
    ),
    GetPage(
      name: AppRoutes.transferRequestStatus,
      page: () => const TransferRequestStatusPage(),
      binding: TransferRequestStatusBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
      binding: RegisterBinding(),
    ),
  ];
}
