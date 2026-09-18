import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Global, feature-agnostic UI helpers — toast and loader — per ADR-0001 §7.
/// No business logic here; feature-specific messaging lives in
/// `core/constants/app_strings.dart`.
class CommonUtils {
  CommonUtils._();

  static void showToast(String message, {bool isError = false}) {
    Get.snackbar(
      isError ? 'Error' : 'Notice',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  static void showLoader({String message = 'Please wait...'}) {
    if (Get.isDialogOpen ?? false) return;
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 16),
                  Text(message),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void hideLoader() {
    if (Get.isDialogOpen ?? false) Get.back();
  }
}
