import 'package:get/get.dart';

import '../../core/time/clock.dart';
import '../../domain/transfer/entities/enums.dart';
import '../../domain/transfer/portal/portal_contracts.dart';
import '../../domain/transfer/usecases/transfer_usecases.dart';
import '../../presentation/transfer/employee/my_requests_controller.dart';
import '../../presentation/transfer/employee/my_requests_page.dart';
import '../../presentation/transfer/employee/request_detail_controller.dart';
import '../../presentation/transfer/employee/request_detail_page.dart';
import '../../presentation/transfer/employee/transfer_form_controller.dart';
import '../../presentation/transfer/employee/transfer_form_page.dart';
import '../../presentation/transfer/shared/app_entry_controller.dart';
import '../../presentation/transfer/shared/app_entry_page.dart';
import '../../presentation/transfer/shared/blocked_page.dart';
import '../../presentation/transfer/shared/role_guard.dart';
import '../../presentation/transfer/shared/session_state.dart';
import '../../presentation/transfer/shared/sign_in_controller.dart';
import '../../presentation/transfer/shared/sign_in_page.dart';
import '../../presentation/transfer/tester/simulation_controller.dart';
import '../../presentation/transfer/tester/simulation_page.dart';
import 'app_routes.dart';

/// Routes of the v2.4 journey. Employee routes and the tester route are
/// guarded by role (PD-07); controllers are bound per route.
abstract class AppPages {
  AppPages._();

  static const initial = AppRoutes.entry;

  static Map<String, dynamic> get _args => (Get.arguments as Map?)?.cast<String, dynamic>() ?? const {};

  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.entry,
      page: () => const AppEntryPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AppEntryController(users: Get.find<CurrentUserProvider>(), session: Get.find<SessionState>()));
      }),
    ),
    GetPage(
      name: AppRoutes.signIn,
      page: () => const SignInPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SignInController(signInService: Get.find<SignInService>(), session: Get.find<SessionState>()));
      }),
    ),
    GetPage(
      name: AppRoutes.myRequests,
      page: () => const MyRequestsPage(),
      middlewares: [RoleGuard(UserRole.employee)],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MyRequestsController(listMyTransferRequests: Get.find(), clock: Get.find<Clock>()));
      }),
    ),
    GetPage(
      name: AppRoutes.newRequest,
      page: () => const TransferFormPage(),
      middlewares: [RoleGuard(UserRole.employee)],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => TransferFormController(
              getActive: Get.find<GetMyActiveTransferRequest>(),
              getCurrentValues: Get.find<GetMyCurrentValues>(),
              submitTransferRequest: Get.find<SubmitTransferRequest>(),
              refs: Get.find<ReferenceLists>(),
              clock: Get.find<Clock>(),
            ));
      }),
    ),
    GetPage(
      name: AppRoutes.requestDetail,
      page: () => const RequestDetailPage(),
      middlewares: [RoleGuard(UserRole.employee)],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => RequestDetailController(
              getRequest: Get.find<GetMyTransferRequest>(),
              getHistory: Get.find<GetRequestHistory>(),
              refs: Get.find<ReferenceLists>(),
              clock: Get.find<Clock>(),
              requestId: _args['requestId'] as String? ?? '',
              justSubmitted: _args['justSubmitted'] as bool? ?? false,
            ));
      }),
    ),
    GetPage(
      name: AppRoutes.simulate,
      page: () => const SimulationPage(),
      middlewares: [RoleGuard(UserRole.tester)],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SimulationController(
              listTasks: Get.find<ListOpenStakeholderTasks>(),
              recordOutcome: Get.find<RecordStakeholderOutcome>(),
              refs: Get.find<ReferenceLists>(),
              clock: Get.find<Clock>(),
            ));
      }),
    ),
    GetPage(name: AppRoutes.blocked, page: () => const BlockedPage()),
  ];
}
