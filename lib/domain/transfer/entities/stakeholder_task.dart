import 'package:equatable/equatable.dart';

import 'enums.dart';

/// Stakeholder contract (BRD-001 §8): what the portal sends to a stakeholder
/// when its step becomes `PENDING`. Fixed at that moment (SD-15).
class StakeholderTask extends Equatable {
  final String taskId;
  final String requestId;
  final StepId stepId;
  final String employeeId;
  final String employeeName;
  final DateTime effectiveDate; // date only
  /// Per-step payload; keys are listed in `TransferWorkflow.taskFor`.
  final Map<String, String> payload;
  final DateTime createdAt;

  const StakeholderTask({
    required this.taskId,
    required this.requestId,
    required this.stepId,
    required this.employeeId,
    required this.employeeName,
    required this.effectiveDate,
    required this.payload,
    required this.createdAt,
  });

  Actor get stakeholder => stepId.stakeholder;

  @override
  List<Object?> get props =>
      [taskId, requestId, stepId, employeeId, employeeName, effectiveDate, payload, createdAt];
}

/// OP07 row: a pending step's task, marked when its effective date has
/// passed (SD-05, AC33).
class OpenStakeholderTask extends Equatable {
  final StakeholderTask task;
  final bool effectiveDatePassed;

  const OpenStakeholderTask({required this.task, required this.effectiveDatePassed});

  @override
  List<Object?> get props => [task, effectiveDatePassed];
}
