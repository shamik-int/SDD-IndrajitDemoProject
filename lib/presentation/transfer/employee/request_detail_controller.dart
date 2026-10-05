import 'package:get/get.dart';

import '../../../core/time/clock.dart';
import '../../../domain/transfer/entities/history_entry.dart';
import '../../../domain/transfer/entities/transfer_request.dart';
import '../../../domain/transfer/portal/portal_contracts.dart';
import '../../../domain/transfer/usecases/transfer_usecases.dart';
import 'confirmation_builder.dart';

/// Request detail: steps, history and confirmation (OP04, OP05; AC19, AC20,
/// AC23, AC33).
class RequestDetailController extends GetxController {
  final GetMyTransferRequest getRequest;
  final GetRequestHistory getHistory;
  final ReferenceLists refs;
  final Clock clock;
  final String requestId;
  final bool justSubmitted;

  RequestDetailController({
    required this.getRequest,
    required this.getHistory,
    required this.refs,
    required this.clock,
    required this.requestId,
    this.justSubmitted = false,
  });

  final request = Rxn<TransferRequest>();
  final history = <HistoryEntry>[].obs;
  final isLoading = true.obs;
  final error = RxnString();

  /// Set when the request loaded but its history did not (AC23, G2-15).
  final historyError = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    final r = await getRequest(requestId);
    final h = r.isSuccess ? await getHistory(requestId) : null;
    if (isClosed) return;
    error.value = r.isError ? r.message : null;
    historyError.value = h != null && h.isError ? h.message : null;
    request.value = r.data;
    history.assignAll(h?.data ?? const []);
    isLoading.value = false;
  }

  DateTime get today => clock.today();

  bool get effectiveDatePassed => request.value?.isEffectiveDatePassed(today) ?? false;

  Confirmation? get confirmation =>
      request.value == null ? null : ConfirmationBuilder.build(request.value!, today: today, refs: refs);
}
