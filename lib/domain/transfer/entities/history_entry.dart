import 'package:equatable/equatable.dart';

import 'enums.dart';

/// Spec `HistoryEntry`. Append-only (BR-27): never edited or deleted.
class HistoryEntry extends Equatable {
  final int sequence;
  final DateTime recordedAt;
  final Actor actor;
  final HistoryType type;
  final StepId? stepId;
  final Outcome? outcome;
  final String? reason;
  final StepState? toState;
  final RequestStatus? fromStatus;
  final RequestStatus? toStatus;
  final DateTime? effectiveFrom;
  final String? simulatedBy;

  const HistoryEntry({
    required this.sequence,
    required this.recordedAt,
    required this.actor,
    required this.type,
    this.stepId,
    this.outcome,
    this.reason,
    this.toState,
    this.fromStatus,
    this.toStatus,
    this.effectiveFrom,
    this.simulatedBy,
  });

  @override
  List<Object?> get props => [
        sequence,
        recordedAt,
        actor,
        type,
        stepId,
        outcome,
        reason,
        toState,
        fromStatus,
        toStatus,
        effectiveFrom,
        simulatedBy,
      ];
}
