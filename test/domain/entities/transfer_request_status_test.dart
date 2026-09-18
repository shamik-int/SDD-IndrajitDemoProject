import 'package:flutter_test/flutter_test.dart';

import 'package:employee_transfer_project/domain/entities/transfer_request_status.dart';

void main() {
  group('TransferRequestStatus.isTerminal', () {
    test('completed is terminal', () {
      expect(TransferRequestStatus.completed.isTerminal, isTrue);
    });

    test('rejectedByManager is terminal', () {
      expect(TransferRequestStatus.rejectedByManager.isTerminal, isTrue);
    });

    test('rejectedByHr is terminal', () {
      expect(TransferRequestStatus.rejectedByHr.isTerminal, isTrue);
    });

    test('pendingManagerApproval is not terminal', () {
      expect(TransferRequestStatus.pendingManagerApproval.isTerminal, isFalse);
    });

    test('pendingHrValidation is not terminal', () {
      expect(TransferRequestStatus.pendingHrValidation.isTerminal, isFalse);
    });

    test('pendingDownstreamUpdates is not terminal', () {
      expect(TransferRequestStatus.pendingDownstreamUpdates.isTerminal, isFalse);
    });
  });
}
