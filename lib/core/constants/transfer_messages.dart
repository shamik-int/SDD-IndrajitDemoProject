import '../time/local_date.dart';

/// Every user-facing message of `employee-internal-transfer`, copied verbatim
/// from spec v2.4 (plan PD-10). Repository, screens and tests all read from
/// here so the wording cannot drift.
class TransferMessages {
  TransferMessages._();

  // Access rules
  static const pleaseSignIn = 'Please sign in.';
  static const employeesOnly = 'This action is for employees only.';
  static const testerOnly = 'Only a demo tester can record stakeholder outcomes.';

  // OP01 errors
  static const selectDepartment = 'Select a department.';
  static const selectLocation = 'Select a location.';
  static const selectRole = 'Select a role.';
  static const enterEffectiveDate = 'Enter an effective date.';
  static const effectiveDateInFuture = 'Effective date must be in the future.';
  static const changeAtLeastOne = 'Change at least one of department, location or role.';
  static const alreadyInProgress = 'You already have a transfer request in progress.';
  static String awaitingEffect(DateTime effectiveDate) =>
      'Your previous transfer takes effect on ${LocalDate.format(effectiveDate)}. '
      'You can submit a new request from that date.';
  static const reasonTooLong = 'Reason must be 500 characters or fewer.';

  // OP04 / OP05 / OP06
  static const noRequestFound = 'No request found.';
  static const requestClosed = 'This request is already closed.';
  static const stepNotPending = 'This step is not pending.';
  static const outcomeNotValid = 'This outcome is not valid for this step.';
  static const rejectionReasonRequired = 'A rejection reason is required.';

  // scheduleOrganisationalChange (SD-20)
  static const differentChangeScheduled = 'A different change is already scheduled for this request.';
  static const anotherTransferScheduled = 'Another transfer is already scheduled for this employee.';

  // Screens
  static const demoIndicator = 'Demo — test data only';
  static const simulationTitle = 'Demo only: simulate stakeholder outcome';
  static const effectiveDatePassedMark = 'Effective date passed';
  static String effectiveDatePassedNote(DateTime effectiveDate) =>
      'The effective date (${LocalDate.format(effectiveDate)}) has passed. '
      'Your request continues and the date is not changed. If it completes, '
      'your new department, location and role will show from the day it completes.';
  static String completedAwaitingEffect(DateTime effectiveDate) =>
      'Completed: takes effect on ${LocalDate.format(effectiveDate)}';
  static const requestSubmitted = 'Your transfer request was submitted.';
  static const invalidCredentials = 'Invalid email or password.';

  // Not in spec v2.4: storage failures during sign-in and sign-out (Gate 2
  // G2-09). Wording awaiting confirmation by the spec owner.
  static const signInFailed = 'Could not sign you in. Please try again.';
  static const signOutFailed = 'Could not sign you out. Please try again.';

  static const maxReasonLength = 500;
}
