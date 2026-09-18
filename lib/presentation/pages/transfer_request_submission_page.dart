import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/constants/reference_data.dart';
import '../bindings/transfer_request_status_binding.dart';
import '../controllers/transfer_request_submission_controller.dart';
import '../widgets/logout_action.dart';
import 'transfer_request_status_page.dart';

class TransferRequestSubmissionPage extends GetView<TransferRequestSubmissionController> {
  const TransferRequestSubmissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Internal Transfer'),
        actions: const [LogoutAction()],
      ),
      body: Obx(() {
        if (controller.isCheckingActiveRequest.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.hasActiveRequest.value) {
          return const _ActiveRequestBlockedView();
        }
        if (controller.submitted.value) {
          return const _SubmittedConfirmationView();
        }
        return const _SubmissionForm();
      }),
    );
  }
}

void _goToStatusPage() {
  Get.offAll(
    () => const TransferRequestStatusPage(),
    binding: TransferRequestStatusBinding(),
  );
}

class _ActiveRequestBlockedView extends StatelessWidget {
  const _ActiveRequestBlockedView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You already have a transfer request in progress. '
              'You can have only one active request at a time.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _goToStatusPage,
              child: const Text('View Status'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmittedConfirmationView extends StatelessWidget {
  const _SubmittedConfirmationView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, size: 48),
            const SizedBox(height: 16),
            Text(
              'Your transfer request has been submitted.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _goToStatusPage,
              child: const Text('View Status'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmissionForm extends GetView<TransferRequestSubmissionController> {
  const _SubmissionForm();

  Future<void> _pickEffectiveDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (picked != null) controller.setEffectiveDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(
            () => DropdownButtonFormField<String>(
              key: const Key('department-dropdown'),
              initialValue: controller.departmentId.value,
              decoration: InputDecoration(
                labelText: 'Proposed department',
                errorText: controller.departmentError.value,
              ),
              items: ReferenceData.departments
                  .map((o) => DropdownMenuItem(value: o.id, child: Text(o.label)))
                  .toList(),
              onChanged: controller.setDepartment,
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => DropdownButtonFormField<String>(
              key: const Key('location-dropdown'),
              initialValue: controller.locationId.value,
              decoration: InputDecoration(
                labelText: 'Proposed location',
                errorText: controller.locationError.value,
              ),
              items: ReferenceData.locations
                  .map((o) => DropdownMenuItem(value: o.id, child: Text(o.label)))
                  .toList(),
              onChanged: controller.setLocation,
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => DropdownButtonFormField<String>(
              key: const Key('role-dropdown'),
              initialValue: controller.roleId.value,
              decoration: InputDecoration(
                labelText: 'Proposed role',
                errorText: controller.roleError.value,
              ),
              items: ReferenceData.roles
                  .map((o) => DropdownMenuItem(value: o.id, child: Text(o.label)))
                  .toList(),
              onChanged: controller.setRole,
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => InkWell(
              key: const Key('effective-date-field'),
              onTap: () => _pickEffectiveDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Effective date',
                  errorText: controller.effectiveDateError.value,
                ),
                child: Text(
                  controller.effectiveDate.value == null
                      ? 'Select a date'
                      : DateFormat.yMMMd().format(controller.effectiveDate.value!),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('reason-field'),
            controller: controller.reasonController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Reason (optional)',
            ),
          ),
          const SizedBox(height: 24),
          Obx(
            () => ElevatedButton(
              onPressed: controller.isSubmitting.value
                  ? null
                  : () => controller.submit(),
              child: controller.isSubmitting.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit'),
            ),
          ),
          Obx(
            () => controller.submissionError.value == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      controller.submissionError.value!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
