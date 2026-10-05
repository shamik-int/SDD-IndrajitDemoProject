// Gate 2 G2-03 — `find` tells an absent record (success with null) apart from
// a failed read (error), on real Hive and on the in-memory store.

import 'package:flutter_test/flutter_test.dart';

import 'package:employee_transfer_project/core/local_db/in_memory_local_db_service.dart';
import 'package:employee_transfer_project/core/local_db/local_db_service.dart';

import '../../support/transfer_env.dart';

void main() {
  group('LocalDbService (real Hive)', () {
    final sandbox = HiveSandbox();
    setUp(sandbox.setUp);
    tearDown(sandbox.tearDown);

    test('find: absent → success(null); present → success(value)', () async {
      final db = LocalDbService();

      final absent = await db.find<Map>('box', 'k');
      expect(absent.isSuccess, isTrue);
      expect(absent.data, isNull);

      await db.write('box', 'k', {'a': 1});
      expect((await db.find<Map>('box', 'k')).data, {'a': 1});
    });
  });

  test('InMemoryLocalDbService.find: absent → success(null); present → a copy of the value', () async {
    final db = InMemoryLocalDbService();

    final absent = await db.find<Map>('box', 'k');
    expect(absent.isSuccess, isTrue);
    expect(absent.data, isNull);

    final value = {'list': [1]};
    await db.write('box', 'k', value);
    (value['list'] as List).add(2);
    expect((await db.find<Map>('box', 'k')).data, {'list': [1]});
  });
}
