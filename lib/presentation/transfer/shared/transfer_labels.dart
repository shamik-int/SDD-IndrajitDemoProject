import '../../../core/time/local_date.dart';
import '../../../domain/transfer/entities/enums.dart';
import '../../../domain/transfer/entities/history_entry.dart';
import '../../../domain/transfer/entities/org_values.dart';
import '../../../domain/transfer/entities/transfer_request.dart';
import '../../../domain/transfer/portal/portal_contracts.dart';
import 'package:intl/intl.dart';

/// Display text shared by the employee and tester screens.
class TransferLabels {
  TransferLabels._();

  static final _time = DateFormat('d MMM yyyy HH:mm');

  static String values(OrgValues v, ReferenceLists refs) =>
      '${refs.departmentName(v.departmentId)}, ${refs.locationName(v.locationId)}, ${refs.roleName(v.roleId)}';

  static String timestamp(DateTime t) => _time.format(t);

  /// Status label; a COMPLETED request awaiting effect says so (SD-17).
  static String status(TransferRequest r, DateTime today) =>
      r.isAwaitingEffect(today) ? _awaiting(r.effectiveDate) : r.status.label;

  static String summaryStatus(TransferRequestSummary s, DateTime today) =>
      s.status == RequestStatus.completed && LocalDate.isBefore(today, s.effectiveDate)
          ? _awaiting(s.effectiveDate)
          : s.status.label;

  static String _awaiting(DateTime effectiveDate) => 'Completed: takes effect on ${LocalDate.format(effectiveDate)}';

  static String actor(Actor a) => switch (a) {
        Actor.employee => 'Employee',
        Actor.manager => 'Manager',
        Actor.hr => 'HR',
        Actor.payroll => 'Payroll',
        Actor.it => 'IT',
        Actor.facilities => 'Facilities',
        Actor.system => 'System',
      };

  static String outcome(Outcome o) => switch (o) {
        Outcome.approved => 'Approved',
        Outcome.rejected => 'Rejected',
        Outcome.completed => 'Completed',
        Outcome.failed => 'Failed',
      };

  static String history(HistoryEntry e) => switch (e.type) {
        HistoryType.submitted => 'Request submitted',
        HistoryType.stepOutcome =>
          '${e.stepId!.pendingAction}: ${outcome(e.outcome!)}${e.reason == null ? '' : ' — reason: ${e.reason}'}',
        HistoryType.stepSet => '${e.stepId!.pendingAction} set to ${e.toState!.label}',
        HistoryType.statusChanged => 'Status: ${e.fromStatus!.label} → ${e.toStatus!.label}',
        HistoryType.changeScheduled =>
          'Organisational change scheduled, effective from ${LocalDate.format(e.effectiveFrom!)}',
      };
}
