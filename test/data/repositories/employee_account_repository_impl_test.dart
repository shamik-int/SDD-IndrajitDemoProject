// Exercises employee-registration-login.UT01–UT10 and the relevant QA cases
// (test_cases/employee-registration-login.test_cases.md) against a real,
// temp-directory-backed Hive instance — not a mock, same treatment as
// employee-internal-transfer's T02 (ADR-0004: Hive is the system of record).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:employee_transfer_project/core/local_db/local_db_service.dart';
import 'package:employee_transfer_project/data/datasources/local/employee_account_local_datasource.dart';
import 'package:employee_transfer_project/data/repositories/employee_account_repository_impl.dart';
import 'package:employee_transfer_project/domain/entities/login_input.dart';
import 'package:employee_transfer_project/domain/entities/register_employee_input.dart';

void main() {
  late Directory tempDir;
  late EmployeeAccountRepositoryImpl repository;

  RegisterEmployeeInput validInput({String email = 'person@intglobal.com', String? password}) {
    return RegisterEmployeeInput(
      name: 'Person One',
      email: email,
      password: password ?? 'Password123',
      currentDepartmentId: 'dept-eng',
      currentLocationId: 'loc-blr',
      currentRoleId: 'role-swe',
    );
  }

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('erl_hive_test_');
    Hive.init(tempDir.path);
    final localDb = LocalDbService();
    final dataSource = EmployeeAccountLocalDataSource(localDb);
    repository = EmployeeAccountRepositoryImpl(dataSource);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('register — UT01, UT02, UT03, UT04, UT05, QA02, QA03, QA04', () {
    test('UT01: valid fields succeed, session set to the new account', () async {
      final result = await repository.register(validInput());

      expect(result.isSuccess, isTrue);
      expect(result.data!.email, 'person@intglobal.com');

      final session = await repository.getCurrentSession();
      expect(session.data!.email, 'person@intglobal.com');
    });

    test('UT02: name missing fails, no account created', () async {
      final result = await repository.register(
        RegisterEmployeeInput(
          name: '',
          email: 'person@intglobal.com',
          password: 'Password123',
          currentDepartmentId: 'dept-eng',
          currentLocationId: 'loc-blr',
          currentRoleId: 'role-swe',
        ),
      );

      expect(result.isError, isTrue);
      final login = await repository.login(
        const LoginInput(email: 'person@intglobal.com', password: 'Password123'),
      );
      expect(login.isError, isTrue);
    });

    test('UT03: malformed email fails with the valid-email message', () async {
      final result = await repository.register(validInput(email: 'not-an-email'));

      expect(result.isError, isTrue);
      expect(result.message, 'Enter a valid email address.');
    });

    test('UT04: a 4-character password fails the complexity rule', () async {
      final result = await repository.register(validInput(password: 'ab1'));

      expect(result.isError, isTrue);
      expect(
        result.message,
        'Password must be at least 8 characters and include a letter and a number.',
      );
    });

    test('UT05: registering an already-registered email fails, no second account', () async {
      await repository.register(validInput());
      final result = await repository.register(validInput());

      expect(result.isError, isTrue);
      expect(result.message, 'An account with this email already exists.');
    });

    test('QA02: email uniqueness is case-insensitive', () async {
      await repository.register(validInput(email: 'Person@IntGlobal.com'));
      final result = await repository.register(validInput(email: 'person@intglobal.com'));

      expect(result.isError, isTrue);
      expect(result.message, 'An account with this email already exists.');
    });

    test('QA03: an 8-character password with a letter and a number is accepted', () async {
      final result = await repository.register(validInput(password: 'abcd1234'));

      expect(result.isSuccess, isTrue);
    });

    test('QA04: a 7-character password is rejected', () async {
      final result = await repository.register(validInput(password: 'abcd123'));

      expect(result.isError, isTrue);
    });
  });

  group('login — UT06, UT07, UT08, QA01, QA02, QA05, QA06', () {
    test('UT06: correct email + password succeeds, session set', () async {
      await repository.register(validInput());

      final result = await repository.login(
        const LoginInput(email: 'person@intglobal.com', password: 'Password123'),
      );

      expect(result.isSuccess, isTrue);
      expect(result.data!.email, 'person@intglobal.com');
    });

    test('UT07: an unregistered email fails with the generic message', () async {
      final result = await repository.login(
        const LoginInput(email: 'nobody@intglobal.com', password: 'Password123'),
      );

      expect(result.isError, isTrue);
      expect(result.message, 'Invalid email or password.');
    });

    test('UT08: a registered email with the wrong password fails with the same message', () async {
      await repository.register(validInput());

      final result = await repository.login(
        const LoginInput(email: 'person@intglobal.com', password: 'WrongPass1'),
      );

      expect(result.isError, isTrue);
      expect(result.message, 'Invalid email or password.');
    });

    test('QA01: register, log out, then log back in with the same credentials', () async {
      await repository.register(validInput());
      await repository.logout();

      final result = await repository.login(
        const LoginInput(email: 'person@intglobal.com', password: 'Password123'),
      );

      expect(result.isSuccess, isTrue);
      expect(result.data!.name, 'Person One');
    });

    test('QA02: login email comparison is case-insensitive', () async {
      await repository.register(validInput(email: 'person@intglobal.com'));

      final result = await repository.login(
        const LoginInput(email: 'PERSON@INTGLOBAL.COM', password: 'Password123'),
      );

      expect(result.isSuccess, isTrue);
    });

    test('QA05: logging in as a second account replaces the active session', () async {
      await repository.register(validInput(email: 'first@intglobal.com'));
      await repository.register(validInput(email: 'second@intglobal.com'));

      await repository.login(
        const LoginInput(email: 'first@intglobal.com', password: 'Password123'),
      );
      await repository.login(
        const LoginInput(email: 'second@intglobal.com', password: 'Password123'),
      );

      final session = await repository.getCurrentSession();
      expect(session.data!.email, 'second@intglobal.com');
    });

    test('QA06: an empty password fails with the same generic message', () async {
      await repository.register(validInput());

      final result = await repository.login(
        const LoginInput(email: 'person@intglobal.com', password: ''),
      );

      expect(result.isError, isTrue);
      expect(result.message, 'Invalid email or password.');
    });
  });

  group('getCurrentSession — UT09', () {
    test('UT09: returns success(null) with no prior login', () async {
      final result = await repository.getCurrentSession();

      expect(result.isSuccess, isTrue);
      expect(result.data, isNull);
    });
  });

  group('logout — UT10', () {
    test('UT10: clears the session; account data is untouched', () async {
      await repository.register(validInput());
      final logoutResult = await repository.logout();

      expect(logoutResult.isSuccess, isTrue);
      expect(logoutResult.data, isTrue);

      final session = await repository.getCurrentSession();
      expect(session.data, isNull);

      final login = await repository.login(
        const LoginInput(email: 'person@intglobal.com', password: 'Password123'),
      );
      expect(login.isSuccess, isTrue);
    });
  });
}
