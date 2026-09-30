import '../../../app/routes/app_routes.dart';
import '../../../domain/transfer/portal/portal_contracts.dart';
import 'session_state.dart';

/// Start-up routing by role (plan PD-07).
class AppEntryController {
  final CurrentUserProvider users;
  final SessionState session;

  const AppEntryController({required this.users, required this.session});

  Future<String> resolveInitialRoute() async {
    final user = await users.currentUser();
    session.user.value = user;
    if (user == null) return AppRoutes.signIn;
    return user.isTester ? AppRoutes.simulate : AppRoutes.myRequests;
  }
}
