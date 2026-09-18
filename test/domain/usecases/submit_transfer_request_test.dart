import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employee_transfer_project/core/result/result.dart';
import 'package:employee_transfer_project/domain/entities/submit_transfer_request_input.dart';
import 'package:employee_transfer_project/domain/entities/transfer_request.dart';
import 'package:employee_transfer_project/domain/entities/transfer_request_status.dart';
import 'package:employee_transfer_project/domain/repositories/transfer_request_repository.dart';
import 'package:employee_transfer_project/domain/usecases/submit_transfer_request.dart';

class MockTransferRequestRepository extends Mock
    implements TransferRequestRepository {}

void main() {
  late MockTransferRequestRepository repository;
  late SubmitTransferRequest usecase;

  final input = SubmitTransferRequestInput(
    departmentId: 'dept-1',
    locationId: 'loc-1',
    roleId: 'role-1',
    effectiveDate: DateTime(2026, 11, 1),
  );

  setUp(() {
    repository = MockTransferRequestRepository();
    usecase = SubmitTransferRequest(repository);
  });

  test('delegates to repository.submit with the given input', () async {
    final now = DateTime(2026, 9, 15);
    final expected = TransferRequest(
      id: 'req-1',
      departmentId: 'dept-1',
      locationId: 'loc-1',
      roleId: 'role-1',
      effectiveDate: DateTime(2026, 11, 1),
      status: TransferRequestStatus.pendingManagerApproval,
      stakeholders: const {},
      submittedAt: now,
      updatedAt: now,
    );
    when(
      () => repository.submit(input),
    ).thenAnswer((_) async => Result.success(expected));

    final result = await usecase(input);

    expect(result, Result<TransferRequest>.success(expected));
    verify(() => repository.submit(input)).called(1);
  });

  test('propagates a Result.error from the repository unchanged', () async {
    when(() => repository.submit(input)).thenAnswer(
      (_) async =>
          Result.error('You already have a transfer request in progress.'),
    );

    final result = await usecase(input);

    expect(result.isError, isTrue);
    expect(result.message, 'You already have a transfer request in progress.');
  });
}
