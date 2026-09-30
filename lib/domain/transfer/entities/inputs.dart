import 'package:equatable/equatable.dart';

import 'enums.dart';

/// OP01 input. Fields are nullable because "missing" is a validated case (AC04).
class SubmitTransferInput extends Equatable {
  final String submissionId;
  final String? departmentId;
  final String? locationId;
  final String? roleId;
  final DateTime? effectiveDate;
  final String? reason;

  const SubmitTransferInput({
    required this.submissionId,
    required this.departmentId,
    required this.locationId,
    required this.roleId,
    required this.effectiveDate,
    this.reason,
  });

  @override
  List<Object?> get props => [submissionId, departmentId, locationId, roleId, effectiveDate, reason];
}

/// OP06 input.
class RecordOutcomeInput extends Equatable {
  final String requestId;
  final StepId stepId;
  final Outcome outcome;
  final String? reason;

  const RecordOutcomeInput({required this.requestId, required this.stepId, required this.outcome, this.reason});

  @override
  List<Object?> get props => [requestId, stepId, outcome, reason];
}
