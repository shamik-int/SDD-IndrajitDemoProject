import 'package:equatable/equatable.dart';

import '../../../core/time/local_date.dart';
import 'enums.dart';
import 'history_entry.dart';
import 'org_values.dart';
import 'transfer_step.dart';

/// Spec `TransferRequest`, plus its append-only history. Both live in one
/// record so they are always saved together (plan PD-04).
class TransferRequest extends Equatable {
  final String requestId;
  final String employeeId;
  final String employeeName;
  final String submissionId;
  final EmployeeCurrentValues current; // snapshot at submission (BR-03)
  final OrgValues proposed;
  final DateTime effectiveDate; // date only
  final String? reason;
  final DateTime submittedAt;
  final RequestStatus status;
  final List<TransferStep> steps;
  final List<HistoryEntry> history;

  const TransferRequest({
    required this.requestId,
    required this.employeeId,
    required this.employeeName,
    required this.submissionId,
    required this.current,
    required this.proposed,
    required this.effectiveDate,
    required this.reason,
    required this.submittedAt,
    required this.status,
    required this.steps,
    required this.history,
  });

  bool get isInProgress => !status.isFinal;

  TransferStep? step(StepId id) {
    for (final s in steps) {
      if (s.stepId == id) return s;
    }
    return null;
  }

  /// "Awaiting effect" (SD-17): completed, and today is before the effective date.
  bool isAwaitingEffect(DateTime today) =>
      status == RequestStatus.completed && LocalDate.isBefore(today, effectiveDate);

  /// "Effective date passed" (SD-05): in progress, and today is on or after it.
  bool isEffectiveDatePassed(DateTime today) => isInProgress && LocalDate.isOnOrAfter(today, effectiveDate);

  /// When the request reached its final status, from the history.
  DateTime? get closedAt {
    for (final e in history.reversed) {
      if (e.type == HistoryType.statusChanged && e.toStatus == status && status.isFinal) {
        return e.recordedAt;
      }
    }
    return null;
  }

  TransferRequest copyWith({RequestStatus? status, List<TransferStep>? steps, List<HistoryEntry>? history}) {
    return TransferRequest(
      requestId: requestId,
      employeeId: employeeId,
      employeeName: employeeName,
      submissionId: submissionId,
      current: current,
      proposed: proposed,
      effectiveDate: effectiveDate,
      reason: reason,
      submittedAt: submittedAt,
      status: status ?? this.status,
      steps: steps ?? this.steps,
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props => [
        requestId,
        employeeId,
        employeeName,
        submissionId,
        current,
        proposed,
        effectiveDate,
        reason,
        submittedAt,
        status,
        steps,
        history,
      ];
}

/// OP03 row.
class TransferRequestSummary extends Equatable {
  final String requestId;
  final DateTime submittedAt;
  final RequestStatus status;
  final DateTime effectiveDate;

  const TransferRequestSummary({
    required this.requestId,
    required this.submittedAt,
    required this.status,
    required this.effectiveDate,
  });

  @override
  List<Object?> get props => [requestId, submittedAt, status, effectiveDate];
}

/// OP02 result. At most one of the two is set.
class ActiveState extends Equatable {
  final TransferRequest? inProgress;
  final TransferRequest? awaitingEffect;

  const ActiveState({this.inProgress, this.awaitingEffect});

  bool get canSubmit => inProgress == null && awaitingEffect == null;

  @override
  List<Object?> get props => [inProgress, awaitingEffect];
}
