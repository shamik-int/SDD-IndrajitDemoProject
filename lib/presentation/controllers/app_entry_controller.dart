import '../../app/routes/app_routes.dart';
import '../../domain/usecases/get_active_transfer_request_status.dart';
import '../../domain/usecases/get_current_session.dart';

/// Decides which screen the app opens to. A session check (AC1,
/// employee-registration-login) is checked first — anything else is
/// unreachable without one; only once a session is confirmed does the
/// existing status-vs-submission decision run.
class AppEntryController {
  final GetActiveTransferRequestStatus getActiveTransferRequestStatus;
  final GetCurrentSession getCurrentSession;

  const AppEntryController({
    required this.getActiveTransferRequestStatus,
    required this.getCurrentSession,
  });

  Future<String> resolveInitialRoute() async {
    final sessionResult = await getCurrentSession();
    final hasSession = sessionResult.isSuccess && sessionResult.data != null;
    if (!hasSession) return AppRoutes.login;

    final result = await getActiveTransferRequestStatus();
    final hasActive = result.isSuccess && result.data != null;
    return hasActive
        ? AppRoutes.transferRequestStatus
        : AppRoutes.transferRequestSubmit;
  }
}
