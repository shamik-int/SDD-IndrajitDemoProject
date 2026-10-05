// Gate 2 G2-15, AC23 — the request loads but its history does not: the
// History section says so instead of looking empty.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employee_transfer_project/core/local_db/in_memory_local_db_service.dart';
import 'package:employee_transfer_project/core/result/result.dart';
import 'package:employee_transfer_project/domain/transfer/repositories/transfer_request_repository.dart';
import 'package:employee_transfer_project/domain/transfer/usecases/transfer_usecases.dart';
import 'package:employee_transfer_project/presentation/transfer/employee/request_detail_controller.dart';
import 'package:employee_transfer_project/presentation/transfer/employee/request_detail_page.dart';
import 'package:employee_transfer_project/presentation/transfer/shared/session_state.dart';

import '../../support/transfer_env.dart';
import '../../support/transfer_fixtures.dart';

class _MockRepository extends Mock implements TransferRequestRepository {}

void main() {
  testWidgets('G2-15: history load fails → error shown in the History section; request still shown', (tester) async {
    const failure = 'Local read failed: simulated';
    final env = await TransferEnv.create(InMemoryLocalDbService());
    final request = await env.submitAs(employeeA.userId);
    final repository = _MockRepository();
    when(() => repository.getMyTransferRequest(request.requestId)).thenAnswer((_) async => Result.success(request));
    when(() => repository.getRequestHistory(request.requestId)).thenAnswer((_) async => Result.error(failure));

    Get.testMode = true;
    Get.reset();
    addTearDown(Get.reset);
    Get.put(SessionState());
    Get.put(RequestDetailController(
      getRequest: GetMyTransferRequest(repository),
      getHistory: GetRequestHistory(repository),
      refs: env.refs,
      clock: env.clock,
      requestId: request.requestId,
    ));
    await tester.pumpWidget(const GetMaterialApp(home: RequestDetailPage()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('detail-status')), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('history-error'))).data, failure);
  });
}
