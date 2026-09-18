import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employee_transfer_project/core/result/result.dart';
import 'package:employee_transfer_project/domain/entities/transfer_request.dart';
import 'package:employee_transfer_project/domain/entities/transfer_request_status.dart';
import 'package:employee_transfer_project/domain/repositories/transfer_request_repository.dart';
import 'package:employee_transfer_project/domain/usecases/get_transfer_request_by_id.dart';

class MockTransferRequestRepository extends Mock
    implements TransferRequestRepository {}

void main() {
  late MockTransferRequestRepository repository;
  late GetTransferRequestById usecase;

  setUp(() {
    repository = MockTransferRequestRepository();
    usecase = GetTransferRequestById(repository);
  });

  test('delegates to repository.getById with the given id', () async {
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
      () => repository.getById('req-1'),
    ).thenAnswer((_) async => Result.success(expected));

    final result = await usecase('req-1');

    expect(result, Result<TransferRequest>.success(expected));
    verify(() => repository.getById('req-1')).called(1);
  });

  test('propagates a Result.error when the id is not found', () async {
    when(
      () => repository.getById('missing'),
    ).thenAnswer((_) async => Result.error('No request found for this ID.'));

    final result = await usecase('missing');

    expect(result.isError, isTrue);
  });
}
