import 'package:uuid/uuid.dart';

import '../../core/result/result.dart';
import '../../domain/entities/stakeholder.dart';
import '../../domain/entities/stakeholder_decision.dart';
import '../../domain/entities/stakeholder_state.dart';
import '../../domain/entities/submit_transfer_request_input.dart';
import '../../domain/entities/transfer_request.dart';
import '../../domain/entities/transfer_request_status.dart';
import '../../domain/repositories/transfer_request_repository.dart';
import '../datasources/local/transfer_request_local_datasource.dart';

/// Implements the spec's Local Data Contract (OP01–OP04) over Hive
/// (ADR-0004 — Hive is the system of record, not a cache). Owns field
/// validation, the single-in-flight-request rule, and the full state
/// machine — the datasource itself is raw CRUD only.
class TransferRequestRepositoryImpl implements TransferRequestRepository {
  final TransferRequestLocalDataSource dataSource;
  final Uuid _uuid;

  TransferRequestRepositoryImpl(this.dataSource, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  static const _downstreamStakeholders = {
    Stakeholder.payroll,
    Stakeholder.it,
    Stakeholder.facilities,
  };

  @override
  Future<Result<TransferRequest>> submit(SubmitTransferRequestInput input) async {
    final validationError = _validate(input);
    if (validationError != null) return Result.error(validationError);

    final activeId = await dataSource.getActiveRequestId();
    if (activeId != null) {
      return Result.error('You already have a transfer request in progress.');
    }

    final now = DateTime.now();
    final request = TransferRequest(
      id: _uuid.v4(),
      departmentId: input.departmentId,
      locationId: input.locationId,
      roleId: input.roleId,
      effectiveDate: input.effectiveDate,
      reason: input.reason,
      status: TransferRequestStatus.pendingManagerApproval,
      stakeholders: const {Stakeholder.manager: StakeholderState.pending},
      submittedAt: now,
      updatedAt: now,
    );

    final saveResult = await dataSource.saveRequest(request);
    if (saveResult.isError) {
      return Result.error(saveResult.message ?? 'Failed to save request.');
    }
    await dataSource.setActiveRequestId(request.id);

    return Result.success(request);
  }

  String? _validate(SubmitTransferRequestInput input) {
    if (input.departmentId.trim().isEmpty) return 'Department is required.';
    if (input.locationId.trim().isEmpty) return 'Location is required.';
    if (input.roleId.trim().isEmpty) return 'Role is required.';
    if (!input.effectiveDate.isAfter(DateTime.now())) {
      return 'Effective date must be in the future.';
    }
    return null;
  }

  @override
  Future<Result<TransferRequest>> getById(String requestId) {
    return dataSource.getRequestById(requestId);
  }

  @override
  Future<Result<TransferRequest?>> getActive() async {
    final activeId = await dataSource.getActiveRequestId();
    if (activeId == null) return Result.success(null);

    final result = await dataSource.getRequestById(activeId);
    // A dangling pointer (the record disappeared but app_state didn't) is
    // treated as "no active request" rather than surfaced as an error.
    if (result.isError) return Result.success(null);
    return Result.success(result.data);
  }

  @override
  Future<Result<TransferRequest>> recordStakeholderDecision({
    required String requestId,
    required Stakeholder stakeholder,
    required StakeholderDecision decision,
  }) async {
    final existingResult = await dataSource.getRequestById(requestId);
    if (existingResult.isError) {
      return Result.error(existingResult.message ?? 'No request found for this ID.');
    }

    final transition = _nextState(existingResult.data!, stakeholder, decision);
    if (transition == null) {
      return Result.error("Invalid decision for the request's current state.");
    }

    final updated = existingResult.data!.copyWith(
      status: transition.status,
      stakeholders: transition.stakeholders,
      updatedAt: DateTime.now(),
    );

    await dataSource.saveRequest(updated);
    if (updated.status.isTerminal) {
      await dataSource.setActiveRequestId(null);
    }

    return Result.success(updated);
  }

  _Transition? _nextState(
    TransferRequest existing,
    Stakeholder stakeholder,
    StakeholderDecision decision,
  ) {
    switch (existing.status) {
      case TransferRequestStatus.pendingManagerApproval:
        if (stakeholder != Stakeholder.manager) return null;
        if (decision == StakeholderDecision.approved) {
          return _Transition(TransferRequestStatus.pendingHrValidation, {
            ...existing.stakeholders,
            Stakeholder.manager: StakeholderState.approved,
            Stakeholder.hr: StakeholderState.pending,
          });
        }
        if (decision == StakeholderDecision.rejected) {
          return _Transition(TransferRequestStatus.rejectedByManager, {
            ...existing.stakeholders,
            Stakeholder.manager: StakeholderState.rejected,
          });
        }
        return null;

      case TransferRequestStatus.pendingHrValidation:
        if (stakeholder != Stakeholder.hr) return null;
        if (decision == StakeholderDecision.approved) {
          return _Transition(TransferRequestStatus.pendingDownstreamUpdates, {
            ...existing.stakeholders,
            Stakeholder.hr: StakeholderState.approved,
            Stakeholder.payroll: StakeholderState.pending,
            Stakeholder.it: StakeholderState.pending,
            Stakeholder.facilities: StakeholderState.pending,
          });
        }
        if (decision == StakeholderDecision.rejected) {
          return _Transition(TransferRequestStatus.rejectedByHr, {
            ...existing.stakeholders,
            Stakeholder.hr: StakeholderState.rejected,
          });
        }
        return null;

      case TransferRequestStatus.pendingDownstreamUpdates:
        if (!_downstreamStakeholders.contains(stakeholder)) return null;
        if (decision != StakeholderDecision.completed) return null;
        if (existing.stakeholders[stakeholder] != StakeholderState.pending) return null;

        final updatedStakeholders = {
          ...existing.stakeholders,
          stakeholder: StakeholderState.completed,
        };
        final allDownstreamDone = _downstreamStakeholders.every(
          (s) => updatedStakeholders[s] == StakeholderState.completed,
        );

        return _Transition(
          allDownstreamDone
              ? TransferRequestStatus.completed
              : TransferRequestStatus.pendingDownstreamUpdates,
          updatedStakeholders,
        );

      case TransferRequestStatus.completed:
      case TransferRequestStatus.rejectedByManager:
      case TransferRequestStatus.rejectedByHr:
        return null; // terminal — no further decisions are ever valid
    }
  }
}

class _Transition {
  final TransferRequestStatus status;
  final Map<Stakeholder, StakeholderState> stakeholders;

  const _Transition(this.status, this.stakeholders);
}
