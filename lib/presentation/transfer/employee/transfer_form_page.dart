import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/transfer_messages.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/transfer/portal/portal_contracts.dart';
import '../../widgets/demo_banner.dart';
import '../shared/sign_out_action.dart';
import 'transfer_form_controller.dart';

class TransferFormPage extends GetView<TransferFormController> {
  const TransferFormPage({super.key});

  Future<void> _submit() async {
    final request = await controller.submit();
    if (request != null) {
      Get.offNamed(AppRoutes.requestDetail, arguments: {'requestId': request.requestId, 'justSubmitted': true});
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final today = controller.clock.today();
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.effectiveDate.value ?? today.add(const Duration(days: 1)),
      firstDate: today.add(const Duration(days: 1)),
      lastDate: DateTime(2100),
    );
    if (picked != null) controller.setEffectiveDate(picked);
  }

  Widget _dropdown(String key, String label, String field, RxnString value, List<ReferenceItem> items) {
    return Obx(
      () => DropdownButtonFormField<String>(
        key: Key(key),
        initialValue: value.value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label, errorText: controller.fieldErrors[field]),
        items: [for (final i in items) DropdownMenuItem(value: i.id, child: Text(i.name))],
        onChanged: (v) => value.value = v,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final refs = controller.refs;
    final errorStyle = TextStyle(color: Theme.of(context).colorScheme.error);
    return Scaffold(
      appBar: AppBar(title: const Text('New transfer request'), actions: const [SignOutAction()]),
      body: Column(
        children: [
          const DemoBanner(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
              if (controller.blockedMessage.value != null) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(controller.blockedMessage.value!, key: const Key('form-blocked-message')),
                );
              }
              final c = controller.current.value!;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      key: const Key('current-values'),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Your current details', style: Theme.of(context).textTheme.titleSmall),
                            const SizedBox(height: 8),
                            Text('Department: ${refs.departmentName(c.departmentId)}'),
                            Text('Location: ${refs.locationName(c.locationId)}'),
                            Text('Role: ${refs.roleName(c.roleId)}'),
                            Text('Manager: ${c.managerName}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _dropdown('form-department', 'Proposed department / business unit', 'department',
                        controller.departmentId, refs.departments()),
                    const SizedBox(height: 12),
                    _dropdown('form-location', 'Proposed location', 'location', controller.locationId, refs.locations()),
                    const SizedBox(height: 12),
                    _dropdown('form-role', 'Proposed role', 'role', controller.roleId, refs.roles()),
                    const SizedBox(height: 12),
                    Obx(
                      () => InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Effective date',
                          errorText: controller.fieldErrors['effectiveDate'],
                        ),
                        child: InkWell(
                          key: const Key('form-effective-date'),
                          onTap: () => _pickDate(context),
                          child: Text(
                            controller.effectiveDate.value == null
                                ? 'Choose a date'
                                : LocalDate.format(controller.effectiveDate.value!),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => TextField(
                        key: const Key('form-reason'),
                        controller: controller.reasonController,
                        maxLength: TransferMessages.maxReasonLength,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Reason (optional)',
                          errorText: controller.fieldErrors['reason'],
                        ),
                      ),
                    ),
                    Obx(
                      () => controller.fieldErrors['form'] == null
                          ? const SizedBox.shrink()
                          : Text(controller.fieldErrors['form']!, style: errorStyle),
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => ElevatedButton(
                        key: const Key('form-submit'),
                        onPressed: controller.isSubmitting.value ? null : _submit,
                        child: const Text('Submit request'),
                      ),
                    ),
                    Obx(
                      () => controller.formError.value == null
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(controller.formError.value!, style: errorStyle),
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
