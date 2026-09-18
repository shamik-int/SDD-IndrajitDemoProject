import '../../core/result/result.dart';
import '../entities/employee_account.dart';
import '../entities/login_input.dart';
import '../entities/register_employee_input.dart';

abstract class EmployeeAccountRepository {
  Future<Result<EmployeeAccount>> register(RegisterEmployeeInput input);

  Future<Result<EmployeeAccount>> login(LoginInput input);

  Future<Result<EmployeeAccount?>> getCurrentSession();

  Future<Result<bool>> logout();
}
