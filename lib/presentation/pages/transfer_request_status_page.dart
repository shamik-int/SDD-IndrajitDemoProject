import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/stakeholder.dart';
import '../../domain/entities/stakeholder_decision.dart';
import '../../domain/entities/transfer_request.dart';
import '../../domain/entities/transfer_request_status.dart';
import '../bindings/transfer_request_submission_binding.dart';
import '../controllers/simulate_decision_controller.dart';
import '../controllers/transfer_request_status_controller.dart';
import '../widgets/logout_action.dart';
import 'transfer_request_submission_page.dart';

String _statusLabel(TransferRequestStatus status) {
  switch (status) {
    case TransferRequestStatus.pendingManagerApproval:
      return 'Pending Manager Approval';
    case TransferRequestStatus.pendingHrValidation:
      return 'Pending HR Validation';
    case TransferRequestStatus.pendingDownstreamUpdates:
      return 'Pending Downstream Updates';
    case TransferRequestStatus.completed:
      return 'Completed';
    case TransferRequestStatus.rejectedByManager:
      return 'Rejected by Manager';
    case TransferRequestStatus.rejectedByHr:
      return 'Rejected by HR';
  }
}

String _stakeholderLabel(Stakeholder stakeholder) {
  switch (stakeholder) {
    case Stakeholder.manager:
      return 'Manager';
    case Stakeholder.hr:
      return 'HR';
    case Stakeholder.payroll:
      return 'Payroll';
    case Stakeholder.it:
      return 'IT';
    case Stakeholder.facilities:
      return 'Facilities';
  }
}

void _goToSubmissionPage() {
  Get.to(
    () => const TransferRequestSubmissionPage(),
    binding: TransferRequestSubmissionBinding(),
  );
}

class TransferRequestStatusPage
    extends GetView<TransferRequestStatusController> {
  const TransferRequestStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Transfer Request'),
        actions: const [LogoutAction()],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final request = controller.request.value;
        if (request == null) {
          return const _NoRequestView();
        }
        return RefreshIndicator(
          onRefresh: controller.refreshStatus,
          child: _RequestDetails(request: request),
        );
      }),
    );
  }
}

class _NoRequestView extends StatelessWidget {
  const _NoRequestView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You have no transfer request in progress.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _goToSubmissionPage(),
              child: const Text('Submit a Transfer Request'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestDetails extends StatelessWidget {
  final TransferRequest request;

  const _RequestDetails({required this.request});

  @override
  Widget build(BuildContext context) {
    final pending = request.pendingStakeholders;
    final isTerminal = request.status.isTerminal;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _statusLabel(request.status),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _DetailRow(label: 'Effective date', value: DateFormat.yMMMd().format(request.effectiveDate)),
          if (request.reason != null && request.reason!.isNotEmpty)
            _DetailRow(label: 'Reason', value: request.reason!),
          const SizedBox(height: 24),
          if (!isTerminal) ...[
            Text('Pending Actions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (pending.isEmpty)
              const Text('No stakeholder currently pending.')
            else
              Wrap(
                key: const Key('pending-stakeholders'),
                spacing: 8,
                children: pending
                    .map((s) => Chip(label: Text(_stakeholderLabel(s))))
                    .toList(),
              ),
          ],
          if (isTerminal) ...[
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _goToSubmissionPage(),
              child: const Text('Submit a New Transfer Request'),
            ),
          ],
          if (!isTerminal && pending.isNotEmpty)
            _SimulateDecisionSection(requestId: request.id, pendingStakeholders: pending),
        ],
      ),
    );
  }
}

/// AC14 — a deliberately distinct, non-production section. There is no
/// backend (ADR-0004), so Manager/HR/Payroll/IT/Facilities decisions are
/// simulated here rather than arriving from a real integration. This must
/// never be styled or labeled as if it were a real stakeholder-facing
/// feature (plan's explicit QA/Gate 2 check item).
class _SimulateDecisionSection extends GetView<SimulateDecisionController> {
  final String requestId;
  final List<Stakeholder> pendingStakeholders;

  const _SimulateDecisionSection({
    required this.requestId,
    required this.pendingStakeholders,
  });

  static const _downstream = {
    Stakeholder.payroll,
    Stakeholder.it,
    Stakeholder.facilities,
  };

  Future<void> _apply(Stakeholder stakeholder, StakeholderDecision decision) async {
    await controller.simulate(
      requestId: requestId,
      stakeholder: stakeholder,
      decision: decision,
    );
    await Get.find<TransferRequestStatusController>().refreshStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('simulate-decision-section'),
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(8),
        color: Colors.orange.withValues(alpha: 0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science_outlined, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'TEST/DEMO ONLY — Simulate Stakeholder Decision',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.orange.shade900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'This app has no backend. These controls stand in for a real '
            'Manager/HR/Payroll/IT/Facilities decision.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          for (final stakeholder in pendingStakeholders)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(child: Text(_stakeholderLabel(stakeholder))),
                  if (_downstream.contains(stakeholder))
                    ElevatedButton(
                      onPressed: () => _apply(stakeholder, StakeholderDecision.completed),
                      child: const Text('Mark Complete'),
                    )
                  else ...[
                    ElevatedButton(
                      onPressed: () => _apply(stakeholder, StakeholderDecision.approved),
                      child: const Text('Approve'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _apply(stakeholder, StakeholderDecision.rejected),
                      child: const Text('Reject'),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text('$label: $value'),
    );
  }
}
