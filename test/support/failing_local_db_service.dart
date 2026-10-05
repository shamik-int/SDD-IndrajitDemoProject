// In-memory store whose reads, writes and deletes can be made to fail per box,
// and which records every write. Used for the storage-failure paths (G2-03,
// G2-09).

import 'package:employee_transfer_project/core/local_db/in_memory_local_db_service.dart';
import 'package:employee_transfer_project/core/result/result.dart';

class FailingLocalDbService extends InMemoryLocalDbService {
  static const readFailure = 'Local read failed: simulated';
  static const writeFailure = 'Local write failed: simulated';
  static const deleteFailure = 'Local delete failed: simulated';

  /// Boxes whose reads currently fail.
  final Set<String> failReadsOn = {};

  /// Boxes whose writes currently fail.
  final Set<String> failWritesOn = {};

  /// Boxes whose deletes currently fail.
  final Set<String> failDeletesOn = {};

  /// Box name of every write, in order.
  final List<String> writes = [];

  @override
  Future<Result<T>> read<T>(String boxName, String key) async =>
      failReadsOn.contains(boxName) ? Result.error(readFailure) : super.read<T>(boxName, key);

  @override
  Future<Result<T?>> find<T>(String boxName, String key) async =>
      failReadsOn.contains(boxName) ? Result.error(readFailure) : super.find<T>(boxName, key);

  @override
  Future<Result<Map<dynamic, dynamic>>> readAll(String boxName) async =>
      failReadsOn.contains(boxName) ? Result.error(readFailure) : super.readAll(boxName);

  @override
  Future<Result<bool>> write(String boxName, String key, dynamic value) {
    writes.add(boxName);
    if (failWritesOn.contains(boxName)) return Future.value(Result.error(writeFailure));
    return super.write(boxName, key, value);
  }

  @override
  Future<Result<bool>> delete(String boxName, String key) async =>
      failDeletesOn.contains(boxName) ? Result.error(deleteFailure) : super.delete(boxName, key);
}
