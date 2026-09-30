import 'package:equatable/equatable.dart';

import '../../../core/constants/transfer_messages.dart';
import '../../../core/result/result.dart';
import '../../../core/time/local_date.dart';
import '../entities/org_values.dart';
import '../entities/scheduled_change.dart';

class ScheduleOutcome extends Equatable {
  final ScheduledChange change;
  final List<ScheduledChange> changes;
  final bool created;

  const ScheduleOutcome({required this.change, required this.changes, required this.created});

  @override
  List<Object?> get props => [change, changes, created];
}

/// Pure rules for an employee's scheduled organisational changes (D-02).
/// Used by the public `scheduleOrganisationalChange` and inside OP06, so the
/// SD-20 table exists in one place (plan: "Architecture Approach").
class ScheduleBook {
  ScheduleBook._();

  /// A change has taken effect once [asOf] is on or after both its
  /// `effectiveFrom` and the day it was scheduled (never retroactively, SD-05).
  static bool hasTakenEffect(ScheduledChange change, DateTime asOf) =>
      LocalDate.isOnOrAfter(asOf, change.effectiveFrom) && LocalDate.isOnOrAfter(asOf, change.scheduledAt);

  /// SD-20 table.
  static Result<ScheduleOutcome> schedule(
    List<ScheduledChange> existing, {
    required String employeeId,
    required String requestId,
    required OrgValues values,
    required DateTime effectiveFrom,
    required DateTime now,
  }) {
    final from = LocalDate.dateOnly(effectiveFrom);

    for (final change in existing) {
      if (change.requestId != requestId) continue;
      final same = change.values.sameAs(values) && change.effectiveFrom == from;
      if (!same) return Result.error(TransferMessages.differentChangeScheduled);
      return Result.success(ScheduleOutcome(change: change, changes: existing, created: false));
    }

    if (existing.any((c) => !hasTakenEffect(c, now))) {
      return Result.error(TransferMessages.anotherTransferScheduled);
    }

    final change = ScheduledChange(
      requestId: requestId,
      employeeId: employeeId,
      values: values,
      effectiveFrom: from,
      scheduledAt: now,
    );
    return Result.success(ScheduleOutcome(change: change, changes: [...existing, change], created: true));
  }

  /// The change that has not taken effect yet, if any (`asOf` before its
  /// `effectiveFrom`).
  static ScheduledChange? pending(List<ScheduledChange> changes, DateTime asOf) {
    for (final c in changes) {
      if (LocalDate.isBefore(asOf, c.effectiveFrom)) return c;
    }
    return null;
  }

  /// `getCurrentValues`: the baseline with every change that has taken effect
  /// applied, in the order they were scheduled.
  static EmployeeCurrentValues currentValues(
    EmployeeCurrentValues baseline,
    List<ScheduledChange> changes,
    DateTime asOf,
  ) {
    final ordered = [...changes]..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    var values = baseline.values;
    for (final c in ordered) {
      if (hasTakenEffect(c, asOf)) values = c.values;
    }
    return EmployeeCurrentValues(values: values, managerName: baseline.managerName);
  }
}
