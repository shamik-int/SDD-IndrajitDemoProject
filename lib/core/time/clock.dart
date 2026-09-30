import 'local_date.dart';

/// Source of the current time (plan PD-05). Injected everywhere a rule
/// depends on "today", so tests and the cross-flow scenarios (XF01–XF09) can
/// run on fixed dates.
abstract class Clock {
  const Clock();

  DateTime now();

  /// The device local date, with no time part.
  DateTime today() => LocalDate.dateOnly(now());
}

class SystemClock extends Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// A clock that only moves when told to. Used by tests; never registered in
/// the shipped app.
class AdjustableClock extends Clock {
  DateTime _now;

  AdjustableClock(this._now);

  @override
  DateTime now() => _now;

  void set(DateTime value) => _now = value;

  void advance(Duration by) => _now = _now.add(by);
}
