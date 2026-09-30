import 'package:equatable/equatable.dart';

import 'scheduled_change.dart';
import 'transfer_request.dart';

/// One employee's stored record (plan PD-04, ADR-0006): all their requests
/// (with steps, tasks and history) and their scheduled organisational
/// changes. Saved with a single write, so every operation is atomic.
class TransferLedger extends Equatable {
  final String employeeId;
  final List<TransferRequest> requests;
  final List<ScheduledChange> scheduledChanges;

  const TransferLedger({required this.employeeId, required this.requests, required this.scheduledChanges});

  factory TransferLedger.empty(String employeeId) =>
      TransferLedger(employeeId: employeeId, requests: const [], scheduledChanges: const []);

  TransferRequest? request(String requestId) {
    for (final r in requests) {
      if (r.requestId == requestId) return r;
    }
    return null;
  }

  TransferLedger withRequest(TransferRequest request) {
    final exists = requests.any((r) => r.requestId == request.requestId);
    return TransferLedger(
      employeeId: employeeId,
      requests: exists
          ? [for (final r in requests) r.requestId == request.requestId ? request : r]
          : [...requests, request],
      scheduledChanges: scheduledChanges,
    );
  }

  TransferLedger withScheduledChanges(List<ScheduledChange> changes) =>
      TransferLedger(employeeId: employeeId, requests: requests, scheduledChanges: changes);

  @override
  List<Object?> get props => [employeeId, requests, scheduledChanges];
}
