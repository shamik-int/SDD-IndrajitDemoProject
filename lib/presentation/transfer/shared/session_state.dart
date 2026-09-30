import 'package:get/get.dart';

import '../../../domain/transfer/entities/current_user.dart';

/// The signed-in user as known to the UI, for route guards only. The
/// repository never trusts this: it reads D-01 on every call. Cleared on
/// sign-out (AC31).
class SessionState {
  final user = Rxn<CurrentUser>();

  void clear() => user.value = null;
}
