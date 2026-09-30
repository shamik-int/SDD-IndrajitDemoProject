import '../../../core/local_db/local_db_service.dart';
import 'demo_accounts.dart';

/// Start-up step (plan PD-06). Below schema version 2, deletes the v1.5 and
/// BRD-002 demo data (test data only, BR-25) once; then makes sure every
/// demo account exists.
class DemoDataSeeder {
  static const metaBox = 'app_meta';
  static const schemaKey = 'schemaVersion';
  static const schemaVersion = 2;
  static const legacyBoxes = ['transfer_requests', 'app_state', 'employees', 'session', 'decision_history'];

  final LocalDbService localDb;
  final List<DemoAccount> accounts;

  const DemoDataSeeder(this.localDb, {this.accounts = DemoAccounts.seed});

  Future<void> ensureSeeded() async {
    final version = await localDb.read<int>(metaBox, schemaKey);
    if (version.isError || version.data! < schemaVersion) {
      for (final box in legacyBoxes) {
        await localDb.clearBox(box);
      }
      await localDb.write(metaBox, schemaKey, schemaVersion);
    }
    for (final account in accounts) {
      await localDb.write(DemoAccountsStore.box, account.userId, account.toMap());
    }
  }
}
