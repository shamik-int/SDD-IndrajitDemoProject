import '../../core/result/result.dart';
import '../entities/employee_account.dart';
import '../repositories/employee_account_repository.dart';

class GetCurrentSession {
  final EmployeeAccountRepository repository;

  const GetCurrentSession(this.repository);

  Future<Result<EmployeeAccount?>> call() {
    return repository.getCurrentSession();
  }
}
