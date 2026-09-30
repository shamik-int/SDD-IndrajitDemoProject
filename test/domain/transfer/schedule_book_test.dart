// employee-internal-transfer.T03 — ScheduleBook: SD-20 table (UT60–UT62, pure)
// and the D-02 current-values rule, including "never retroactively" (SD-05).

import 'package:flutter_test/flutter_test.dart';

import 'package:employee_transfer_project/core/constants/transfer_messages.dart';
import 'package:employee_transfer_project/domain/transfer/entities/org_values.dart';
import 'package:employee_transfer_project/domain/transfer/workflow/schedule_book.dart';

import '../../support/transfer_fixtures.dart';

void main() {
  final newValues = changing(role: true);
  final oct1 = DateTime(2026, 10, 1, 10);
  final oct15 = DateTime(2026, 10, 15);

  group('schedule (SD-20)', () {
    test('first call for a requestId schedules one change', () {
      final result = ScheduleBook.schedule(const [],
          employeeId: 'emp-a', requestId: 'r1', values: newValues, effectiveFrom: oct15, now: oct1);

      expect(result.isSuccess, isTrue);
      expect(result.data!.created, isTrue);
      expect(result.data!.changes, hasLength(1));
      expect(result.data!.change.scheduledAt, oct1);
      expect(result.data!.change.effectiveFrom, oct15);
    });

    test('UT60: repeat call, same requestId and values, returns the existing change', () {
      final first = ScheduleBook.schedule(const [],
          employeeId: 'emp-a', requestId: 'r1', values: newValues, effectiveFrom: oct15, now: oct1);
      final second = ScheduleBook.schedule(first.data!.changes,
          employeeId: 'emp-a', requestId: 'r1', values: newValues, effectiveFrom: oct15, now: oct1.add(const Duration(hours: 1)));

      expect(second.isSuccess, isTrue);
      expect(second.data!.created, isFalse);
      expect(second.data!.change.scheduledAt, oct1);
      expect(second.data!.changes, hasLength(1));
    });

    test('UT61: same requestId, different values → error; original kept', () {
      final first = ScheduleBook.schedule(const [],
          employeeId: 'emp-a', requestId: 'r1', values: newValues, effectiveFrom: oct15, now: oct1);
      final other = ScheduleBook.schedule(first.data!.changes,
          employeeId: 'emp-a', requestId: 'r1', values: changing(location: true), effectiveFrom: oct15, now: oct1);
      final otherDate = ScheduleBook.schedule(first.data!.changes,
          employeeId: 'emp-a', requestId: 'r1', values: newValues, effectiveFrom: DateTime(2026, 10, 16), now: oct1);

      expect(other.message, TransferMessages.differentChangeScheduled);
      expect(otherDate.message, TransferMessages.differentChangeScheduled);
    });

    test('UT62: another requestId while a change has not taken effect → error', () {
      final first = ScheduleBook.schedule(const [],
          employeeId: 'emp-a', requestId: 'r1', values: newValues, effectiveFrom: oct15, now: oct1);
      final second = ScheduleBook.schedule(first.data!.changes,
          employeeId: 'emp-a', requestId: 'r2', values: newValues, effectiveFrom: DateTime(2026, 10, 30), now: oct1);

      expect(second.message, TransferMessages.anotherTransferScheduled);
    });

    test('another requestId once the earlier change has taken effect is accepted', () {
      final first = ScheduleBook.schedule(const [],
          employeeId: 'emp-a', requestId: 'r1', values: newValues, effectiveFrom: oct15, now: oct1);
      final second = ScheduleBook.schedule(first.data!.changes,
          employeeId: 'emp-a', requestId: 'r2', values: changing(location: true),
          effectiveFrom: DateTime(2026, 10, 30), now: DateTime(2026, 10, 15, 9));

      expect(second.isSuccess, isTrue);
      expect(second.data!.changes, hasLength(2));
    });
  });

  group('pending and current values (D-02)', () {
    final change = ScheduleBook.schedule(const [],
            employeeId: 'emp-a', requestId: 'r1', values: newValues, effectiveFrom: oct15, now: oct1)
        .data!
        .changes;

    test('pending only while asOf is before effectiveFrom', () {
      expect(ScheduleBook.pending(change, DateTime(2026, 10, 14)), isNotNull);
      expect(ScheduleBook.pending(change, oct15), isNull);
    });

    test('UT21 (pure): previous values before the effective date, new values from it', () {
      expect(ScheduleBook.currentValues(baseCurrent, change, DateTime(2026, 10, 14)).values, baseValues);
      expect(ScheduleBook.currentValues(baseCurrent, change, oct15).values, newValues);
      expect(ScheduleBook.currentValues(baseCurrent, change, oct15).managerName, baseCurrent.managerName);
    });

    test('SD-05: a change scheduled after its effective date shows from the scheduling day, never before', () {
      final late = ScheduleBook.schedule(const [],
              employeeId: 'emp-a', requestId: 'r1', values: newValues,
              effectiveFrom: DateTime(2026, 10, 10), now: DateTime(2026, 10, 14, 16))
          .data!
          .changes;

      expect(ScheduleBook.currentValues(baseCurrent, late, DateTime(2026, 10, 12)).values, baseValues);
      expect(ScheduleBook.currentValues(baseCurrent, late, DateTime(2026, 10, 13)).values, baseValues);
      expect(ScheduleBook.currentValues(baseCurrent, late, DateTime(2026, 10, 14)).values, newValues);
    });

    test('two changes over time apply in order', () {
      final first = ScheduleBook.schedule(const [],
              employeeId: 'emp-a', requestId: 'r1', values: newValues, effectiveFrom: oct15, now: oct1)
          .data!
          .changes;
      const second = OrgValues(departmentId: 'dept-fin', locationId: 'loc-pun', roleId: 'role-tl');
      final both = ScheduleBook.schedule(first,
              employeeId: 'emp-a', requestId: 'r2', values: second,
              effectiveFrom: DateTime(2026, 10, 30), now: DateTime(2026, 10, 16))
          .data!
          .changes;

      expect(ScheduleBook.currentValues(baseCurrent, both, DateTime(2026, 10, 20)).values, newValues);
      expect(ScheduleBook.currentValues(baseCurrent, both, DateTime(2026, 10, 30)).values, second);
    });
  });
}
