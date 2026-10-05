import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../../core/local_db/local_db_service.dart';
import '../../../domain/transfer/entities/enums.dart';
import '../../../domain/transfer/entities/org_values.dart';

/// A V1 demo account (plan PD-01, ADR-0006). The role is set here and can
/// never be chosen at sign-in (SD-18). Only a hash and salt are held
/// (PD-01a); a tester has no [baseline] profile.
class DemoAccount {
  final String userId;
  final String email;
  final String displayName;
  final UserRole role;
  final String passwordHash;
  final String passwordSalt;
  final EmployeeCurrentValues? baseline;

  const DemoAccount({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.role,
    required this.passwordHash,
    required this.passwordSalt,
    this.baseline,
  });

  /// For tests and tooling: builds an account from a password it never stores.
  factory DemoAccount.withPassword({
    required String userId,
    required String email,
    required String displayName,
    required UserRole role,
    required String password,
    required String salt,
    EmployeeCurrentValues? baseline,
  }) {
    return DemoAccount(
      userId: userId,
      email: email,
      displayName: displayName,
      role: role,
      passwordHash: hashPassword(password, salt),
      passwordSalt: salt,
      baseline: baseline,
    );
  }

  /// SHA-256 over `password:salt` (ADR-0005 decision 2, kept by ADR-0006).
  static String hashPassword(String password, String salt) =>
      sha256.convert(utf8.encode('$password:$salt')).toString();

  bool matches(String password) => hashPassword(password, passwordSalt) == passwordHash;

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'email': email,
        'displayName': displayName,
        'role': role.name,
        'passwordHash': passwordHash,
        'passwordSalt': passwordSalt,
        'baseline': baseline == null
            ? null
            : {
                'departmentId': baseline!.departmentId,
                'locationId': baseline!.locationId,
                'roleId': baseline!.roleId,
                'managerName': baseline!.managerName,
              },
      };

  static DemoAccount fromMap(Map<dynamic, dynamic> m) {
    final b = m['baseline'] as Map?;
    return DemoAccount(
      userId: m['userId'] as String,
      email: m['email'] as String,
      displayName: m['displayName'] as String,
      role: UserRole.values.byName(m['role'] as String),
      passwordHash: m['passwordHash'] as String,
      passwordSalt: m['passwordSalt'] as String,
      baseline: b == null
          ? null
          : EmployeeCurrentValues(
              values: OrgValues(
                departmentId: b['departmentId'] as String,
                locationId: b['locationId'] as String,
                roleId: b['roleId'] as String,
              ),
              managerName: b['managerName'] as String,
            ),
    );
  }
}

/// The accounts shipped in V1 builds: test data only (BR-25). The demo
/// password is given to testers with the demo instructions; it is not in
/// the repository (PD-01a).
class DemoAccounts {
  DemoAccounts._();

  static const seed = [
    DemoAccount(
      userId: 'emp-001',
      email: 'asha.rao@demo.test',
      displayName: 'Asha Rao (demo)',
      role: UserRole.employee,
      passwordSalt: 'GHzIm85ZldLPvO8S8bvkcw==',
      passwordHash: '85b320facb0d89328ab2e782e4cf705b5f2da245aec3cf4426d66c761751f93f',
      baseline: EmployeeCurrentValues(
        values: OrgValues(departmentId: 'dept-eng', locationId: 'loc-blr', roleId: 'role-swe'),
        managerName: 'Vikram Sen (demo)',
      ),
    ),
    DemoAccount(
      userId: 'emp-002',
      email: 'rahul.verma@demo.test',
      displayName: 'Rahul Verma (demo)',
      role: UserRole.employee,
      passwordSalt: 'dfctXhHyXbWoGyToRQJbug==',
      passwordHash: '640bc740de9427ed1ca4137650ea48f04f32dc37c61733e7ce06d31e14a0b534',
      baseline: EmployeeCurrentValues(
        values: OrgValues(departmentId: 'dept-sales', locationId: 'loc-mum', roleId: 'role-analyst'),
        managerName: 'Neha Kapoor (demo)',
      ),
    ),
    DemoAccount(
      userId: 'emp-003',
      email: 'meera.iyer@demo.test',
      displayName: 'Meera Iyer (demo)',
      role: UserRole.employee,
      passwordSalt: 'ky1-d7qBjr6z0qjTsEKvXQ==',
      passwordHash: 'c2e14497b9253c6510645474e6f2a7457549ea57a9149a552a0cf34629499f15',
      baseline: EmployeeCurrentValues(
        values: OrgValues(departmentId: 'dept-fin', locationId: 'loc-pun', roleId: 'role-tl'),
        managerName: 'Arjun Das (demo)',
      ),
    ),
    DemoAccount(
      userId: 'tst-001',
      email: 'tester@demo.test',
      displayName: 'Demo Tester',
      role: UserRole.tester,
      passwordSalt: 'k0ygHzBy_CPtbWH-g3BPYA==',
      passwordHash: 'a2787e20a8d11e7cc6373c8448dbc70212813052515f29c6499266df900c3a29',
    ),
  ];
}

/// Raw access to the `demo_accounts` box, keyed by `userId`.
class DemoAccountsStore {
  static const box = 'demo_accounts';

  final LocalDbService localDb;

  const DemoAccountsStore(this.localDb);

  Future<DemoAccount?> byUserId(String userId) async {
    final result = await localDb.read<Map>(box, userId);
    return result.isSuccess ? DemoAccount.fromMap(result.data!) : null;
  }

  Future<DemoAccount?> byEmail(String normalisedEmail) async {
    final result = await localDb.readAll(box);
    if (result.isError) return null;
    for (final value in result.data!.values) {
      final account = DemoAccount.fromMap(value as Map);
      if (account.email == normalisedEmail) return account;
    }
    return null;
  }
}
