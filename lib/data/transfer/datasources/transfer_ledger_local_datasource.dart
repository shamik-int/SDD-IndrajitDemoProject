import '../../../core/local_db/local_db_service.dart';
import '../../../core/result/result.dart';
import '../../../domain/transfer/entities/transfer_ledger.dart';
import '../models/transfer_ledger_model.dart';

/// Raw storage of per-employee ledgers (ADR-0006). No business rules here.
/// [put] is a single write, which is what makes each operation atomic.
///
/// Reads keep "absent" and "failed" apart: [get] is `success(null)` only when
/// no ledger is stored, and a failed read is an error. A caller must never
/// put after a failed read, or it would overwrite the stored history (G2-03).
class TransferLedgerLocalDataSource {
  static const box = 'transfer_ledgers';

  final LocalDbService localDb;

  const TransferLedgerLocalDataSource(this.localDb);

  Future<Result<TransferLedger?>> get(String employeeId) async {
    final result = await localDb.find<Map>(box, employeeId);
    if (result.isError) return Result.error(result.message!);
    final map = result.data;
    return Result.success(map == null ? null : TransferLedgerModel.fromMap(map));
  }

  Future<Result<bool>> put(TransferLedger ledger) =>
      localDb.write(box, ledger.employeeId, TransferLedgerModel.toMap(ledger));

  Future<Result<List<TransferLedger>>> all() async {
    final result = await localDb.readAll(box);
    if (result.isError) return Result.error(result.message!);
    return Result.success([for (final v in result.data!.values) TransferLedgerModel.fromMap(v as Map)]);
  }
}
