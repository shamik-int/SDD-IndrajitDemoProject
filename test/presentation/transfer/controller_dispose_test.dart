// Gate 2 G2-04 — constitution Testing Discipline: every controller disposes
// what it owns in onClose(). Checked directly, because leak_tracker only
// reliably reports an undisposed object that is still reachable when the
// test ends, and these controllers are deleted before that.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:employee_transfer_project/core/local_db/in_memory_local_db_service.dart';
import 'package:employee_transfer_project/domain/transfer/usecases/transfer_usecases.dart';
import 'package:employee_transfer_project/presentation/transfer/employee/transfer_form_controller.dart';
import 'package:employee_transfer_project/presentation/transfer/shared/session_state.dart';
import 'package:employee_transfer_project/presentation/transfer/shared/sign_in_controller.dart';

import '../../support/transfer_env.dart';

void main() {
  late TransferEnv env;

  setUp(() async {
    Get.testMode = true;
    Get.reset();
    env = await TransferEnv.create(InMemoryLocalDbService());
  });
  tearDown(Get.reset);

  void expectDisposed(ChangeNotifier notifier) =>
      expect(() => notifier.addListener(() {}), throwsFlutterError, reason: 'used after dispose must assert');

  test('SignInController.onClose disposes both text controllers', () async {
    final c = Get.put(SignInController(signInService: env.auth, session: SessionState()));
    await Get.delete<SignInController>();

    expectDisposed(c.emailController);
    expectDisposed(c.passwordController);
  });

  test('TransferFormController.onClose disposes the reason controller', () async {
    final repo = env.repository;
    final c = Get.put(TransferFormController(
      getActive: GetMyActiveTransferRequest(repo),
      getCurrentValues: GetMyCurrentValues(repo),
      submitTransferRequest: SubmitTransferRequest(repo),
      refs: env.refs,
      clock: env.clock,
    ));
    await Get.delete<TransferFormController>();

    expectDisposed(c.reasonController);
  });
}
