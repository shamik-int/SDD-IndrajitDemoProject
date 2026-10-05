import 'package:get/get.dart';

import '../../../core/time/clock.dart';
import '../../../domain/transfer/entities/enums.dart';
import '../../../domain/transfer/entities/inputs.dart';
import '../../../domain/transfer/entities/stakeholder_task.dart';
import '../../../domain/transfer/portal/portal_contracts.dart';
import '../../../domain/transfer/usecases/transfer_usecases.dart';

/// Demo-only simulation (AC24–AC26, AC29; OP06, OP07). Not a stakeholder
/// interface (BR-24); `TESTER` only (SD-18).
class SimulationController extends GetxController {
  final ListOpenStakeholderTasks listTasks;
  final RecordStakeholderOutcome recordOutcome;
  final ReferenceLists refs;
  final Clock clock;

  SimulationController({required this.listTasks, required this.recordOutcome, required this.refs, required this.clock});

  final tasks = <OpenStakeholderTask>[].obs;
  final isLoading = true.obs;
  final isBusy = false.obs;
  final error = RxnString();
  final notice = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    final result = await listTasks();
    if (isClosed) return;
    error.value = result.isError ? result.message : null;
    tasks.assignAll(result.data ?? const []);
    isLoading.value = false;
  }

  /// Records one outcome; buttons are disabled while it runs, so a double
  /// tap cannot send two (XF06).
  Future<bool> record(StakeholderTask task, Outcome outcome, {String? reason}) async {
    if (isBusy.value) return false;
    isBusy.value = true;
    notice.value = null;
    final result = await recordOutcome(
      RecordOutcomeInput(requestId: task.requestId, stepId: task.stepId, outcome: outcome, reason: reason),
    );
    if (isClosed) return result.isSuccess;
    if (result.isSuccess) {
      notice.value = '${task.stepId.pendingAction}: ${outcome.code} recorded for ${task.employeeName}.';
    }
    isBusy.value = false;
    // Reload first: load() resets `error`, and a refused outcome's OP06
    // message must stay on screen (AC26).
    await load();
    if (!isClosed && result.isError) error.value = result.message;
    return result.isSuccess;
  }
}
