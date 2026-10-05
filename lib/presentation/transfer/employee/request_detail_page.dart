import 'package:flutter/material.dart' hide StepState;
import 'package:get/get.dart';

import '../../../core/constants/transfer_messages.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/transfer/entities/enums.dart';
import '../../../domain/transfer/entities/transfer_step.dart';
import '../../widgets/demo_banner.dart';
import '../shared/sign_out_action.dart';
import '../shared/transfer_labels.dart';
import 'request_detail_controller.dart';

/// Read-only by design: no edit, withdraw, retry or undo (AC09, AC17), and
/// no way to change the history (AC23).
class RequestDetailPage extends GetView<RequestDetailController> {
  const RequestDetailPage({super.key});

  Widget _section(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      );

  Widget _step(BuildContext context, TransferStep s) {
    return Card(
      key: Key('step-${s.stepId.code}'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${s.stepId.stakeholderLabel} · ${s.stepId.pendingAction}',
                style: Theme.of(context).textTheme.titleSmall),
            Text(s.stateLabel),
            if (s.state == StepState.pending) Text('Pending action: ${s.stepId.pendingAction}'),
            if (s.state == StepState.rejected && s.reason != null) Text('Reason: ${s.reason}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final refs = controller.refs;
    return Scaffold(
      appBar: AppBar(title: const Text('Transfer request'), actions: const [SignOutAction()]),
      body: Column(
        children: [
          const DemoBanner(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
              final r = controller.request.value;
              if (r == null) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(controller.error.value ?? TransferMessages.noRequestFound),
                );
              }
              final confirmation = controller.confirmation;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (controller.justSubmitted)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text(TransferMessages.requestSubmitted, key: Key('detail-submitted-banner')),
                      ),
                    Text(TransferLabels.status(r, controller.today),
                        key: const Key('detail-status'), style: Theme.of(context).textTheme.headlineSmall),
                    if (controller.effectiveDatePassed)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          TransferMessages.effectiveDatePassedNote(r.effectiveDate),
                          key: const Key('detail-note-date-passed'),
                        ),
                      ),
                    if (confirmation != null)
                      Card(
                        key: const Key('detail-confirmation'),
                        margin: const EdgeInsets.only(top: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(confirmation.title, style: Theme.of(context).textTheme.titleMedium),
                              for (final line in confirmation.lines) Text(line),
                            ],
                          ),
                        ),
                      ),
                    _section(context, 'What you asked for'),
                    Text('Proposed: ${TransferLabels.values(r.proposed, refs)}'),
                    Text('Current when submitted: ${TransferLabels.values(r.current.values, refs)}'),
                    Text('Effective date: ${LocalDate.format(r.effectiveDate)}'),
                    Text('Your reason: ${r.reason ?? 'None given'}'),
                    Text('Submitted: ${TransferLabels.timestamp(r.submittedAt)}'),
                    _section(context, 'Steps'),
                    for (final s in r.steps) _step(context, s),
                    _section(context, 'History'),
                    if (controller.historyError.value != null)
                      Text(
                        controller.historyError.value!,
                        key: const Key('history-error'),
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    for (final e in controller.history)
                      Padding(
                        key: Key('history-entry-${e.sequence}'),
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${e.sequence}. ${TransferLabels.history(e)}'),
                            Text(
                              '${TransferLabels.actor(e.actor)} · ${TransferLabels.timestamp(e.recordedAt)}'
                              '${e.simulatedBy != null ? ' · entered in the V1 demo' : ''}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
