import '../../../core/constants/transfer_messages.dart';
import '../../../core/local_db/local_db_service.dart';
import '../../../core/result/result.dart';
import '../../../domain/transfer/entities/current_user.dart';
import '../../../domain/transfer/portal/portal_contracts.dart';
import 'demo_accounts.dart';

/// D-01 in V1: demo-level sign-in over the seeded accounts (plan PD-01).
/// A local access gate only, not real authentication (ADR-0005, BR-26).
class DemoAuthService implements SignInService {
  static const sessionBox = 'session';
  static const currentUserKey = 'currentUserId';

  final LocalDbService localDb;
  final DemoAccountsStore _accounts;

  DemoAuthService(this.localDb) : _accounts = DemoAccountsStore(localDb);

  static CurrentUser _toUser(DemoAccount a) =>
      CurrentUser(userId: a.userId, role: a.role, displayName: a.displayName);

  @override
  Future<Result<CurrentUser>> signIn({required String email, required String password}) async {
    final account = await _accounts.byEmail(email.trim().toLowerCase());
    // One message for both cases, so a failed attempt never says which was wrong.
    if (account == null || !account.matches(password)) {
      return Result.error(TransferMessages.invalidCredentials);
    }
    final saved = await localDb.write(sessionBox, currentUserKey, account.userId);
    // Credentials were right; only the session could not be stored.
    if (saved.isError) return Result.error(TransferMessages.signInFailed);
    return Result.success(_toUser(account));
  }

  @override
  Future<Result<bool>> signOut() async {
    final deleted = await localDb.delete(sessionBox, currentUserKey);
    return deleted.isError ? Result.error(TransferMessages.signOutFailed) : Result.success(true);
  }

  @override
  Future<CurrentUser?> currentUser() async {
    final session = await localDb.read<String>(sessionBox, currentUserKey);
    if (session.isError) return null;
    final account = await _accounts.byUserId(session.data!);
    return account == null ? null : _toUser(account);
  }
}
