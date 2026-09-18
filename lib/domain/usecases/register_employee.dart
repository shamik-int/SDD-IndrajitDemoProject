import '../../core/result/result.dart';
import '../entities/employee_account.dart';
import '../entities/register_employee_input.dart';
import '../repositories/employee_account_repository.dart';

class RegisterEmployee {
  final EmployeeAccountRepository repository;

  const RegisterEmployee(this.repository);

  Future<Result<EmployeeAccount>> call(RegisterEmployeeInput input) {
    return repository.register(input);
  }
}
