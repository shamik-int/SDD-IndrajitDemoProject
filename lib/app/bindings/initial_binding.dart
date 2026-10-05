import 'package:get/get.dart';

import '../../core/concurrency/async_lock.dart';
import '../../core/local_db/local_db_service.dart';
import '../../core/time/clock.dart';
import '../../data/transfer/datasources/transfer_ledger_local_datasource.dart';
import '../../data/transfer/portal/demo_auth_service.dart';
import '../../data/transfer/portal/demo_profile_service.dart';
import '../../data/transfer/portal/static_reference_lists.dart';
import '../../data/transfer/repositories/transfer_request_repository_impl.dart';
import '../../domain/transfer/portal/portal_contracts.dart';
import '../../domain/transfer/repositories/transfer_request_repository.dart';
import '../../domain/transfer/usecases/transfer_usecases.dart';
import '../../presentation/transfer/shared/session_state.dart';

/// App-lifetime services for `employee-internal-transfer` (plan v4.0). All
/// stateless except [SessionState], which sign-out clears. Feature
/// controllers are never registered here: they are bound per route, so
/// removing the routes on sign-out disposes them (AC31).
///
/// [localDb] and [clock] can be replaced by tests. No `ApiClient` is
/// registered: there is no backend (ADR-0004), and nothing would use it.
class InitialBinding extends Bindings {
  final LocalDbService? localDb;
  final Clock? clock;

  InitialBinding({this.localDb, this.clock});

  @override
  void dependencies() {
    final db = Get.put<LocalDbService>(localDb ?? LocalDbService(), permanent: true);
    final time = Get.put<Clock>(clock ?? const SystemClock(), permanent: true);
    final lock = Get.put<AsyncLock>(AsyncLock(), permanent: true);

    final ledgers = TransferLedgerLocalDataSource(db);
    final auth = DemoAuthService(db);
    Get.put<SignInService>(auth, permanent: true);
    Get.put<CurrentUserProvider>(auth, permanent: true);
    final profile = Get.put<EmployeeProfile>(DemoProfileService(db, ledgers, lock, time), permanent: true);
    final refs = Get.put<ReferenceLists>(const StaticReferenceLists(), permanent: true);
    Get.put(SessionState(), permanent: true);

    final repository = Get.put<TransferRequestRepository>(
      TransferRequestRepositoryImpl(
        users: auth,
        profile: profile,
        refs: refs,
        ledgers: ledgers,
        lock: lock,
        clock: time,
      ),
      permanent: true,
    );
    Get.put(SubmitTransferRequest(repository), permanent: true);
    Get.put(GetMyActiveTransferRequest(repository), permanent: true);
    Get.put(ListMyTransferRequests(repository), permanent: true);
    Get.put(GetMyTransferRequest(repository), permanent: true);
    Get.put(GetRequestHistory(repository), permanent: true);
    Get.put(RecordStakeholderOutcome(repository), permanent: true);
    Get.put(ListOpenStakeholderTasks(repository), permanent: true);
    Get.put(GetMyCurrentValues(repository), permanent: true);
  }
}
