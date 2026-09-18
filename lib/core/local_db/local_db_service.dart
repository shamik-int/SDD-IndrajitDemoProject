import 'package:hive_flutter/hive_flutter.dart';

import '../result/result.dart';

/// Local-first persistence, shaped identically to [ApiClient] — both return
/// [Result] (ADR-0001 §4). Proposed engine: Hive (key-value; no TypeAdapters
/// yet since no feature model exists — add one per-model at Tasks stage once
/// `employee-internal-transfer`'s data model is specced).
///
/// Call [init] once at app start, before any box is opened.
class LocalDbService {
  static Future<void> init() async {
    await Hive.initFlutter();
  }

  Future<Result<T>> read<T>(String boxName, String key) async {
    try {
      final box = await Hive.openBox(boxName);
      final value = box.get(key);
      if (value == null) {
        return Result.error('No local record found for "$key".');
      }
      return Result.success(value as T);
    } catch (e) {
      return Result.error('Local read failed: $e');
    }
  }

  Future<Result<bool>> write(String boxName, String key, dynamic value) async {
    try {
      final box = await Hive.openBox(boxName);
      await box.put(key, value);
      return Result.success(true);
    } catch (e) {
      return Result.error('Local write failed: $e');
    }
  }

  Future<Result<bool>> delete(String boxName, String key) async {
    try {
      final box = await Hive.openBox(boxName);
      await box.delete(key);
      return Result.success(true);
    } catch (e) {
      return Result.error('Local delete failed: $e');
    }
  }
}
