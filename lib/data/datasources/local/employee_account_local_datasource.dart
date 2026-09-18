import '../../../core/local_db/local_db_service.dart';
import '../../../core/result/result.dart';
import '../../models/employee_account_model.dart';

/// Raw Hive CRUD only — no business rules (validation, uniqueness, password
/// hashing/verification) live here, that's `data/repositories/`'s job, same
/// split ADR-0004 already established for `employee-internal-transfer`.
class EmployeeAccountLocalDataSource {
  static const employeesBox = 'employees';
  static const sessionBox = 'session';
  static const currentEmployeeEmailKey = 'currentEmployeeEmail';

  final LocalDbService localDb;

  const EmployeeAccountLocalDataSource(this.localDb);

  Future<EmployeeAccountModel?> getByEmail(String normalizedEmail) async {
    final result = await localDb.read<Map>(employeesBox, normalizedEmail);
    if (result.isError) return null;
    return EmployeeAccountModel.fromMap(result.data!);
  }

  Future<Result<bool>> saveAccount(String normalizedEmail, EmployeeAccountModel model) {
    return localDb.write(employeesBox, normalizedEmail, EmployeeAccountModel.toMap(model));
  }

  Future<String?> getCurrentSessionEmail() async {
    final result = await localDb.read<String>(sessionBox, currentEmployeeEmailKey);
    return result.isSuccess ? result.data : null;
  }

  Future<Result<bool>> setCurrentSessionEmail(String? normalizedEmail) {
    if (normalizedEmail == null) {
      return localDb.delete(sessionBox, currentEmployeeEmailKey);
    }
    return localDb.write(sessionBox, currentEmployeeEmailKey, normalizedEmail);
  }
}
