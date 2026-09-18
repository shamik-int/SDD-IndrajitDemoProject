# ADR-0001: Flutter Client Architecture, State Management & Local Persistence

_Author: Indrajit Bhandari | 2026-09-15 | Status: Accepted_

## Context
Before the first feature (`employee-internal-transfer`) enters Plan stage, the
client-side technical foundation needs to be fixed once, project-wide, so every
future spec/plan/tasks chain builds on the same base (Blueprint §8, §13: "a plan
that's silent on a constitution rule isn't neutral — it's a gap"). This ADR captures
that foundation, decided at kickoff by the Author.

Scope note: this ADR covers the **Flutter client only**. The backend/orchestration
service stack (Node vs. Java, per `constitution.md`) is still open and will be
decided at the `employee-internal-transfer` Plan stage, likely as its own ADR.

## Decision

### 1. Architecture pattern — Clean Architecture
Three layers, plus one cross-cutting layer:

```
lib/
├── main.dart
├── app/
│   ├── app.dart              # GetMaterialApp root
│   ├── routes/                # GetPage route table
│   └── bindings/               # Root/initial GetX bindings
├── core/                        # Cross-cutting, shared by all features
│   ├── constants/                 # Static strings, message copy, app version
│   ├── utils/                     # common_utils (toast, loader), validators (email/phone/mandatory)
│   ├── theme/                     # colors, text styles, light/dark ThemeData
│   ├── responsive/                # ScreenUtil bootstrap + phone/tablet breakpoint helper
│   ├── security/                  # root/jailbreak/Frida detection (ADR-0002)
│   ├── network/                   # ApiClient (remote data source contract)
│   ├── local_db/                  # LocalDbService (local data source contract)
│   └── result/                    # Result<T> + Status{success,error,inProgress}
├── data/
│   ├── models/                    # DTOs / response models (fromJson/toJson)
│   ├── datasources/
│   │   ├── remote/                  # API-backed data sources
│   │   └── local/                   # LocalDbService-backed data sources
│   └── repositories/               # Implements domain repository contracts
├── domain/
│   ├── entities/                  # Pure business objects, no JSON/DB concerns
│   ├── repositories/               # Abstract contracts (implemented in data/)
│   └── usecases/                  # One class per business operation
└── presentation/
    ├── controllers/               # GetxController per screen/feature
    ├── bindings/                  # Feature-level GetX bindings
    ├── pages/                     # Screens
    └── widgets/                   # Shared/reusable widgets
```

Dependency rule: `presentation` → `domain` ← `data`. `domain` never imports from
`data` or `presentation`. `core/` has no dependency on any of the three layers and
is importable by all of them.

### 2. State management — GetX
`GetxController` + `Get.put`/`Get.find` via bindings, `GetMaterialApp` with `GetPage`
named routes. Single approach for the whole app (constitution.md Architectural
Constraints already required "one approach, no second library per feature" — this
ADR is that decision).

### 3. Environments — UAT and PROD
`assets/env/.env.uat` and `assets/env/.env.prod`, loaded at startup (via
`flutter_dotenv` or `--dart-define-from-file`, confirmed at Plan stage) based on the
build flavor. **These files hold non-sensitive configuration only** — environment
name, API base URL, feature flags. Real credentials never go here; see the
Security Posture note below.

### 4. Local persistence — local-first, API-shaped
A `LocalDbService` abstraction in `core/local_db/`, deliberately shaped the same
way as `core/network/ApiClient` — both return the same `Result<T>` wrapper:

```dart
enum Status { success, error, inProgress }

class Result<T> {
  final Status status;
  final T? data;
  final String? message;
  const Result({required this.status, this.data, this.message});
}
```

Proposed engine default: **Hive** (lightweight, no native SQL needed for the
request/status data shape currently known from BRD-001). Revisit as Drift/sqflite
if `employee-internal-transfer`'s Plan-stage data model turns out to need
relational queries across requests.

### 5. Responsiveness — ScreenUtil + tablet detection
`flutter_screenutil` for scaling against a design reference size. A
`core/responsive/ResponsiveUtil` helper additionally distinguishes device class by
breakpoint, since ScreenUtil alone only scales — it doesn't re-layout:
```dart
bool isTablet(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide >= 600;
```

### 6. Theming — light/dark, green/yellow, Lato
- Light + dark `ThemeData`, primary **Green**, accent **Yellow**, secondary light
  tint shades, layered text-color shades (primary/secondary/disabled, per mode).
- Proposed palette (confirm at Gate 1 against any existing One-Point Portal design
  system before treating as final):
  | Token | Light | Dark |
  |---|---|---|
  | Primary (Green) | `#2E7D32` | `#66BB6A` |
  | Primary Variant | `#1B5E20` | `#388E3C` |
  | Accent (Yellow) | `#FBC02D` | `#FFD54F` |
  | Secondary tint (green) | `#E8F5E9` | `#1B3A1D` |
  | Secondary tint (yellow) | `#FFF9C4` | `#3A3319` |
  | Surface | `#FFFFFF` | `#121212` |
  | Text — primary | `#212121` | `#F5F5F5` |
  | Text — secondary | `#616161` | `#BDBDBD` |
  | Text — disabled | `#9E9E9E` | `#6E6E6E` |
- Font: **Lato**, self-hosted — `.ttf` weights (Regular/Light/Bold/Italic)
  downloaded from Google Fonts and bundled under `assets/fonts/`, declared as a
  local font family in `pubspec.yaml`. Deliberately **not** using the `google_fonts`
  runtime-fetch package, so the app never needs a network call for its own type on
  first launch — consistent with the local-first posture in (4).

### 7. Cross-cutting utilities & constants
- `core/constants/` — static message copy, app version string, any other
  compile-time constants. Single source; no per-feature duplicate string tables.
- `core/utils/common_utils.dart` — toast, loader/progress-indicator helpers, and
  other global UI-adjacent services.
- `core/utils/validators.dart` — email, phone, and mandatory-field checks, shared
  by every screen's form validation.

### 8. Validation
Every mandatory input field has an explicit validator from
`core/utils/validators.dart`. Client-side validation is a UX aid, not the security
boundary — the same field is still re-validated at the repository/API boundary.

## Constitution Check
- [x] Testing Discipline — updated to test GetX controllers directly (plain Dart
      classes), replacing the earlier bloc_test placeholder.
- [x] Architectural Constraints — updated to name Clean Architecture + GetX +
      local-first persistence as the decided approach.
- [x] Security Posture — updated to clarify env files carry no secrets.
- [ ] Non-Functional Baselines — unaffected by this ADR; local DB read/write
      latency budget to be set at `employee-internal-transfer` Plan stage.

## Explicitly Deferred
- Backend/orchestration service stack (Node vs. Java) — separate, still-open
  decision (see `constitution.md` Testing Discipline note).
- Final local DB engine choice — Hive proposed, confirm once the feature's data
  model is known.
- Exact env-loading mechanism (`flutter_dotenv` vs. `--dart-define-from-file`) —
  confirm at Plan stage.
- Root/Jailbreak/Frida detection and memory hygiene — see **ADR-0002**.

## Consequences
Every future spec/plan for this project inherits this structure without
re-litigating it. A spec that needs a new top-level architectural concept (e.g. a
second local datastore, a second state-management pattern) requires its own ADR,
per constitution.md's "no new datastore without an ADR" rule. Onboarding a new
engineer or agent session means pointing them at this file and
`architecture.md` — not re-explaining the stack in every prompt (Blueprint §17).
