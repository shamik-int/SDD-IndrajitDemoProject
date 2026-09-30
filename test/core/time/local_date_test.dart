// employee-internal-transfer.T01 — PD-05 (device local dates, stored without time).

import 'package:flutter_test/flutter_test.dart';

import 'package:employee_transfer_project/core/time/clock.dart';
import 'package:employee_transfer_project/core/time/local_date.dart';

void main() {
  group('LocalDate helpers', () {
    test('dateOnly strips the time of day', () {
      expect(LocalDate.dateOnly(DateTime(2026, 10, 15, 23, 59, 30)), DateTime(2026, 10, 15));
    });

    test('toIso / parseIso round-trip a date as yyyy-MM-dd', () {
      final iso = LocalDate.toIso(DateTime(2026, 3, 7, 18, 0));
      expect(iso, '2026-03-07');
      expect(LocalDate.parseIso(iso), DateTime(2026, 3, 7));
    });

    test('format renders d MMM yyyy (PD-10, e.g. UT64 "15 Oct 2026")', () {
      expect(LocalDate.format(DateTime(2026, 10, 15)), '15 Oct 2026');
      expect(LocalDate.format(DateTime(2026, 10, 1)), '1 Oct 2026');
    });

    test('isBefore / isOnOrAfter compare dates only', () {
      final a = DateTime(2026, 10, 15, 23);
      final b = DateTime(2026, 10, 15, 1);
      expect(LocalDate.isBefore(a, b), isFalse);
      expect(LocalDate.isOnOrAfter(a, b), isTrue);
      expect(LocalDate.isBefore(DateTime(2026, 10, 14), b), isTrue);
    });
  });

  group('Clock', () {
    test('AdjustableClock returns the set time; today() drops the time', () {
      final clock = AdjustableClock(DateTime(2026, 10, 1, 9, 30));
      expect(clock.now(), DateTime(2026, 10, 1, 9, 30));
      expect(clock.today(), DateTime(2026, 10, 1));

      clock.set(DateTime(2026, 10, 15, 8));
      expect(clock.today(), DateTime(2026, 10, 15));
    });

    test('AdjustableClock.advance moves time forward', () {
      final clock = AdjustableClock(DateTime(2026, 10, 1, 9));
      clock.advance(const Duration(minutes: 5));
      expect(clock.now(), DateTime(2026, 10, 1, 9, 5));
    });

    test('SystemClock.today() has no time part', () {
      final today = const SystemClock().today();
      expect(today, LocalDate.dateOnly(today));
    });
  });
}
