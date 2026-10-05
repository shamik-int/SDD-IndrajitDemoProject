import '../../../core/local_db/local_db_service.dart';
import 'demo_accounts.dart';

/// Start-up step (plan PD-06). Below schema version 2, deletes the v1.5 and
/// BRD-002 demo data (test data only, BR-25) once; then makes sure every
/// demo account exists.
///
/// A failed read of the version is not "first run": the clean-up is skipped
/// and tried again on the next start, so a read error never wipes the
/// session (G2-14). The accounts are rewritten from [accounts] on every
/// start on purpose: the seed is their only source, nothing edits them
/// locally, and a rotated demo password takes effect this way.
class DemoDataSeeder {
  static const metaBox = 'app_meta';
  static const schemaKey = 'schemaVersion';
  static const schemaVersion = 2;
  static const legacyBoxes = ['transfer_requests', 'app_state', 'employees', 'session', 'decision_history'];

  final LocalDbService localDb;
  final List<DemoAccount> accounts;

  const DemoDataSeeder(this.localDb, {this.accounts = DemoAccounts.seed});

  Future<void> ensureSeeded() async {
    final version = await localDb.find<int>(metaBox, schemaKey);
    if (version.isSuccess && (version.data ?? 0) < schemaVersion) {
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
