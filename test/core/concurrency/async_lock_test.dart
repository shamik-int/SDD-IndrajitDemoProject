// employee-internal-transfer.T01 — PD-04: read-modify-write cycles never interleave (XF06).

import 'package:flutter_test/flutter_test.dart';

import 'package:employee_transfer_project/core/concurrency/async_lock.dart';

void main() {
  test('runs critical sections one at a time, in call order', () async {
    final lock = AsyncLock();
    final events = <String>[];

    Future<void> section(String name) => lock.synchronized(() async {
          events.add('$name:start');
          await Future<void>.delayed(const Duration(milliseconds: 5));
          events.add('$name:end');
        });

    await Future.wait([section('a'), section('b'), section('c')]);

    expect(events, ['a:start', 'a:end', 'b:start', 'b:end', 'c:start', 'c:end']);
  });

  test('returns the section value, and a thrown error does not block the next caller', () async {
    final lock = AsyncLock();

    await expectLater(lock.synchronized<int>(() async => throw StateError('x')), throwsStateError);
    expect(await lock.synchronized(() async => 42), 42);
  });
}
