import 'package:equatable/equatable.dart';

import 'org_values.dart';

/// D-02 `ScheduledChange` (BR-13, SD-16, SD-20). At most one per request.
class ScheduledChange extends Equatable {
  final String requestId;
  final String employeeId;
  final OrgValues values;
  final DateTime effectiveFrom; // date only
  final DateTime scheduledAt;

  const ScheduledChange({
    required this.requestId,
    required this.employeeId,
    required this.values,
    required this.effectiveFrom,
    required this.scheduledAt,
  });

  @override
  List<Object?> get props => [requestId, employeeId, values, effectiveFrom, scheduledAt];
}
