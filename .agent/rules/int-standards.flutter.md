# INT Standards — Flutter

Always-on rules the agent reads every session, regardless of task. Do not duplicate
project-specific rules here — those belong in `.ai-context/constitution.md`.

## Coding Conventions
- Null-safety strict mode; no `!` non-null assertions without a comment explaining why the null case is impossible.
- One widget, one responsibility — extract when a `build()` method exceeds ~80 lines or mixes layout with business logic.
- State management: whatever is decided in ADR-0001 for this project — do not introduce a second approach per feature/screen.
- No business logic in widgets — UI layer calls into a state-notifier/bloc/controller, which calls the data layer.

## Error Handling
- Every API call site handles: success, expected failure (4xx — user-facing message), unexpected failure (5xx/timeout — generic retry state), and offline/no-connectivity.
- Never swallow an exception silently — log (without PII, per constitution.md) or surface it, never both-skip.

## Testing
- Test-first per constitution.md's Testing Discipline section — write the failing test before the widget/logic it verifies.
- Widget tests for every screen's happy path plus at least one error/empty state.
- Unit tests for every state-notifier/bloc event → state transition.

## Performance
- No unbounded lists without pagination/lazy-loading once data volume is non-trivial.
- Avoid rebuilding whole screens on state change — scope `Consumer`/`BlocBuilder` to the smallest widget that needs the rebuild.

## Guardrails
- Vet any suggested pub.dev package before adding to `pubspec.yaml` — check maintenance status and download count; prefer Flutter/Dart SDK built-ins when they already solve the problem (Blueprint §20's OTP-generator example applies here too).
- No secrets, API keys, or environment endpoints hardcoded in Dart source — via the app's existing config/secrets mechanism only.
