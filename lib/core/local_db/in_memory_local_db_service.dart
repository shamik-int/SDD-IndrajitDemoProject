import '../result/result.dart';
import 'local_db_service.dart';

/// Same contract as [LocalDbService], held in memory. Used by widget tests,
/// where real Hive file I/O does not settle under `testWidgets`. Values are
/// deep-copied on the way in and out, as a real store would behave.
class InMemoryLocalDbService extends LocalDbService {
  final Map<String, Map<String, dynamic>> _boxes = {};

  Map<String, dynamic> _box(String name) => _boxes.putIfAbsent(name, () => {});

  static dynamic _copy(dynamic value) {
    if (value is Map) return {for (final e in value.entries) e.key: _copy(e.value)};
    if (value is List) return [for (final v in value) _copy(v)];
    return value;
  }

  @override
  Future<Result<T>> read<T>(String boxName, String key) async {
    final value = _box(boxName)[key];
    if (value == null) return Result.error('No local record found for "$key".');
    return Result.success(_copy(value) as T);
  }

  @override
  Future<Result<bool>> write(String boxName, String key, dynamic value) async {
    _box(boxName)[key] = _copy(value);
    return Result.success(true);
  }

  @override
  Future<Result<bool>> delete(String boxName, String key) async {
    _box(boxName).remove(key);
    return Result.success(true);
  }

  @override
  Future<Result<Map<dynamic, dynamic>>> readAll(String boxName) async {
    return Result.success(_copy(_box(boxName)) as Map<dynamic, dynamic>);
  }

  @override
  Future<Result<bool>> clearBox(String boxName) async {
    _box(boxName).clear();
    return Result.success(true);
  }
}
