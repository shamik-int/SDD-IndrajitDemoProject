# ADR-0002: Mobile Runtime Security Hardening (Root / Jailbreak / Frida) & Memory Hygiene

_Author: Indrajit Bhandari | 2026-09-15 | Status: Accepted_

## Context
Transfer requests touch organisational, approval, and payroll-adjacent data,
so a compromised runtime — a rooted/jailbroken device, or Frida/hook-based
instrumentation — is a real threat to the client-side authorization and
validation this app relies on. The requirement also grouped "memory leakage"
together with root/Frida detection; these are actually two different categories
of concern and are treated separately below rather than folded into one control,
since conflating them would leave one of them unenforceable.

## Decision

### 1. Anti-tampering — a genuine runtime security control
On app start and on resume, check for root/jailbreak status and Frida/hook
instrumentation using a dedicated detection package. Proposed default:
`freerasp` (Talsec's Flutter security suite — root, jailbreak, debugger, and
Frida/hook detection in one library), confirmed at Gate 1 against license/vendor
approval if this project has an approved-vendor list. Detection result is
surfaced through `core/security/`; the **response** to a positive detection
(hard block vs. warn-and-continue vs. silent telemetry) is a Plan-stage decision
for `employee-internal-transfer`, since it's a UX/risk-appetite call, not just a
technical one.

### 2. Memory hygiene — an engineering-quality practice, not a runtime guard
Every `GetxController`, `StreamSubscription`, and `AnimationController` releases
its resources in `onClose()`/`dispose()`. This is enforced via the Gate 2 code
review checklist and via Flutter's `leak_tracker` running in debug/profile test
runs. Unlike (1), this has no meaningful "detect in production at runtime" form —
it is caught in development and review, not defended against at runtime.

## Constitution Check
- [x] Security Posture — adds mandatory root/jailbreak/Frida detection.
- [x] Testing Discipline — adds the memory-hygiene/leak-check expectation.

## Explicitly Deferred
- Exact response behaviour on positive root/Frida detection — deferred to the
  `employee-internal-transfer` plan and Security sign-off.
- Whether detection failure should be a hard app-level gate (blocks all use) or
  scoped only to the transfer-request submission flow — open, Plan stage.

## Consequences
Adds a small startup-time check; budgeted within the app's perceived-responsiveness
goal, not the API p95 NFR specifically. This is defence-in-depth, not a substitute
for server-side authorization — the existing Security Posture rule that a user may
only act on requests where they hold the pending action still applies and is
enforced server-side regardless of client-side detection outcome.
