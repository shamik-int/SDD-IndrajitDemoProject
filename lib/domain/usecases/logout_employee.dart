import '../../core/result/result.dart';
import '../repositories/employee_account_repository.dart';

class LogoutEmployee {
  final EmployeeAccountRepository repository;

  const LogoutEmployee(this.repository);

  Future<Result<bool>> call() {
    return repository.logout();
  }
}
