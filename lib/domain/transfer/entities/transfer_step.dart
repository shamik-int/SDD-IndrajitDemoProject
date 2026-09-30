import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'stakeholder_task.dart';

/// Spec `Step`. Only steps that have been reached exist (SD-01).
class TransferStep extends Equatable {
  final StepId stepId;
  final StepState state;
  final Outcome? decision;
  final String? reason;
  final DateTime? recordedAt;
  final StakeholderTask? task;

  const TransferStep({
    required this.stepId,
    required this.state,
    this.decision,
    this.reason,
    this.recordedAt,
    this.task,
  });

  Actor get stakeholder => stepId.stakeholder;

  /// "Completed (Approved)" for an approved manager/HR step (SD-02).
  String get stateLabel =>
      state == StepState.completed && decision == Outcome.approved ? 'Completed (Approved)' : state.label;

  TransferStep copyWith({StepState? state, Outcome? decision, String? reason, DateTime? recordedAt}) {
    return TransferStep(
      stepId: stepId,
      state: state ?? this.state,
      decision: decision ?? this.decision,
      reason: reason ?? this.reason,
      recordedAt: recordedAt ?? this.recordedAt,
      task: task,
    );
  }

  @override
  List<Object?> get props => [stepId, state, decision, reason, recordedAt, task];
}
