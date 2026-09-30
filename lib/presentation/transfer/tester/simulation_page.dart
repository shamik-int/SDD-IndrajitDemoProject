import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/transfer_messages.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/transfer/entities/enums.dart';
import '../../../domain/transfer/entities/stakeholder_task.dart';
import '../../../domain/transfer/portal/portal_contracts.dart';
import '../../widgets/demo_banner.dart';
import '../shared/sign_out_action.dart';
import 'simulation_controller.dart';

/// "Demo only: simulate stakeholder outcome" (AC24). Visually separate from
/// the employee screens and never presented as a stakeholder interface.
/// Must be removed before any production release (SD-13).
class SimulationPage extends GetView<SimulationController> {
  const SimulationPage({super.key});

  static String _label(Outcome o) => switch (o) {
        Outcome.approved => 'Approve',
        Outcome.rejected => 'Reject',
        Outcome.completed => 'Complete',
        Outcome.failed => 'Fail',
      };

  /// Stakeholder contract content only (BR-25), names resolved from D-03.
  static List<String> payloadLines(StakeholderTask t, ReferenceLists refs) {
    final p = t.payload;
    String dept(String k) => refs.departmentName(p[k]!);
    String loc(String k) => refs.locationName(p[k]!);
    String role(String k) => refs.roleName(p[k]!);
    return switch (t.stepId) {
      StepId.managerApproval || StepId.hrEligibility => [
          'Current: ${dept('currentDepartmentId')}, ${loc('currentLocationId')}, ${role('currentRoleId')}',
          'Proposed: ${dept('proposedDepartmentId')}, ${loc('proposedLocationId')}, ${role('proposedRoleId')}',
          "Employee's reason: ${p['reason'] ?? 'None given'}",
        ],
      StepId.orgRecordUpdate => ['New: ${dept('newDepartmentId')}, ${loc('newLocationId')}, ${role('newRoleId')}'],
      StepId.payrollUpdate => ['New role: ${role('newRoleId')}', 'New location: ${loc('newLocationId')}'],
      StepId.itAccessChange => [
          'Provision: ${dept('provisionDepartmentId')}, ${role('provisionRoleId')}',
          'Remove: ${dept('removeDepartmentId')}, ${role('removeRoleId')}',
        ],
      StepId.facilitiesWorkspace => ['New location: ${loc('newLocationId')}'],
    };
  }

  Future<void> _onOutcome(StakeholderTask task, Outcome outcome) async {
    if (outcome != Outcome.rejected) {
      await controller.record(task, outcome);
      return;
    }
    final reason = await Get.dialog<String>(const _RejectReasonDialog());
    if (reason != null) await controller.record(task, outcome, reason: reason);
  }

  Widget _task(BuildContext context, OpenStakeholderTask open) {
    final t = open.task;
    return Card(
      key: Key('task-${t.taskId}'),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.accentLight, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${t.stepId.stakeholderLabel} · ${t.stepId.pendingAction}',
                style: Theme.of(context).textTheme.titleSmall),
            Text('Employee: ${t.employeeName}'),
            Text('Effective date: ${LocalDate.format(t.effectiveDate)}'),
            if (open.effectiveDatePassed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Chip(
                  key: Key('task-mark-${t.taskId}'),
                  label: const Text(TransferMessages.effectiveDatePassedMark),
                ),
              ),
            for (final line in payloadLines(t, controller.refs)) Text(line),
            const SizedBox(height: 8),
            Obx(
              () => Wrap(
                spacing: 8,
                children: [
                  for (final o in t.stepId.validOutcomes)
                    OutlinedButton(
                      key: Key('outcome-${t.taskId}-${o.code}'),
                      onPressed: controller.isBusy.value ? null : () => _onOutcome(t, o),
                      child: Text(_label(o)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(TransferMessages.simulationTitle),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.accentLight,
        foregroundColor: AppColors.textPrimaryLight,
        actions: const [SignOutAction()],
      ),
      body: Column(
        children: [
          const DemoBanner(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              'Test and demo use only. Outcomes recorded here stand in for the real stakeholders, '
              'who are not integrated in V1. This is not a stakeholder interface.',
            ),
          ),
          Obx(() => controller.error.value == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Text(controller.error.value!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                )),
          Obx(() => controller.notice.value == null
              ? const SizedBox.shrink()
              : Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 0), child: Text(controller.notice.value!))),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.tasks.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.tasks.isEmpty) return const Center(child: Text('No open stakeholder tasks.'));
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [for (final t in controller.tasks) _task(context, t)],
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Rejection needs a reason that is not empty or only spaces (AC25, BR-28).
class _RejectReasonDialog extends StatefulWidget {
  const _RejectReasonDialog();

  @override
  State<_RejectReasonDialog> createState() => _RejectReasonDialogState();
}

class _RejectReasonDialogState extends State<_RejectReasonDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ok = _reason.text.trim().isNotEmpty;
    return AlertDialog(
      title: const Text('Rejection reason'),
      content: TextField(
        key: const Key('reject-reason-field'),
        controller: _reason,
        maxLength: TransferMessages.maxReasonLength,
        maxLines: 3,
        decoration: const InputDecoration(hintText: 'Required'),
        onChanged: (_) => setState(() {}),
      ),
      actions: [
        TextButton(onPressed: () => Get.back<String>(), child: const Text('Cancel')),
        ElevatedButton(
          key: const Key('reject-confirm'),
          onPressed: ok ? () => Get.back(result: _reason.text) : null,
          child: const Text('Record rejection'),
        ),
      ],
    );
  }
}
