"""G2-05 option (a): break the rule each XF scenario covers, run that XF test,
expect RED, restore. Files are always restored, even on error."""
import subprocess, sys

WF = 'lib/domain/transfer/workflow/transfer_workflow.dart'
REPO = 'lib/data/transfer/repositories/transfer_request_repository_impl.dart'
SB = 'lib/domain/transfer/workflow/schedule_book.dart'
LOCK = 'lib/core/concurrency/async_lock.dart'

M = [
    ('XF01', 'A downstream failure no longer stops the other pending steps (BR-16, AC17)', WF,
     'if (s.state == StepState.pending) builder.setStep(s.stepId, StepState.stopped);',
     'if (false) builder.setStep(s.stepId, StepState.stopped);'),
    ('XF02', 'A COMPLETED request awaiting effect no longer blocks a new one (SD-17, OP01 error 6)', WF,
     'if (active.awaitingEffect != null) {',
     'if (false && active.awaitingEffect != null) {'),
    ('XF03', 'OP06/OP07 no longer check the TESTER role (SD-18, AC32)', REPO,
     'if (!user.isTester) return Result.error(TransferMessages.testerOnly);',
     '// role check removed'),
    ('XF04', 'Status changes recorded with actor EMPLOYEE instead of SYSTEM (SD-19, AC23)', WF,
     '      actor: Actor.system,\n      type: HistoryType.statusChanged,',
     '      actor: Actor.employee,\n      type: HistoryType.statusChanged,'),
    ('XF05', 'A late-completed change applies retroactively from its effective date (SD-05)', SB,
     'LocalDate.isOnOrAfter(asOf, change.effectiveFrom) && LocalDate.isOnOrAfter(asOf, change.scheduledAt)',
     'LocalDate.isOnOrAfter(asOf, change.effectiveFrom)'),
    ('XF06', 'The lock no longer serialises operations (PD-04)', LOCK,
     'return previous.then((_) => action()).whenComplete(done.complete);',
     'done.complete(); return action();'),
    ('XF07', "OP04 reads every employee's ledger, not only the caller's (SD-04, AC22)", REPO,
     '    final ledger = await _ledger(access.data!.userId);\n    if (ledger.isError) return Result.error(ledger.message!);\n    final request = ledger.data!.request(requestId);',
     '    TransferRequest? request;\n    for (final l in (await ledgers.all()).data!) {\n      request ??= l.request(requestId);\n    }'),
    ('XF08', 'A FAILED request schedules the organisational change (SD-16, BR-16)', WF,
     '        builder.changeStatus(RequestStatus.failed);',
     '        builder.changeStatus(RequestStatus.failed);\n        schedule = ScheduleIntent(requestId: request.requestId, employeeId: request.employeeId, values: request.proposed, effectiveFrom: request.effectiveDate);'),
    ('XF09', 'A scheduled change takes effect before its effective date (BR-13)', SB,
     'LocalDate.isOnOrAfter(asOf, change.effectiveFrom) && LocalDate.isOnOrAfter(asOf, change.scheduledAt)',
     'LocalDate.isOnOrAfter(asOf, change.scheduledAt)'),
]

only = set(sys.argv[1:])
rows = []
for xf, rule, path, old, new in M:
    if only and xf not in only:
        continue
    original = open(path).read()
    assert original.count(old) == 1, (xf, 'mutation target not unique or missing')
    try:
        open(path, 'w').write(original.replace(old, new))
        out = subprocess.run(['flutter', 'test', 'test/integration/cross_flow_test.dart', '--plain-name', xf],
                             capture_output=True, text=True).stdout
        compiled = 'Compilation failed' not in out and 'Error: ' not in out
        red = 'Some tests failed' in out and compiled
        ran = [l.split(': ', 1)[-1] for l in out.splitlines() if '[E]' in l]
        rows.append((xf, rule, 'RED' if red else ('COMPILE ERROR' if not compiled else 'still GREEN'), '; '.join(ran)[:80] or '-'))
    finally:
        open(path, 'w').write(original)
    restored = open(path).read() == original
    after = subprocess.run(['flutter', 'test', 'test/integration/cross_flow_test.dart', '--plain-name', xf],
                           capture_output=True, text=True).stdout
    green = 'All tests passed' in after
    rows[-1] = rows[-1] + ('restored' if restored else 'NOT RESTORED', 'GREEN' if green else 'NOT GREEN')

for r in rows:
    print(' | '.join(r))
