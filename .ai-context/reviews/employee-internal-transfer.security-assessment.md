# Security Assessment — employee-internal-transfer (spec v2.4) — Deliverable 8

_Author: Indrajit Bhandari (Author's assessment) | 2026-10-06 | Code assessed:
branch `employee-transfer-request` at `8c02a11` plus the uncommitted re-review
fixes (179/179 tests)._

**Checked against:** `PROJECT_CHECKLIST.md` §6 (Blueprint §30 security
items), `constitution.md` Security Posture, ADR-0002 (runtime hardening),
ADR-0006 (demo identity, data at rest, demo password) and the spec's Security
boundary. The Blueprint PDF could not be opened on this machine (no PDF
reader), so the checklist items were taken from the project's own copies.

## Result: **Not passed — 2 High findings must be fixed first**

The data-handling side is clean: no logging, no secrets anywhere in the code,
config or git history, and no known-vulnerable dependency. The runtime
protection (ADR-0002) is not: on Android, macOS and web the app stops at
start-up because the device-threat check fails, and on iOS the check is set up
with the wrong app ID.

Severity: **High** (fix before any build is shared), **Medium** (fix before
production, or record an accepted risk), **Low** (hardening), **Info**.

## Findings

| ID | Severity | Finding |
|---|---|---|
| SA-01 | **High** | App does not start on Android, macOS or web: the threat-detection start fails before `runApp` |
| SA-02 | **High** | freeRASP iOS config uses the Android package name, not the iOS bundle ID |
| SA-03 | Medium | Release builds are signed with the debug key |
| SA-04 | Medium | Android backup is on by default, so the unencrypted data and session can leave the device |
| SA-05 | Medium | Only 4 of freeRASP's threat types are handled; app tampering is ignored |
| SA-06 | Medium (accepted, pending) | Local data unencrypted; `currentUserId` can be edited to become the tester (ADR-0006 decision 4) |
| SA-07 | Medium (pending) | Demo passwords are short, their hashes are public, one SHA-256 round, no attempt limit (ADR-0006 decision 5, G2-17) |
| SA-08 | Low | No Dart obfuscation configured for release builds |
| SA-09 | Low | `.gitignore` has no rule for iOS signing files (Android keystores are covered) |
| SA-10 | Low | No screenshot / app-switcher protection |
| SA-11 | Info | freeRASP 8.2.2 in use; 8.2.4 available |
| SA-12 | Info | No dedicated SAST tool available; analyzer plus manual review used |

### SA-01 — App does not start on Android, macOS or web (High)
**Where:** `lib/main.dart:39` awaits `SecurityService.start(...)` before
`runApp`; `lib/core/security/security_service.dart:36-49`.
**Evidence:**
- **macOS, real run** (`flutter run -d macos`, 2026-10-06):
  `Unhandled Exception: UnimplementedError: Platform is not supported` at
  `main (main.dart:39)`. The window stays blank.
- **Android:** `AndroidConfig` validates `signingCertHashes` when it is built
  (`freerasp-8.2.2/lib/src/utils/config_verifier.dart`). The placeholder
  `TODO-real-release-signing-cert-hash` is not Base64, so it throws
  `ConfigurationException: SHA256 digest in Base64 is expected` — reproduced
  with a probe test under the Android target platform. Same line of `main`,
  same result: no `runApp`.
- **Web:** freeRASP supports Android and iOS only; `start` throws on any
  other platform.
- **iOS** starts, because the iOS checks only need a non-empty Team ID.

**Why the tests missed it:** IT01 and every widget test build the app
without `main()`.
**Impact:** on Android the app cannot be used at all, and the mandatory
detection (ADR-0002) never runs. Every earlier "it works" run was on iOS.
**Fix (proposed):** start freeRASP only on Android and iOS; catch a start
failure so it cannot stop `runApp`, and treat it as a threat in PROD (fail
closed) and a warning in UAT; add a test that runs the real start-up path
with a failing `SecurityService`. Real signing-cert hash before release
(already a release blocker).

### SA-02 — Wrong iOS bundle ID in freeRASP (High)
**Where:** `security_service.dart:16` and `:42` use
`com.intglobal.employee_transfer_project` for both platforms. The iOS bundle
ID is `com.intglobal.employeeTransferProject`
(`ios/Runner.xcodeproj/project.pbxproj`).
**Impact:** freeRASP's iOS integrity check compares against an ID the app
does not have, so it can report tampering on a genuine build or miss a
re-signed one.
**Fix (proposed):** separate Android and iOS IDs in `SecurityService`, with a
test that pins each to the value in the platform project.

### SA-03 — Release builds signed with the debug key (Medium; release blocker)
**Where:** `android/app/build.gradle.kts:36`,
`signingConfig = signingConfigs.getByName("debug")` (Flutter template).
**Impact:** anyone can sign a modified build that looks the same; freeRASP's
signing-hash check cannot work until a real key exists.
**Fix:** release keystore held outside the repo, loaded from
`key.properties`; add to the Release Checklist.

### SA-04 — Android backup on by default (Medium)
**Where:** `android/app/src/main/AndroidManifest.xml` sets no
`allowBackup` / `dataExtractionRules`, so Android's default (backup on)
applies.
**Impact:** Auto Backup can copy the Hive files — requests, history, and the
`session` box with `currentUserId` — to the user's cloud backup and restore
them on another device, already signed in. With SA-06 the files are readable.
**Fix (proposed):** `android:allowBackup="false"`, or
`dataExtractionRules` that exclude the Hive directory.

### SA-05 — Most freeRASP threat types unhandled (Medium)
**Where:** `security_service.dart:27-34` handles `onPrivilegedAccess`,
`onHooks`, `onDebug`, `onSimulator` — the three ADR-0002 calls mandatory,
plus emulator.
**Impact:** app tampering/re-signing (`onAppIntegrity`), unofficial store
installs, missing obfuscation and similar signals are detected but ignored.
**Fix:** decide per signal in ADR-0002 (at least `onAppIntegrity` →
same response as root).

### SA-06 — Unencrypted local data; session can be edited (Medium, accepted risk pending)
Plain Hive boxes. Anyone with storage access can read the demo data or set
`session.currentUserId` to `tst-001` and act as the tester. Recorded as
ADR-0006 decision 4 (V1 demo data only; encrypt before real data), pending
Tech Lead acceptance. Not re-opened here.

### SA-07 — Demo passwords (Medium, pending)
The committed salts and hashes are for short, memorable passwords (reset
2026-10-05 for team testing); one SHA-256 round; no attempt limit on
sign-in. This does not meet ADR-0006 decision 5 as drafted (long, random,
rotated). Tech Lead to decide before accepting decision 5.

### SA-08 — No Dart obfuscation in release (Low)
No `--obfuscate --split-debug-info` in any build instruction, and no R8
rules. Add to the release build command; freeRASP can then also check it.

### SA-09 — No `.gitignore` rule for iOS signing files (Low)
_Corrected 2026-10-06:_ `android/.gitignore` already ignores
`key.properties`, `*.keystore` and `*.jks`; the first check only read the
root `.gitignore`. Missing: iOS signing files (`*.p12`, `*.mobileprovision`,
`*.cer`). No such file is tracked today (checked).

### SA-10 — No screenshot protection (Low)
No `FLAG_SECURE` on Android and no iOS app-switcher blur. Acceptable for
demo data (BR-25); decide before production.

### SA-11 — freeRASP update available (Info)
8.2.2 in use, 8.2.4 is the latest compatible version. Update with the SA-01
fix and re-check its change log.

### SA-12 — SAST tooling (Info)
No SAST tool (e.g. Semgrep) or OSV scanner is installed here. Used instead:
`flutter analyze` (clean) and the targeted manual review recorded below.
Recommend a SAST step in CI; until then this is an exception for the Tech
Lead to sign off (checklist §6).

## Checks that passed

| Check (checklist §6 / constitution) | How it was checked | Result |
|---|---|---|
| No PII in logs at any level | `grep` of `lib/` for `print`, `debugPrint`, `developer.log`, `log(`, `Logger`, `stdout`/`stderr` | **None.** The only user-facing technical text is the threat-reason toast (no PII) |
| No secrets in code or config | `grep` of `lib/`, `assets/`, `android/app/src`, `ios/Runner` for key, token, secret and private-key patterns; both `.env` files read | **None.** `.env` files hold `ENV_NAME` and `API_BASE_URL` only |
| No secrets in git history | `git log --all -p` for password literals, key patterns and both demo passwords; tracked-file check for keystores, `.p12`, `.pem`, Firebase files | **None found** |
| Passwords never stored in plaintext | `demo_accounts.dart` holds salts and SHA-256 hashes only | **Pass** (strength: SA-07) |
| Dependencies vetted — licence | LICENSE of all 13 direct dependencies | **All permissive:** MIT, Apache-2.0 or BSD-3-Clause |
| Dependencies vetted — advisories | `dart pub outdated --json --show-all` over all 77 resolved packages (direct, dev, transitive) | **No advisory, retraction or discontinued package** |
| Network | No network call in `lib/` (`ApiClient` unregistered, G2-16); no cleartext or ATS exceptions in Android/iOS config | **Pass** |
| Deep links | Android: launcher intent only; iOS: no URL types | **None registered** |
| Access control (app-level) | Repository checks signed in → role → ownership on every operation (Gate 2, XF03, XF07 mutation evidence) | **Pass**, application-level only (spec Security boundary) |
| Session hygiene | Sign-out clears the session and the back stack; failure reported (G2-09) | **Pass** |
| Memory hygiene | `leak_tracker` on every widget test; controller disposal tested (G2-04) | **Pass** |
| N/A items | Server-side authorization and rate limiting: no server (ADR-0004) | **N/A**, as recorded in checklist §6 |

## Not verified

- **Root / jailbreak / Frida detection on a compromised device.** Needs a
  rooted Android device or emulator image, or a jailbroken iPhone. Blocked on
  Android by SA-01 (the app does not start). Available here: an iOS simulator
  and a non-rooted Pixel 9 Pro emulator. To do after the SA-01 and SA-02
  fixes, on a device set up for it.
- **Web build.** Not run; it fails the same way as macOS (SA-01).

## Fixes (2026-10-06)
Platforms: the **macOS app was removed** at the session user's direction
("we only need Android and iOS"); 30 tracked files under `macos/` deleted and
the `macos` entry dropped from `.metadata`.

| ID | Fix | Test (RED → GREEN) |
|---|---|---|
| SA-01 | New `SecurityStartup.run` (`lib/core/security/security_startup.dart`), called from `main`: starts freeRASP only on Android and iOS; a start that fails is reported to `ThreatResponse` as "Device security check could not start." — PROD blocks, UAT warns. `runApp` is always reached. | `test/core/security/security_startup_test.dart` (5 tests), including the **real** `SecurityService.start` under the Android target with the placeholder hash: caught, reported, no exception. RED before the fix: the real macOS run crashed at `main.dart:39`; the new tests did not compile (no `SecurityStartup`). |
| SA-02 | `SecurityService.androidPackageName` and `SecurityService.iosBundleId` (`com.intglobal.employeeTransferProject`) used for their own platforms. | Same file: each ID is pinned to the value in `build.gradle.kts` and `project.pbxproj`. |
| SA-04 | `android:allowBackup="false"`, `android:fullBackupContent="false"`, and `res/xml/data_extraction_rules.xml` excluding all app data from cloud backup and device transfer. | Same file: manifest and rules checked. |
| SA-09 | Root `.gitignore`: `*.p12`, `*.mobileprovision`, `*.cer`, `*.certSigningRequest`. | — |
| SA-11 | freeRASP 8.2.2 → **8.2.4** (iOS SDK 8.0.1; 8.2.3 improved iOS jailbreak and hook detection; no API change). | Full suite. |

**Android signing hash for testing:** the Android hash can now be supplied
per build with `--dart-define=RASP_ANDROID_CERT_HASH=<SHA-256, Base64>`
(e.g. the debug certificate's, for device testing). Without it, freeRASP
rejects the placeholder and the app reports "could not start" (UAT warning,
PROD block). The real release hash stays a release blocker.

**Evidence:** `flutter analyze` clean; `flutter test` 187/187.

**Device checks (2026-10-06):**
- **iOS Simulator (iPhone 17): app starts.** Built with freeRASP 8.2.4, no
  unhandled exception, opens on the Sign in screen. No freeRASP threat was
  observed in the run (no "simulator" warning seen), so this shows the start
  no longer fails; it does not yet show detection reporting threats.
- **Physical iPhone:** not run — the Xcode project has no Development Team
  set, which a device build needs for signing.
- **Android emulator: not completed.** The build compiled but failed to copy
  the APK because the Mac's disk is full ("No space left on device").
  Deferred at the session user's direction.

## iOS fixes (2026-10-06, after the Tech Lead's approval was reported)
| ID | Fix | Test |
|---|---|---|
| SA-05 | App tampering / re-signing (`onAppIntegrity`) now reaches `ThreatResponse` like root, hooks, debugger and emulator: PROD blocks, UAT warns. `SecurityService.threatCallback` is the single list of threats acted on. | `security_startup_test.dart`, "SA-05" |
| SA-10 | `Talsec.blockScreenCapture` in PROD: screenshots and screen recording come out black. UAT keeps them for testers. The iOS app-switcher snapshot is not covered by this API. | "SA-10" |
| Release mode | freeRASP runs with `isProd: kReleaseMode` (was always `false`), so release builds get the full checks. | "iOS release config" |
| iOS Team ID | From `--dart-define=RASP_IOS_TEAM_ID` (was a hard-coded placeholder). With the placeholder, a PROD release build would now report app tampering and block itself, so the real Team ID is required for a release. | "iOS release config" |

**Evidence:** `flutter analyze` clean; `flutter test` 191/191.

## Recommended order
1. SA-01 and SA-02 (code, test-first), with SA-11 (update freeRASP).
2. SA-04 and SA-09 (one-line config each).
3. Device verification of root/Frida detection on Android and iOS.
4. Release blockers: SA-03, real freeRASP config, SA-08.
5. Tech Lead decisions: SA-05, SA-06, SA-07, SA-10, SA-12 exception.
