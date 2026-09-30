import '../../../core/local_db/local_db_service.dart';
import '../../../core/result/result.dart';
import '../../../domain/transfer/entities/transfer_ledger.dart';
import '../models/transfer_ledger_model.dart';

/// Raw storage of per-employee ledgers (ADR-0006). No business rules here.
/// [put] is a single write, which is what makes each operation atomic.
class TransferLedgerLocalDataSource {
  static const box = 'transfer_ledgers';

  final LocalDbService localDb;

  const TransferLedgerLocalDataSource(this.localDb);

  Future<TransferLedger?> get(String employeeId) async {
    final result = await localDb.read<Map>(box, employeeId);
    return result.isSuccess ? TransferLedgerModel.fromMap(result.data!) : null;
  }

  Future<Result<bool>> put(TransferLedger ledger) =>
      localDb.write(box, ledger.employeeId, TransferLedgerModel.toMap(ledger));

  Future<List<TransferLedger>> all() async {
    final result = await localDb.readAll(box);
    if (result.isError) return const [];
    return [for (final v in result.data!.values) TransferLedgerModel.fromMap(v as Map)];
  }
}
