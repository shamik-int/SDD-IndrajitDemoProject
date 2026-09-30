import 'package:equatable/equatable.dart';

import '../../../core/time/local_date.dart';
import '../../../domain/transfer/entities/enums.dart';
import '../../../domain/transfer/entities/transfer_request.dart';
import '../../../domain/transfer/portal/portal_contracts.dart';

class Confirmation extends Equatable {
  final String title;
  final List<String> lines;

  const Confirmation(this.title, this.lines);

  @override
  List<Object?> get props => [title, lines];
}

/// Confirmation for each final outcome (AC20, BRD-001 §7). Pure, so the
/// wording is tested without widgets (UT32).
class ConfirmationBuilder {
  ConfirmationBuilder._();

  static const _mayResubmit = 'You may submit a new request.';

  static String _names(Iterable<StepId> steps) => steps.map((s) => s.pendingAction).join(', ');

  static Confirmation? build(TransferRequest r, {required DateTime today, required ReferenceLists refs}) {
    switch (r.status) {
      case RequestStatus.completed:
        final p = r.proposed;
        final closed = r.closedAt ?? today;
        final lines = [
          'New department: ${refs.departmentName(p.departmentId)}, location: ${refs.locationName(p.locationId)}, '
              'role: ${refs.roleName(p.roleId)}.',
          'Effective from ${LocalDate.format(r.effectiveDate)}.',
          'Completed steps: ${_names(r.steps.where((s) => s.state == StepState.completed).map((s) => s.stepId))}.',
          if (LocalDate.isOnOrAfter(closed, r.effectiveDate))
            'This date had passed when your transfer completed, so the new values show in your profile from '
                '${LocalDate.format(closed)}.',
          r.isAwaitingEffect(today)
              ? 'You can submit a new request from ${LocalDate.format(r.effectiveDate)}.'
              : _mayResubmit,
        ];
        return Confirmation('Transfer confirmed', lines);
      case RequestStatus.rejectedByManager:
        return Confirmation('Not approved by your manager', _rejected(r, StepId.managerApproval));
      case RequestStatus.rejectedByHr:
        return Confirmation('Not approved by HR', _rejected(r, StepId.hrEligibility));
      case RequestStatus.failed:
        Iterable<StepId> where(StepState state) =>
            r.steps.where((s) => s.state == state && StepId.downstream.contains(s.stepId)).map((s) => s.stepId);
        final stopped = where(StepState.stopped);
        final done = where(StepState.completed);
        return Confirmation('Transfer failed', [
          'Failed step: ${_names(where(StepState.failed))}.',
          if (done.isNotEmpty) 'Completed steps (not undone): ${_names(done)}.',
          if (stopped.isNotEmpty) 'Stopped steps: ${_names(stopped)}.',
          'Your department, location and role have not changed.',
          _mayResubmit,
        ]);
      case RequestStatus.pendingManagerApproval:
      case RequestStatus.pendingHrEligibility:
      case RequestStatus.inProgress:
        return null;
    }
  }

  static List<String> _rejected(TransferRequest r, StepId step) => [
        'Reason: ${r.step(step)?.reason ?? ''}',
        'No further steps were taken.',
        _mayResubmit,
      ];
}
