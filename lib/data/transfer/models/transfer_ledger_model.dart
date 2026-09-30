import '../../../core/time/local_date.dart';
import '../../../domain/transfer/entities/enums.dart';
import '../../../domain/transfer/entities/history_entry.dart';
import '../../../domain/transfer/entities/org_values.dart';
import '../../../domain/transfer/entities/scheduled_change.dart';
import '../../../domain/transfer/entities/stakeholder_task.dart';
import '../../../domain/transfer/entities/transfer_ledger.dart';
import '../../../domain/transfer/entities/transfer_request.dart';
import '../../../domain/transfer/entities/transfer_step.dart';

/// Plain-map serialisation of [TransferLedger] for Hive (ADR-0006). Date-only
/// values are `yyyy-MM-dd`; timestamps are local ISO-8601 (plan PD-05).
class TransferLedgerModel {
  TransferLedgerModel._();

  static Map<String, dynamic> toMap(TransferLedger ledger) => {
        'employeeId': ledger.employeeId,
        'requests': [for (final r in ledger.requests) _request(r)],
        'scheduledChanges': [for (final c in ledger.scheduledChanges) scheduledChangeToMap(c)],
      };

  static TransferLedger fromMap(Map<dynamic, dynamic> map) => TransferLedger(
        employeeId: map['employeeId'] as String,
        requests: [for (final r in map['requests'] as List) _requestFrom(r as Map)],
        scheduledChanges: [for (final c in map['scheduledChanges'] as List) scheduledChangeFromMap(c as Map)],
      );

  static Map<String, dynamic> _values(OrgValues v) =>
      {'departmentId': v.departmentId, 'locationId': v.locationId, 'roleId': v.roleId};

  static OrgValues _valuesFrom(Map m) => OrgValues(
        departmentId: m['departmentId'] as String,
        locationId: m['locationId'] as String,
        roleId: m['roleId'] as String,
      );

  static String? _ts(DateTime? t) => t?.toIso8601String();
  static DateTime? _tsFrom(Object? s) => s == null ? null : DateTime.parse(s as String);
  static String? _date(DateTime? d) => d == null ? null : LocalDate.toIso(d);
  static DateTime? _dateFrom(Object? s) => s == null ? null : LocalDate.parseIso(s as String);

  static Map<String, dynamic> scheduledChangeToMap(ScheduledChange c) => {
        'requestId': c.requestId,
        'employeeId': c.employeeId,
        'values': _values(c.values),
        'effectiveFrom': _date(c.effectiveFrom),
        'scheduledAt': _ts(c.scheduledAt),
      };

  static ScheduledChange scheduledChangeFromMap(Map m) => ScheduledChange(
        requestId: m['requestId'] as String,
        employeeId: m['employeeId'] as String,
        values: _valuesFrom(m['values'] as Map),
        effectiveFrom: _dateFrom(m['effectiveFrom'])!,
        scheduledAt: _tsFrom(m['scheduledAt'])!,
      );

  static Map<String, dynamic> _request(TransferRequest r) => {
        'requestId': r.requestId,
        'employeeId': r.employeeId,
        'employeeName': r.employeeName,
        'submissionId': r.submissionId,
        'current': {..._values(r.current.values), 'managerName': r.current.managerName},
        'proposed': _values(r.proposed),
        'effectiveDate': _date(r.effectiveDate),
        'reason': r.reason,
        'submittedAt': _ts(r.submittedAt),
        'status': r.status.code,
        'steps': [for (final s in r.steps) _step(s)],
        'history': [for (final e in r.history) _entry(e)],
      };

  static TransferRequest _requestFrom(Map m) {
    final current = m['current'] as Map;
    return TransferRequest(
      requestId: m['requestId'] as String,
      employeeId: m['employeeId'] as String,
      employeeName: m['employeeName'] as String,
      submissionId: m['submissionId'] as String,
      current: EmployeeCurrentValues(values: _valuesFrom(current), managerName: current['managerName'] as String),
      proposed: _valuesFrom(m['proposed'] as Map),
      effectiveDate: _dateFrom(m['effectiveDate'])!,
      reason: m['reason'] as String?,
      submittedAt: _tsFrom(m['submittedAt'])!,
      status: RequestStatus.fromCode(m['status'] as String),
      steps: [for (final s in m['steps'] as List) _stepFrom(s as Map)],
      history: [for (final e in m['history'] as List) _entryFrom(e as Map)],
    );
  }

  static Map<String, dynamic> _step(TransferStep s) => {
        'stepId': s.stepId.code,
        'state': s.state.code,
        'decision': s.decision?.code,
        'reason': s.reason,
        'recordedAt': _ts(s.recordedAt),
        'task': s.task == null ? null : _task(s.task!),
      };

  static TransferStep _stepFrom(Map m) => TransferStep(
        stepId: StepId.fromCode(m['stepId'] as String),
        state: StepState.fromCode(m['state'] as String),
        decision: m['decision'] == null ? null : Outcome.fromCode(m['decision'] as String),
        reason: m['reason'] as String?,
        recordedAt: _tsFrom(m['recordedAt']),
        task: m['task'] == null ? null : _taskFrom(m['task'] as Map),
      );

  static Map<String, dynamic> _task(StakeholderTask t) => {
        'taskId': t.taskId,
        'requestId': t.requestId,
        'stepId': t.stepId.code,
        'employeeId': t.employeeId,
        'employeeName': t.employeeName,
        'effectiveDate': _date(t.effectiveDate),
        'payload': t.payload,
        'createdAt': _ts(t.createdAt),
      };

  static StakeholderTask _taskFrom(Map m) => StakeholderTask(
        taskId: m['taskId'] as String,
        requestId: m['requestId'] as String,
        stepId: StepId.fromCode(m['stepId'] as String),
        employeeId: m['employeeId'] as String,
        employeeName: m['employeeName'] as String,
        effectiveDate: _dateFrom(m['effectiveDate'])!,
        payload: (m['payload'] as Map).map((k, v) => MapEntry(k as String, v as String)),
        createdAt: _tsFrom(m['createdAt'])!,
      );

  static Map<String, dynamic> _entry(HistoryEntry e) => {
        'sequence': e.sequence,
        'recordedAt': _ts(e.recordedAt),
        'actor': e.actor.code,
        'type': e.type.code,
        'stepId': e.stepId?.code,
        'outcome': e.outcome?.code,
        'reason': e.reason,
        'toState': e.toState?.code,
        'fromStatus': e.fromStatus?.code,
        'toStatus': e.toStatus?.code,
        'effectiveFrom': _date(e.effectiveFrom),
        'simulatedBy': e.simulatedBy,
      };

  static HistoryEntry _entryFrom(Map m) => HistoryEntry(
        sequence: m['sequence'] as int,
        recordedAt: _tsFrom(m['recordedAt'])!,
        actor: Actor.fromCode(m['actor'] as String),
        type: HistoryType.fromCode(m['type'] as String),
        stepId: m['stepId'] == null ? null : StepId.fromCode(m['stepId'] as String),
        outcome: m['outcome'] == null ? null : Outcome.fromCode(m['outcome'] as String),
        reason: m['reason'] as String?,
        toState: m['toState'] == null ? null : StepState.fromCode(m['toState'] as String),
        fromStatus: m['fromStatus'] == null ? null : RequestStatus.fromCode(m['fromStatus'] as String),
        toStatus: m['toStatus'] == null ? null : RequestStatus.fromCode(m['toStatus'] as String),
        effectiveFrom: _dateFrom(m['effectiveFrom']),
        simulatedBy: m['simulatedBy'] as String?,
      );
}
