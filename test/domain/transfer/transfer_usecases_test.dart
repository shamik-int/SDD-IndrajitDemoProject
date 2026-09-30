// employee-internal-transfer.T03 — usecases delegate to the repository contract.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employee_transfer_project/core/result/result.dart';
import 'package:employee_transfer_project/domain/transfer/entities/enums.dart';
import 'package:employee_transfer_project/domain/transfer/entities/inputs.dart';
import 'package:employee_transfer_project/domain/transfer/entities/transfer_request.dart';
import 'package:employee_transfer_project/domain/transfer/repositories/transfer_request_repository.dart';
import 'package:employee_transfer_project/domain/transfer/usecases/transfer_usecases.dart';

import '../../support/transfer_fixtures.dart';

class _MockRepository extends Mock implements TransferRequestRepository {}

void main() {
  late _MockRepository repository;

  setUpAll(() {
    registerFallbackValue(submitInput());
    registerFallbackValue(const RecordOutcomeInput(requestId: 'r', stepId: StepId.managerApproval, outcome: Outcome.approved));
  });

  setUp(() => repository = _MockRepository());

  test('each usecase calls its operation once and returns its result', () async {
    when(() => repository.submitTransferRequest(any())).thenAnswer((_) async => Result.error('x'));
    when(() => repository.getMyActiveTransferRequest()).thenAnswer((_) async => Result.success(const ActiveState()));
    when(() => repository.listMyTransferRequests()).thenAnswer((_) async => Result.success(const []));
    when(() => repository.getMyTransferRequest('r')).thenAnswer((_) async => Result.error('n'));
    when(() => repository.getRequestHistory('r')).thenAnswer((_) async => Result.success(const []));
    when(() => repository.recordStakeholderOutcome(any())).thenAnswer((_) async => Result.error('t'));
    when(() => repository.listOpenStakeholderTasks()).thenAnswer((_) async => Result.success(const []));
    when(() => repository.getMyCurrentValues()).thenAnswer((_) async => Result.success(baseCurrent));

    expect((await SubmitTransferRequest(repository)(submitInput())).message, 'x');
    expect((await GetMyActiveTransferRequest(repository)()).data!.canSubmit, isTrue);
    expect((await ListMyTransferRequests(repository)()).data, isEmpty);
    expect((await GetMyTransferRequest(repository)('r')).message, 'n');
    expect((await GetRequestHistory(repository)('r')).data, isEmpty);
    expect(
      (await RecordStakeholderOutcome(repository)(
        const RecordOutcomeInput(requestId: 'r', stepId: StepId.managerApproval, outcome: Outcome.approved),
      )).message,
      't',
    );
    expect((await ListOpenStakeholderTasks(repository)()).data, isEmpty);
    expect((await GetMyCurrentValues(repository)()).data, baseCurrent);

    verify(() => repository.submitTransferRequest(any())).called(1);
    verify(() => repository.recordStakeholderOutcome(any())).called(1);
  });
}
