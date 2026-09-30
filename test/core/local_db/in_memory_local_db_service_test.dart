// employee-internal-transfer.T01 — in-memory LocalDbService used by widget tests,
// because real Hive I/O does not settle under testWidgets (see test/widget_test.dart).

import 'package:flutter_test/flutter_test.dart';

import 'package:employee_transfer_project/core/local_db/in_memory_local_db_service.dart';

void main() {
  test('read, write, readAll, delete and clearBox behave like LocalDbService', () async {
    final db = InMemoryLocalDbService();

    expect((await db.read<Map>('box', 'k')).isError, isTrue);

    await db.write('box', 'k', {'a': 1});
    await db.write('box', 'k2', {'a': 2});
    expect((await db.read<Map>('box', 'k')).data, {'a': 1});
    expect((await db.readAll('box')).data!.length, 2);

    await db.delete('box', 'k');
    expect((await db.read<Map>('box', 'k')).isError, isTrue);

    await db.clearBox('box');
    expect((await db.readAll('box')).data, isEmpty);
  });

  test('stored maps are copied, so callers cannot mutate saved data in place', () async {
    final db = InMemoryLocalDbService();
    final value = {'list': [1]};
    await db.write('box', 'k', value);
    (value['list'] as List).add(2);

    expect((await db.read<Map>('box', 'k')).data, {'list': [1]});
  });
}
