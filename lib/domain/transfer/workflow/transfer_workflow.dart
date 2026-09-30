import 'package:equatable/equatable.dart';

import '../../../core/constants/transfer_messages.dart';
import '../../../core/result/result.dart';
import '../../../core/time/local_date.dart';
import '../entities/current_user.dart';
import '../entities/enums.dart';
import '../entities/history_entry.dart';
import '../entities/inputs.dart';
import '../entities/org_values.dart';
import '../entities/stakeholder_task.dart';
import '../entities/transfer_request.dart';
import '../entities/transfer_step.dart';
import '../portal/portal_contracts.dart';

/// What the repository must schedule when a request becomes COMPLETED (SD-16).
class ScheduleIntent extends Equatable {
  final String requestId;
  final String employeeId;
  final OrgValues values;
  final DateTime effectiveFrom;

  const ScheduleIntent({
    required this.requestId,
    required this.employeeId,
    required this.values,
    required this.effectiveFrom,
  });

  @override
  List<Object?> get props => [requestId, employeeId, values, effectiveFrom];
}

class OutcomeResult extends Equatable {
  final TransferRequest request;
  final List<HistoryEntry> added;
  final ScheduleIntent? schedule;

  const OutcomeResult({required this.request, required this.added, this.schedule});

  @override
  List<Object?> get props => [request, added, schedule];
}

/// The transfer journey as pure functions (plan v4.0, "The workflow is pure
/// domain logic"). No I/O: the repository does access checks, loading,
/// saving and the schedule call.
class TransferWorkflow {
  TransferWorkflow._();

  // ---------------------------------------------------------------- OP01

  /// OP01 errors 1–7, in the spec's order, then the new request. Access
  /// rules and `submissionId` idempotency are checked by the caller first.
  static Result<TransferRequest> submit({
    required SubmitTransferInput input,
    required CurrentUser employee,
    required EmployeeCurrentValues current,
    required ActiveState active,
    required ReferenceLists refs,
    required String requestId,
    required DateTime now,
  }) {
    final today = LocalDate.dateOnly(now);

    bool listed(List<ReferenceItem> items, String? id) =>
        id != null && id.isNotEmpty && items.any((i) => i.id == id);

    if (!listed(refs.departments(), input.departmentId)) return Result.error(TransferMessages.selectDepartment);
    if (!listed(refs.locations(), input.locationId)) return Result.error(TransferMessages.selectLocation);
    if (!listed(refs.roles(), input.roleId)) return Result.error(TransferMessages.selectRole);
    if (input.effectiveDate == null) return Result.error(TransferMessages.enterEffectiveDate);

    final effectiveDate = LocalDate.dateOnly(input.effectiveDate!);
    if (!LocalDate.isBefore(today, effectiveDate)) return Result.error(TransferMessages.effectiveDateInFuture);

    final proposed = OrgValues(departmentId: input.departmentId!, locationId: input.locationId!, roleId: input.roleId!);
    if (proposed.sameAs(current.values)) return Result.error(TransferMessages.changeAtLeastOne);

    if (active.inProgress != null) return Result.error(TransferMessages.alreadyInProgress);
    if (active.awaitingEffect != null) {
      return Result.error(TransferMessages.awaitingEffect(active.awaitingEffect!.effectiveDate));
    }

    final reason = normaliseReason(input.reason);
    if (reason != null && reason.length > TransferMessages.maxReasonLength) {
      return Result.error(TransferMessages.reasonTooLong);
    }

    final draft = TransferRequest(
      requestId: requestId,
      employeeId: employee.userId,
      employeeName: employee.displayName,
      submissionId: input.submissionId,
      current: current,
      proposed: proposed,
      effectiveDate: effectiveDate,
      reason: reason,
      submittedAt: now,
      status: RequestStatus.pendingManagerApproval,
      steps: const [],
      history: [
        HistoryEntry(
          sequence: 1,
          recordedAt: now,
          actor: Actor.employee,
          type: HistoryType.submitted,
          toStatus: RequestStatus.pendingManagerApproval,
        ),
      ],
    );
    return Result.success(draft.copyWith(steps: [_pendingStep(StepId.managerApproval, draft, now)]));
  }

  /// Empty or only spaces is stored as no reason.
  static String? normaliseReason(String? reason) {
    final trimmed = reason?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  // ---------------------------------------------------------------- OP06

  /// OP06 errors (after access rules and "not found") and effects, exactly
  /// as the spec's Effects table, history entries in the listed order.
  static Result<OutcomeResult> recordOutcome({
    required TransferRequest request,
    required RecordOutcomeInput input,
    required String testerId,
    required DateTime now,
  }) {
    if (request.status.isFinal) return Result.error(TransferMessages.requestClosed);

    final step = request.step(input.stepId);
    if (step == null || step.state != StepState.pending) return Result.error(TransferMessages.stepNotPending);
    if (!input.stepId.validOutcomes.contains(input.outcome)) return Result.error(TransferMessages.outcomeNotValid);

    String? reason;
    if (input.outcome == Outcome.rejected) {
      reason = normaliseReason(input.reason);
      if (reason == null) return Result.error(TransferMessages.rejectionReasonRequired);
      if (reason.length > TransferMessages.maxReasonLength) return Result.error(TransferMessages.reasonTooLong);
    }

    final builder = _Changes(request, now);
    final recordedStep = step.copyWith(
      state: switch (input.outcome) {
        Outcome.approved || Outcome.completed => StepState.completed,
        Outcome.rejected => StepState.rejected,
        Outcome.failed => StepState.failed,
      },
      decision: input.outcome,
      reason: reason,
      recordedAt: now,
    );
    builder.replaceStep(recordedStep);
    builder.add(HistoryEntry(
      sequence: 0,
      recordedAt: now,
      actor: input.stepId.stakeholder,
      type: HistoryType.stepOutcome,
      stepId: input.stepId,
      outcome: input.outcome,
      reason: reason,
      simulatedBy: testerId,
    ));

    ScheduleIntent? schedule;
    switch ((input.stepId, input.outcome)) {
      case (StepId.managerApproval, Outcome.approved):
        builder.changeStatus(RequestStatus.pendingHrEligibility);
        builder.setStep(StepId.hrEligibility, StepState.pending);
      case (StepId.managerApproval, Outcome.rejected):
        builder.changeStatus(RequestStatus.rejectedByManager);
      case (StepId.hrEligibility, Outcome.approved):
        builder.changeStatus(RequestStatus.inProgress);
        triggersFor(request.current.values, request.proposed).forEach(builder.setStep);
      case (StepId.hrEligibility, Outcome.rejected):
        builder.changeStatus(RequestStatus.rejectedByHr);
      case (_, Outcome.completed):
        final stillPending = builder.steps.any((s) => s.state == StepState.pending);
        if (!stillPending) {
          builder.changeStatus(RequestStatus.completed);
          schedule = ScheduleIntent(
            requestId: request.requestId,
            employeeId: request.employeeId,
            values: request.proposed,
            effectiveFrom: request.effectiveDate,
          );
          builder.add(HistoryEntry(
            sequence: 0,
            recordedAt: now,
            actor: Actor.system,
            type: HistoryType.changeScheduled,
            effectiveFrom: request.effectiveDate,
          ));
        }
      case (_, Outcome.failed):
        for (final s in [...builder.steps]) {
          if (s.state == StepState.pending) builder.setStep(s.stepId, StepState.stopped);
        }
        builder.changeStatus(RequestStatus.failed);
      default:
        return Result.error(TransferMessages.outcomeNotValid);
    }

    return Result.success(builder.build(schedule));
  }

  // ------------------------------------------------------------ triggers

  /// Downstream triggers (BRD-001 §5), comparing the snapshot at submission
  /// with the proposed values (SD-03). Keys in Steps-table order.
  static Map<StepId, StepState> triggersFor(OrgValues current, OrgValues proposed) {
    final department = current.departmentId != proposed.departmentId;
    final location = current.locationId != proposed.locationId;
    final role = current.roleId != proposed.roleId;
    StepState when(bool required) => required ? StepState.pending : StepState.notRequired;

    return {
      StepId.orgRecordUpdate: StepState.pending,
      StepId.payrollUpdate: when(role || location),
      StepId.itAccessChange: when(department || role),
      StepId.facilitiesWorkspace: when(location),
    };
  }

  // --------------------------------------------------------------- tasks

  /// Stakeholder contract payload (BRD-001 §8), fixed when the step becomes
  /// PENDING (SD-15). Values are reference-list IDs.
  static StakeholderTask taskFor(StepId stepId, TransferRequest request, DateTime now) {
    final c = request.current.values;
    final p = request.proposed;
    final payload = switch (stepId) {
      StepId.managerApproval || StepId.hrEligibility => {
          'currentDepartmentId': c.departmentId,
          'currentLocationId': c.locationId,
          'currentRoleId': c.roleId,
          'proposedDepartmentId': p.departmentId,
          'proposedLocationId': p.locationId,
          'proposedRoleId': p.roleId,
          if (request.reason != null) 'reason': request.reason!,
        },
      StepId.orgRecordUpdate => {
          'newDepartmentId': p.departmentId,
          'newLocationId': p.locationId,
          'newRoleId': p.roleId,
        },
      StepId.payrollUpdate => {'newRoleId': p.roleId, 'newLocationId': p.locationId},
      StepId.itAccessChange => {
          'provisionDepartmentId': p.departmentId,
          'provisionRoleId': p.roleId,
          'removeDepartmentId': c.departmentId,
          'removeRoleId': c.roleId,
        },
      StepId.facilitiesWorkspace => {'newLocationId': p.locationId},
    };

    return StakeholderTask(
      taskId: '${request.requestId}:${stepId.code}',
      requestId: request.requestId,
      stepId: stepId,
      employeeId: request.employeeId,
      employeeName: request.employeeName,
      effectiveDate: request.effectiveDate,
      payload: payload,
      createdAt: now,
    );
  }

  static TransferStep _pendingStep(StepId id, TransferRequest request, DateTime now) =>
      TransferStep(stepId: id, state: StepState.pending, task: taskFor(id, request, now));
}

/// Accumulates one outcome's changes; numbers history entries on build.
class _Changes {
  final TransferRequest _request;
  final DateTime _now;
  final List<TransferStep> steps;
  final List<HistoryEntry> _added = [];
  RequestStatus _status;

  _Changes(this._request, this._now)
      : steps = [..._request.steps],
        _status = _request.status;

  void replaceStep(TransferStep step) {
    final i = steps.indexWhere((s) => s.stepId == step.stepId);
    steps[i] = step;
  }

  void add(HistoryEntry entry) => _added.add(entry);

  void changeStatus(RequestStatus to) {
    add(HistoryEntry(
      sequence: 0,
      recordedAt: _now,
      actor: Actor.system,
      type: HistoryType.statusChanged,
      fromStatus: _status,
      toStatus: to,
    ));
    _status = to;
  }

  /// Starts, stops or marks not required a step, with its STEP_SET entry.
  void setStep(StepId id, StepState state) {
    final i = steps.indexWhere((s) => s.stepId == id);
    if (i >= 0) {
      steps[i] = steps[i].copyWith(state: state);
    } else {
      steps.add(state == StepState.pending
          ? TransferWorkflow._pendingStep(id, _request, _now)
          : TransferStep(stepId: id, state: state));
    }
    add(HistoryEntry(
      sequence: 0,
      recordedAt: _now,
      actor: Actor.system,
      type: HistoryType.stepSet,
      stepId: id,
      toState: state,
    ));
  }

  OutcomeResult build(ScheduleIntent? schedule) {
    var next = _request.history.isEmpty ? 1 : _request.history.last.sequence + 1;
    final numbered = [
      for (final e in _added)
        HistoryEntry(
          sequence: next++,
          recordedAt: e.recordedAt,
          actor: e.actor,
          type: e.type,
          stepId: e.stepId,
          outcome: e.outcome,
          reason: e.reason,
          toState: e.toState,
          fromStatus: e.fromStatus,
          toStatus: e.toStatus,
          effectiveFrom: e.effectiveFrom,
          simulatedBy: e.simulatedBy,
        ),
    ];
    final ordered = [...steps]..sort((a, b) => a.stepId.index.compareTo(b.stepId.index));
    return OutcomeResult(
      request: _request.copyWith(status: _status, steps: ordered, history: [..._request.history, ...numbered]),
      added: numbered,
      schedule: schedule,
    );
  }
}
