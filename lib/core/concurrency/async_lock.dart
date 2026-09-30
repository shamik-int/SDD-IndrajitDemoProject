import 'dart:async';

/// Serialises asynchronous critical sections (plan PD-04). Each
/// state-changing operation reads a ledger, changes it and writes it back;
/// without this lock two quick taps could both read the old ledger (XF06).
class AsyncLock {
  Future<void> _last = Future.value();

  Future<T> synchronized<T>(Future<T> Function() action) {
    final previous = _last;
    final done = Completer<void>();
    _last = done.future;

    return previous.then((_) => action()).whenComplete(done.complete);
  }
}
