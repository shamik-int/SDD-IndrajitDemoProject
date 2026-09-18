import 'package:flutter_test/flutter_test.dart';

import 'package:employee_transfer_project/core/result/result.dart';
import 'package:employee_transfer_project/core/result/status.dart';

void main() {
  test('Result.success carries data and success status', () {
    final result = Result<int>.success(42);
    expect(result.status, Status.success);
    expect(result.isSuccess, isTrue);
    expect(result.data, 42);
  });

  test('Result.error carries a message and error status', () {
    final result = Result<int>.error('failed');
    expect(result.status, Status.error);
    expect(result.isError, isTrue);
    expect(result.message, 'failed');
  });

  test('Result.inProgress carries no data', () {
    const result = Result<int>.inProgress();
    expect(result.status, Status.inProgress);
    expect(result.isInProgress, isTrue);
    expect(result.data, isNull);
  });
}
