import '../../core/result/result.dart';
import '../entities/employee_account.dart';
import '../entities/login_input.dart';
import '../repositories/employee_account_repository.dart';

class LoginEmployee {
  final EmployeeAccountRepository repository;

  const LoginEmployee(this.repository);

  Future<Result<EmployeeAccount>> call(LoginInput input) {
    return repository.login(input);
  }
}
