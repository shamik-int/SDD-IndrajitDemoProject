import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/validators.dart';
import '../../domain/entities/submit_transfer_request_input.dart';
import '../../domain/usecases/get_active_transfer_request_status.dart';
import '../../domain/usecases/submit_transfer_request.dart';

/// Drives the submission screen — AC1 (capture fields), AC2 (block a second
/// concurrent request), AC3 (successful submit), AC4/AC5 (validation).
class TransferRequestSubmissionController extends GetxController {
  final SubmitTransferRequest submitTransferRequest;
  final GetActiveTransferRequestStatus getActiveTransferRequestStatus;

  TransferRequestSubmissionController({
    required this.submitTransferRequest,
    required this.getActiveTransferRequestStatus,
  });

  final isCheckingActiveRequest = true.obs;
  final hasActiveRequest = false.obs;

  final departmentId = RxnString();
  final locationId = RxnString();
  final roleId = RxnString();
  final effectiveDate = Rx<DateTime?>(null);
  final reasonController = TextEditingController();

  final departmentError = RxnString();
  final locationError = RxnString();
  final roleError = RxnString();
  final effectiveDateError = RxnString();

  final isSubmitting = false.obs;
  final submissionError = RxnString();
  final submitted = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkActiveRequest();
  }

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }

  Future<void> _checkActiveRequest() async {
    isCheckingActiveRequest.value = true;
    final result = await getActiveTransferRequestStatus();
    hasActiveRequest.value = result.isSuccess && result.data != null;
    isCheckingActiveRequest.value = false;
  }

  void setDepartment(String? value) {
    departmentId.value = value;
    departmentError.value = null;
  }

  void setLocation(String? value) {
    locationId.value = value;
    locationError.value = null;
  }

  void setRole(String? value) {
    roleId.value = value;
    roleError.value = null;
  }

  void setEffectiveDate(DateTime? value) {
    effectiveDate.value = value;
    effectiveDateError.value = null;
  }

  bool _validate() {
    var valid = true;

    departmentError.value = Validators.required(
      departmentId.value,
      fieldName: 'Department',
    );
    if (departmentError.value != null) valid = false;

    locationError.value = Validators.required(
      locationId.value,
      fieldName: 'Location',
    );
    if (locationError.value != null) valid = false;

    roleError.value = Validators.required(roleId.value, fieldName: 'Role');
    if (roleError.value != null) valid = false;

    // QA13 (reassigned from T02): effectiveDate is a non-null DateTime once
    // set, so "missing" can only be observed here, before it's ever set.
    if (effectiveDate.value == null) {
      effectiveDateError.value = 'Please select an effective date.';
      valid = false;
    } else if (!effectiveDate.value!.isAfter(DateTime.now())) {
      effectiveDateError.value = 'Effective date must be in the future.';
      valid = false;
    }

    return valid;
  }

  Future<bool> submit() async {
    if (!_validate()) return false;

    isSubmitting.value = true;
    submissionError.value = null;

    final reason = reasonController.text.trim();
    final input = SubmitTransferRequestInput(
      departmentId: departmentId.value!,
      locationId: locationId.value!,
      roleId: roleId.value!,
      effectiveDate: effectiveDate.value!,
      reason: reason.isEmpty ? null : reason,
    );

    final result = await submitTransferRequest(input);
    isSubmitting.value = false;

    if (result.isError) {
      submissionError.value = result.message;
      return false;
    }

    submitted.value = true;
    return true;
  }
}
