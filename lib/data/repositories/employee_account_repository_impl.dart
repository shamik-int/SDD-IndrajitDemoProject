import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../../core/result/result.dart';
import '../../core/utils/validators.dart';
import '../../domain/entities/employee_account.dart';
import '../../domain/entities/login_input.dart';
import '../../domain/entities/register_employee_input.dart';
import '../../domain/repositories/employee_account_repository.dart';
import '../datasources/local/employee_account_local_datasource.dart';
import '../models/employee_account_model.dart';

/// Implements the spec's Local Data Contract (OP01–OP04) over Hive
/// (ADR-0004/ADR-0005). Owns field validation, email normalization,
/// uniqueness, password hashing/verification, and session read/write — the
/// datasource itself is raw CRUD only.
class EmployeeAccountRepositoryImpl implements EmployeeAccountRepository {
  final EmployeeAccountLocalDataSource dataSource;
  final Random _random;

  EmployeeAccountRepositoryImpl(this.dataSource, {Random? random})
    : _random = random ?? Random.secure();

  static const _invalidCredentialsMessage = 'Invalid email or password.';

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  String _generateSalt() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String _hashPassword(String password, String salt) {
    return sha256.convert(utf8.encode('$password:$salt')).toString();
  }

  @override
  Future<Result<EmployeeAccount>> register(RegisterEmployeeInput input) async {
    final validationError = _validate(input);
    if (validationError != null) return Result.error(validationError);

    final normalizedEmail = _normalizeEmail(input.email);
    final existing = await dataSource.getByEmail(normalizedEmail);
    if (existing != null) {
      return Result.error('An account with this email already exists.');
    }

    final salt = _generateSalt();
    final model = EmployeeAccountModel(
      name: input.name,
      email: normalizedEmail,
      passwordHash: _hashPassword(input.password, salt),
      passwordSalt: salt,
      currentDepartmentId: input.currentDepartmentId,
      currentLocationId: input.currentLocationId,
      currentRoleId: input.currentRoleId,
      registeredAt: DateTime.now(),
    );

    final saveResult = await dataSource.saveAccount(normalizedEmail, model);
    if (saveResult.isError) {
      return Result.error(saveResult.message ?? 'Failed to create account.');
    }
    await dataSource.setCurrentSessionEmail(normalizedEmail);

    return Result.success(model.toEntity());
  }

  String? _validate(RegisterEmployeeInput input) {
    final nameError = Validators.required(input.name, fieldName: 'Name');
    if (nameError != null) return nameError;

    final emailError = Validators.email(input.email);
    if (emailError != null) return emailError;

    final passwordError = Validators.password(input.password);
    if (passwordError != null) return passwordError;

    final departmentError = Validators.required(input.currentDepartmentId, fieldName: 'Department');
    if (departmentError != null) return departmentError;

    final locationError = Validators.required(input.currentLocationId, fieldName: 'Location');
    if (locationError != null) return locationError;

    final roleError = Validators.required(input.currentRoleId, fieldName: 'Role');
    if (roleError != null) return roleError;

    return null;
  }

  @override
  Future<Result<EmployeeAccount>> login(LoginInput input) async {
    final normalizedEmail = _normalizeEmail(input.email);
    final existing = await dataSource.getByEmail(normalizedEmail);
    if (existing == null) {
      return Result.error(_invalidCredentialsMessage);
    }

    final candidateHash = _hashPassword(input.password, existing.passwordSalt);
    if (candidateHash != existing.passwordHash) {
      return Result.error(_invalidCredentialsMessage);
    }

    await dataSource.setCurrentSessionEmail(normalizedEmail);
    return Result.success(existing.toEntity());
  }

  @override
  Future<Result<EmployeeAccount?>> getCurrentSession() async {
    final sessionEmail = await dataSource.getCurrentSessionEmail();
    if (sessionEmail == null) return Result.success(null);

    final account = await dataSource.getByEmail(sessionEmail);
    // A dangling session pointer is treated as "no session", same handling
    // as the other feature's dangling active-request pointer.
    if (account == null) return Result.success(null);

    return Result.success(account.toEntity());
  }

  @override
  Future<Result<bool>> logout() async {
    await dataSource.setCurrentSessionEmail(null);
    return Result.success(true);
  }
}
