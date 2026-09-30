/// Enumerations of spec v2.4 (Definitions). Labels are the ones shown to the
/// employee (SD-14, BR-19, §6).
library;

enum UserRole { employee, tester }

enum RequestStatus {
  pendingManagerApproval('PENDING_MANAGER_APPROVAL', 'Pending manager approval', isFinal: false),
  pendingHrEligibility('PENDING_HR_ELIGIBILITY', 'Pending HR eligibility check', isFinal: false),
  inProgress('IN_PROGRESS', 'In progress', isFinal: false),
  completed('COMPLETED', 'Completed', isFinal: true),
  rejectedByManager('REJECTED_BY_MANAGER', 'Rejected by Manager', isFinal: true),
  rejectedByHr('REJECTED_BY_HR', 'Rejected by HR', isFinal: true),
  failed('FAILED', 'Failed', isFinal: true);

  const RequestStatus(this.code, this.label, {required this.isFinal});

  final String code;
  final String label;
  final bool isFinal;

  static RequestStatus fromCode(String code) => values.firstWhere((s) => s.code == code);
}

/// Who a history entry is recorded by (SD-19).
enum Actor {
  employee('EMPLOYEE'),
  manager('MANAGER'),
  hr('HR'),
  payroll('PAYROLL'),
  it('IT'),
  facilities('FACILITIES'),
  system('SYSTEM');

  const Actor(this.code);
  final String code;

  static Actor fromCode(String code) => values.firstWhere((a) => a.code == code);
}

enum Outcome {
  approved('APPROVED'),
  rejected('REJECTED'),
  completed('COMPLETED'),
  failed('FAILED');

  const Outcome(this.code);
  final String code;

  static Outcome fromCode(String code) => values.firstWhere((o) => o.code == code);
}

/// Steps table (BRD-001 §3, §6). Declaration order is the table order, used
/// for the order of `STEP_SET` entries and of steps on screen.
enum StepId {
  managerApproval('MANAGER_APPROVAL', Actor.manager, 'Manager approval', 'Current manager'),
  hrEligibility('HR_ELIGIBILITY', Actor.hr, 'HR eligibility check', 'HR'),
  orgRecordUpdate('ORG_RECORD_UPDATE', Actor.hr, 'Organisational record update', 'HR'),
  payrollUpdate('PAYROLL_UPDATE', Actor.payroll, 'Payroll update', 'Payroll'),
  itAccessChange(
    'IT_ACCESS_CHANGE',
    Actor.it,
    'IT access change: provision new access, remove old access',
    'IT',
  ),
  facilitiesWorkspace(
    'FACILITIES_WORKSPACE',
    Actor.facilities,
    'Facilities: workspace at the new location',
    'Facilities',
  );

  const StepId(this.code, this.stakeholder, this.pendingAction, this.stakeholderLabel);

  final String code;
  final Actor stakeholder;
  final String pendingAction;
  final String stakeholderLabel;

  bool get isApproval => this == managerApproval || this == hrEligibility;

  /// Valid outcomes per step (OP06).
  List<Outcome> get validOutcomes =>
      isApproval ? const [Outcome.approved, Outcome.rejected] : const [Outcome.completed, Outcome.failed];

  static const downstream = [orgRecordUpdate, payrollUpdate, itAccessChange, facilitiesWorkspace];

  static StepId fromCode(String code) => values.firstWhere((s) => s.code == code);
}

enum StepState {
  pending('PENDING', 'Pending'),
  completed('COMPLETED', 'Completed'),
  rejected('REJECTED', 'Rejected'),
  failed('FAILED', 'Failed'),
  stopped('STOPPED', 'Stopped'),
  notRequired('NOT_REQUIRED', 'Not required');

  const StepState(this.code, this.label);
  final String code;
  final String label;

  static StepState fromCode(String code) => values.firstWhere((s) => s.code == code);
}

enum HistoryType {
  submitted('SUBMITTED'),
  stepOutcome('STEP_OUTCOME'),
  stepSet('STEP_SET'),
  statusChanged('STATUS_CHANGED'),
  changeScheduled('CHANGE_SCHEDULED');

  const HistoryType(this.code);
  final String code;

  static HistoryType fromCode(String code) => values.firstWhere((t) => t.code == code);
}
