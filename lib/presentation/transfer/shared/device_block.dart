import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../domain/transfer/portal/portal_contracts.dart';
import 'session_state.dart';

/// PROD block (PD-08): clears the stored session, so the next start does not
/// sign the user back in, then shows only the blocked screen. Blocks even if
/// the session cannot be cleared.
Future<void> blockDevice() async {
  await Get.find<SignInService>().signOut();
  Get.find<SessionState>().clear();
  Get.offAllNamed(AppRoutes.blocked);
}
