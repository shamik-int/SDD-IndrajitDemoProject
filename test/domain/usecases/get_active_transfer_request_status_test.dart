import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employee_transfer_project/core/result/result.dart';
import 'package:employee_transfer_project/domain/entities/transfer_request.dart';
import 'package:employee_transfer_project/domain/entities/transfer_request_status.dart';
import 'package:employee_transfer_project/domain/repositories/transfer_request_repository.dart';
import 'package:employee_transfer_project/domain/usecases/get_active_transfer_request_status.dart';

class MockTransferRequestRepository extends Mock
    implements TransferRequestRepository {}

void main() {
  late MockTransferRequestRepository repository;
  late GetActiveTransferRequestStatus usecase;

  setUp(() {
    repository = MockTransferRequestRepository();
    usecase = GetActiveTransferRequestStatus(repository);
  });

  test('returns success(null) when the repository has no active request', () async {
    when(
      () => repository.getActive(),
    ).thenAnswer((_) async => Result<TransferRequest?>.success(null));

    final result = await usecase();

    expect(result.isSuccess, isTrue);
    expect(result.data, isNull);
    verify(() => repository.getActive()).called(1);
  });

  test('returns the active request when one exists', () async {
    final now = DateTime(2026, 9, 15);
    final active = TransferRequest(
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
      () => repository.getActive(),
    ).thenAnswer((_) async => Result<TransferRequest?>.success(active));

    final result = await usecase();

    expect(result.data, active);
  });
}
