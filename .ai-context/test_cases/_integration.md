# Integration / Cross-Flow Test Index

## employee-internal-transfer (spec v2.4, plan v4.0)
| ID | Scenario | Test |
|---|---|---|
| XF01–XF09 | Cross-flow scenarios from spec v2.4, over the real repository, demo portal adapters and real Hive, with an adjustable clock | `test/integration/cross_flow_test.dart` (`flutter test`) |
| IT01 | Full journey through the real UI and real Hive: employee submits, tester records every outcome, employee sees the COMPLETED confirmation | `integration_test/transfer_journey_test.dart` (`flutter test integration_test -d macos`) |

Scenario details and the UT mapping: `employee-internal-transfer.test_cases.md`.
The v1.5 index is kept as `_integration-v1.5-backup-2026-09-30.md`.

## employee-registration-login
Not followed (BRD-002 is version control only). Its Register screen is not
part of the V1 app (plan v4.0 PD-01).
