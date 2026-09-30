import '../../../core/result/result.dart';
import '../entities/current_user.dart';
import '../entities/org_values.dart';
import '../entities/scheduled_change.dart';

/// Consumed contract (spec v2.4, dependencies D-01 to D-03). V1 provides
/// demo implementations in `data/transfer/portal/` (plan PD-01 to PD-03).

/// D-01 — the signed-in user; `null` when nobody is signed in.
abstract class CurrentUserProvider {
  Future<CurrentUser?> currentUser();
}

/// D-02 — the employee's profile and scheduled organisational change.
abstract class EmployeeProfile {
  /// `null` when [employeeId] has no profile (e.g. a tester).
  Future<EmployeeCurrentValues?> getCurrentValues(String employeeId, {required DateTime asOf});

  /// Called only when a request becomes COMPLETED (SD-16). Idempotent by
  /// [requestId] (SD-20).
  Future<Result<ScheduledChange>> scheduleOrganisationalChange(
    String employeeId, {
    required String requestId,
    required OrgValues values,
    required DateTime effectiveFrom,
  });

  Future<ScheduledChange?> pendingScheduledChange(String employeeId, {required DateTime asOf});
}

class ReferenceItem {
  final String id;
  final String name;

  const ReferenceItem(this.id, this.name);
}

/// D-03 — reference lists.
abstract class ReferenceLists {
  List<ReferenceItem> departments();
  List<ReferenceItem> locations();
  List<ReferenceItem> roles();
}

extension ReferenceListsNames on ReferenceLists {
  String _name(List<ReferenceItem> items, String id) =>
      items.firstWhere((i) => i.id == id, orElse: () => ReferenceItem(id, id)).name;

  String departmentName(String id) => _name(departments(), id);
  String locationName(String id) => _name(locations(), id);
  String roleName(String id) => _name(roles(), id);
}

/// D-01 sign-in, demo-level in V1 (BR-26). Not part of this spec; consumed
/// only to get a signed-in user.
abstract class SignInService implements CurrentUserProvider {
  Future<Result<CurrentUser>> signIn({required String email, required String password});
  Future<void> signOut();
}
