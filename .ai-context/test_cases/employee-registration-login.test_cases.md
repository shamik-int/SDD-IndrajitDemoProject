# Test Cases: Employee Registration & Login

_QA-expanded version of `specs/employee-registration-login.spec.md`'s own
Unit Test Cases table (Blueprint §19.1)._

## Spec-derived (mirrors employee-registration-login.spec.md)
| Test ID | Maps to AC | Scenario | Expected |
|---|---|---|---|
| employee-registration-login.UT01 | AC3 | Register with all valid fields | `Result.success`, session set |
| employee-registration-login.UT02 | AC4 | Register with name missing | `Result.error`, field-level message, no account created |
| employee-registration-login.UT03 | AC4 | Register with malformed email | `Result.error`, "valid email address" |
| employee-registration-login.UT04 | AC4 | Register with a 4-character password | `Result.error`, complexity message |
| employee-registration-login.UT05 | AC5 | Register with an already-registered email | `Result.error`, "already exists", no second account created |
| employee-registration-login.UT06 | AC6 | Login with correct email + password | `Result.success`, session set |
| employee-registration-login.UT07 | AC7 | Login with an unregistered email | `Result.error`, "Invalid email or password." |
| employee-registration-login.UT08 | AC7 | Login with a registered email, wrong password | `Result.error`, identical message as UT07 |
| employee-registration-login.UT09 | AC1, AC8 | `getCurrentSession` with no prior login | `Result.success(null)` |
| employee-registration-login.UT10 | AC8 | Logout after a successful login | Session cleared; account/request data untouched |
| employee-registration-login.UT11 | AC9 | Two accounts register and each submits a transfer request | Each account's active-request check is independent |

## Additional QA coverage (not individually AC-mapped, still in scope)
| Test ID | Scenario | Expected |
|---|---|---|
| employee-registration-login.QA01 | Register, log out, then log back in with the same credentials | Login succeeds, same account/profile fields returned |
| employee-registration-login.QA02 | Email comparison is case-insensitive (`A@x.com` vs `a@x.com`) | Treated as the same account for uniqueness and login |
| employee-registration-login.QA03 | Password exactly 8 characters, one letter, one number | Accepted (boundary case for AC4's complexity rule) |
| employee-registration-login.QA04 | Password 7 characters, otherwise valid | Rejected (boundary case) |
| employee-registration-login.QA05 | Two different registered accounts, each logs in on a fresh app instance | `getCurrentSession()` reflects only the most recently logged-in account, never both |
| employee-registration-login.QA06 | Attempt to log in with correct email but empty password | `Result.error`, same generic invalid-credentials message |
| employee-registration-login.QA07 | Uninstall/reinstall the app (or clear app data) | All registered accounts and sessions are gone — same accepted local-only limitation as `employee-internal-transfer.QA14` (ADR-0004/0005) |

## Cross-feature / integration
_See `.ai-context/test_cases/_integration.md` for the full journey once
`employee-internal-transfer` adds `employeeId` scoping: register/login →
submit a transfer request → log out → log back in → status still visible →
a second account never sees the first account's request._
