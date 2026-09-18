// Exercises employee-internal-transfer.UT01–UT14 and the relevant QA cases
// (test_cases/employee-internal-transfer.test_cases.md) against a real,
// temp-directory-backed Hive instance — not a mock. The datasource is thin
// enough that testing through the real persistence layer is more faithful
// than mocking it, and this is where nearly all of T02's actual behavior
// lives (ADR-0004: Hive is the system of record, not a cache).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:employee_transfer_project/core/local_db/local_db_service.dart';
import 'package:employee_transfer_project/data/datasources/local/transfer_request_local_datasource.dart';
import 'package:employee_transfer_project/data/repositories/transfer_request_repository_impl.dart';
import 'package:employee_transfer_project/domain/entities/stakeholder.dart';
import 'package:employee_transfer_project/domain/entities/stakeholder_decision.dart';
import 'package:employee_transfer_project/domain/entities/submit_transfer_request_input.dart';
import 'package:employee_transfer_project/domain/entities/transfer_request_status.dart';

void main() {
  late Directory tempDir;
  late TransferRequestRepositoryImpl repository;

  SubmitTransferRequestInput validInput({DateTime? effectiveDate, String? reason}) {
    return SubmitTransferRequestInput(
      departmentId: 'dept-1',
      locationId: 'loc-1',
      roleId: 'role-1',
      effectiveDate: effectiveDate ?? DateTime.now().add(const Duration(days: 30)),
      reason: reason,
    );
  }

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('eit_hive_test_');
    Hive.init(tempDir.path);
    final localDb = LocalDbService();
    final dataSource = TransferRequestLocalDataSource(localDb);
    repository = TransferRequestRepositoryImpl(dataSource);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('submit — UT01, UT02, UT03, UT04, UT05, QA01, QA02, QA11, QA12', () {
    test('UT01: valid fields + future date succeeds as PENDING_MANAGER_APPROVAL', () async {
      final result = await repository.submit(validInput());

      expect(result.isSuccess, isTrue);
      expect(result.data!.status, TransferRequestStatus.pendingManagerApproval);
      expect(result.data!.pendingStakeholders, [Stakeholder.manager]);
    });

    test('UT02: departmentId missing (blank) fails, no record created', () async {
      final result = await repository.submit(
        SubmitTransferRequestInput(
          departmentId: '',
          locationId: 'loc-1',
          roleId: 'role-1',
          effectiveDate: DateTime.now().add(const Duration(days: 30)),
        ),
      );

      expect(result.isError, isTrue);
      final active = await repository.getActive();
      expect(active.data, isNull);
    });

    test('QA11: locationId missing (blank) fails, names locationId', () async {
      final result = await repository.submit(
        SubmitTransferRequestInput(
          departmentId: 'dept-1',
          locationId: '',
          roleId: 'role-1',
          effectiveDate: DateTime.now().add(const Duration(days: 30)),
        ),
      );

      expect(result.isError, isTrue);
      expect(result.message, contains('Location'));
    });

    test('QA12: roleId missing (blank) fails, names roleId', () async {
      final result = await repository.submit(
        SubmitTransferRequestInput(
          departmentId: 'dept-1',
          locationId: 'loc-1',
          roleId: '',
          effectiveDate: DateTime.now().add(const Duration(days: 30)),
        ),
      );

      expect(result.isError, isTrue);
      expect(result.message, contains('Role'));
    });

    test('UT03: effectiveDate = today fails', () async {
      final result = await repository.submit(validInput(effectiveDate: DateTime.now()));
      expect(result.isError, isTrue);
      expect(result.message, contains('future'));
    });

    test('UT04: effectiveDate in the past fails', () async {
      final result = await repository.submit(
        validInput(effectiveDate: DateTime.now().subtract(const Duration(days: 1))),
      );
      expect(result.isError, isTrue);
    });

    test('QA01: effectiveDate exactly one day in the future succeeds', () async {
      final result = await repository.submit(
        validInput(effectiveDate: DateTime.now().add(const Duration(days: 1, hours: 1))),
      );
      expect(result.isSuccess, isTrue);
    });

    test('QA02: reason left blank (null) succeeds', () async {
      final result = await repository.submit(validInput(reason: null));
      expect(result.isSuccess, isTrue);
    });

    test('UT05 / QA03: submitting while a non-terminal request exists fails, no second record', () async {
      final first = await repository.submit(validInput());
      expect(first.isSuccess, isTrue);

      final second = await repository.submit(validInput());
      expect(second.isError, isTrue);

      final active = await repository.getActive();
      expect(active.data!.id, first.data!.id);
    });
  });

  group('getById — QA05', () {
    test('QA05: unknown id fails', () async {
      final result = await repository.getById('does-not-exist');
      expect(result.isError, isTrue);
    });

    test('returns the matching record for a known id', () async {
      final submitted = await repository.submit(validInput());
      final fetched = await repository.getById(submitted.data!.id);
      expect(fetched.data, submitted.data);
    });
  });

  group('getActive — QA06', () {
    test('QA06: no active request returns success(null)', () async {
      final result = await repository.getActive();
      expect(result.isSuccess, isTrue);
      expect(result.data, isNull);
    });
  });

  group('recordStakeholderDecision — manager stage (UT07, UT08, UT13, UT14)', () {
    test('UT08: manager approves moves to PENDING_HR_VALIDATION, HR pending', () async {
      final submitted = await repository.submit(validInput());

      final result = await repository.recordStakeholderDecision(
        requestId: submitted.data!.id,
        stakeholder: Stakeholder.manager,
        decision: StakeholderDecision.approved,
      );

      expect(result.data!.status, TransferRequestStatus.pendingHrValidation);
      expect(result.data!.pendingStakeholders, [Stakeholder.hr]);
    });

    test('UT07: manager rejects moves to REJECTED_BY_MANAGER, nothing pending', () async {
      final submitted = await repository.submit(validInput());

      final result = await repository.recordStakeholderDecision(
        requestId: submitted.data!.id,
        stakeholder: Stakeholder.manager,
        decision: StakeholderDecision.rejected,
      );

      expect(result.data!.status, TransferRequestStatus.rejectedByManager);
      expect(result.data!.pendingStakeholders, isEmpty);
    });

    test('UT13: after a manager rejection, a new request can be submitted', () async {
      final submitted = await repository.submit(validInput());
      await repository.recordStakeholderDecision(
        requestId: submitted.data!.id,
        stakeholder: Stakeholder.manager,
        decision: StakeholderDecision.rejected,
      );

      final second = await repository.submit(validInput());

      expect(second.isSuccess, isTrue);
      expect(second.data!.id, isNot(submitted.data!.id));
    });

    test('UT14: an HR decision while still PENDING_MANAGER_APPROVAL fails', () async {
      final submitted = await repository.submit(validInput());

      final result = await repository.recordStakeholderDecision(
        requestId: submitted.data!.id,
        stakeholder: Stakeholder.hr,
        decision: StakeholderDecision.approved,
      );

      expect(result.isError, isTrue);
    });
  });

  group('recordStakeholderDecision — HR stage (UT09, UT10)', () {
    Future<String> submitAndApproveManager() async {
      final submitted = await repository.submit(validInput());
      await repository.recordStakeholderDecision(
        requestId: submitted.data!.id,
        stakeholder: Stakeholder.manager,
        decision: StakeholderDecision.approved,
      );
      return submitted.data!.id;
    }

    test('UT10: HR approves moves to PENDING_DOWNSTREAM_UPDATES, Payroll/IT/Facilities pending', () async {
      final id = await submitAndApproveManager();

      final result = await repository.recordStakeholderDecision(
        requestId: id,
        stakeholder: Stakeholder.hr,
        decision: StakeholderDecision.approved,
      );

      expect(result.data!.status, TransferRequestStatus.pendingDownstreamUpdates);
      expect(result.data!.pendingStakeholders, [
        Stakeholder.payroll,
        Stakeholder.it,
        Stakeholder.facilities,
      ]);
    });

    test('UT09: HR rejects moves to REJECTED_BY_HR, nothing pending', () async {
      final id = await submitAndApproveManager();

      final result = await repository.recordStakeholderDecision(
        requestId: id,
        stakeholder: Stakeholder.hr,
        decision: StakeholderDecision.rejected,
      );

      expect(result.data!.status, TransferRequestStatus.rejectedByHr);
      expect(result.data!.pendingStakeholders, isEmpty);
    });

    test('QA15: a Manager decision while PENDING_HR_VALIDATION fails', () async {
      final id = await submitAndApproveManager();

      final result = await repository.recordStakeholderDecision(
        requestId: id,
        stakeholder: Stakeholder.manager,
        decision: StakeholderDecision.approved,
      );

      expect(result.isError, isTrue);
    });
  });

  group('recordStakeholderDecision — downstream stage (UT11, UT12, QA10, QA16)', () {
    Future<String> submitApproveManagerAndHr() async {
      final submitted = await repository.submit(validInput());
      final id = submitted.data!.id;
      await repository.recordStakeholderDecision(
        requestId: id,
        stakeholder: Stakeholder.manager,
        decision: StakeholderDecision.approved,
      );
      await repository.recordStakeholderDecision(
        requestId: id,
        stakeholder: Stakeholder.hr,
        decision: StakeholderDecision.approved,
      );
      return id;
    }

    test('UT11: Payroll completes; IT and Facilities remain pending', () async {
      final id = await submitApproveManagerAndHr();

      final result = await repository.recordStakeholderDecision(
        requestId: id,
        stakeholder: Stakeholder.payroll,
        decision: StakeholderDecision.completed,
      );

      expect(result.data!.status, TransferRequestStatus.pendingDownstreamUpdates);
      expect(result.data!.pendingStakeholders, [Stakeholder.it, Stakeholder.facilities]);
    });

    test('UT12 / QA10: all three downstream steps complete resolves to COMPLETED', () async {
      final id = await submitApproveManagerAndHr();

      await repository.recordStakeholderDecision(
        requestId: id,
        stakeholder: Stakeholder.payroll,
        decision: StakeholderDecision.completed,
      );
      await repository.recordStakeholderDecision(
        requestId: id,
        stakeholder: Stakeholder.it,
        decision: StakeholderDecision.completed,
      );
      final result = await repository.recordStakeholderDecision(
        requestId: id,
        stakeholder: Stakeholder.facilities,
        decision: StakeholderDecision.completed,
      );

      expect(result.data!.status, TransferRequestStatus.completed);
      expect(result.data!.pendingStakeholders, isEmpty);
    });

    test('QA16: a Manager-style decision (approved) on a downstream stakeholder fails', () async {
      final id = await submitApproveManagerAndHr();

      final result = await repository.recordStakeholderDecision(
        requestId: id,
        stakeholder: Stakeholder.payroll,
        decision: StakeholderDecision.approved,
      );

      expect(result.isError, isTrue);
    });
  });

  group('QA14 — no persistence across a fresh install', () {
    test('a wiped Hive store has no active request', () async {
      await repository.submit(validInput());
      await Hive.deleteFromDisk();

      // Fresh repository over the (now empty) store, simulating reinstall.
      final freshRepository = TransferRequestRepositoryImpl(
        TransferRequestLocalDataSource(LocalDbService()),
      );
      final result = await freshRepository.getActive();

      expect(result.data, isNull);
    });
  });
}
