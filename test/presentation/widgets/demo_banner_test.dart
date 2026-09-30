// employee-internal-transfer.T01 — AC28 indicator widget (used by UT43 on each screen).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:employee_transfer_project/core/constants/transfer_messages.dart';
import 'package:employee_transfer_project/presentation/widgets/demo_banner.dart';

void main() {
  testWidgets('shows "Demo — test data only"', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DemoBanner())));
    expect(find.text(TransferMessages.demoIndicator), findsOneWidget);
    expect(TransferMessages.demoIndicator, 'Demo — test data only');
  });
}
