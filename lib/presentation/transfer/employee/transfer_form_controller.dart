import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/transfer_messages.dart';
import '../../../core/time/clock.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/transfer/entities/inputs.dart';
import '../../../domain/transfer/entities/org_values.dart';
import '../../../domain/transfer/entities/transfer_request.dart';
import '../../../domain/transfer/portal/portal_contracts.dart';
import '../../../domain/transfer/usecases/transfer_usecases.dart';

/// New transfer request form (AC01–AC08, AC34). Client-side checks are a UX
/// aid; the repository re-checks everything (OP01).
class TransferFormController extends GetxController {
  final GetMyActiveTransferRequest getActive;
  final GetMyCurrentValues getCurrentValues;
  final SubmitTransferRequest submitTransferRequest;
  final ReferenceLists refs;
  final Clock clock;
  final String Function() newSubmissionId;

  TransferFormController({
    required this.getActive,
    required this.getCurrentValues,
    required this.submitTransferRequest,
    required this.refs,
    required this.clock,
    String Function()? newSubmissionId,
  }) : newSubmissionId = newSubmissionId ?? const Uuid().v4;

  final isLoading = true.obs;
  final blockedMessage = RxnString();
  final current = Rxn<EmployeeCurrentValues>();
  final departmentId = RxnString();
  final locationId = RxnString();
  final roleId = RxnString();
  final effectiveDate = Rxn<DateTime>();
  final reasonController = TextEditingController();
  final isSubmitting = false.obs;
  final fieldErrors = <String, String>{}.obs;
  final formError = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }

  /// OP02 first: show the OP01 error 5 or 6 before anything is filled in.
  Future<void> load() async {
    isLoading.value = true;
    final active = await getActive();
    if (isClosed) return;
    if (active.isError) {
      blockedMessage.value = active.message;
    } else if (active.data!.inProgress != null) {
      blockedMessage.value = TransferMessages.alreadyInProgress;
    } else if (active.data!.awaitingEffect != null) {
      blockedMessage.value = TransferMessages.awaitingEffect(active.data!.awaitingEffect!.effectiveDate);
    } else {
      final values = await getCurrentValues();
      if (isClosed) return;
      if (values.isError) {
        blockedMessage.value = values.message;
      } else {
        current.value = values.data;
        departmentId.value = values.data!.departmentId;
        locationId.value = values.data!.locationId;
        roleId.value = values.data!.roleId;
      }
    }
    isLoading.value = false;
  }

  void setEffectiveDate(DateTime date) => effectiveDate.value = date;

  bool _validate() {
    final errors = <String, String>{};
    final today = clock.today();

    void need(String field, String? value, String message) {
      final e = Validators.requiredSelection(value, message: message);
      if (e != null) errors[field] = e;
    }

    need('department', departmentId.value, TransferMessages.selectDepartment);
    need('location', locationId.value, TransferMessages.selectLocation);
    need('role', roleId.value, TransferMessages.selectRole);
    final dateError = Validators.futureDate(
      effectiveDate.value,
      today: today,
      missing: TransferMessages.enterEffectiveDate,
      notFuture: TransferMessages.effectiveDateInFuture,
    );
    if (dateError != null) errors['effectiveDate'] = dateError;
    final reasonError = Validators.maxLength(
      reasonController.text.trim(),
      TransferMessages.maxReasonLength,
      message: TransferMessages.reasonTooLong,
    );
    if (reasonError != null) errors['reason'] = reasonError;

    final c = current.value;
    if (c != null &&
        departmentId.value == c.departmentId &&
        locationId.value == c.locationId &&
        roleId.value == c.roleId) {
      errors['form'] = TransferMessages.changeAtLeastOne;
    }

    fieldErrors.assignAll(errors);
    return errors.isEmpty;
  }

  /// Returns the new request, or null. Ignored while a submit is in progress
  /// (AC08); each submit action gets one `submissionId`.
  Future<TransferRequest?> submit() async {
    if (isSubmitting.value) return null;
    formError.value = null;
    if (!_validate()) return null;

    isSubmitting.value = true;
    final result = await submitTransferRequest(SubmitTransferInput(
      submissionId: newSubmissionId(),
      departmentId: departmentId.value,
      locationId: locationId.value,
      roleId: roleId.value,
      effectiveDate: effectiveDate.value,
      reason: reasonController.text,
    ));
    if (isClosed) return result.data;
    isSubmitting.value = false;
    if (result.isError) {
      formError.value = result.message;
      return null;
    }
    return result.data;
  }
}
