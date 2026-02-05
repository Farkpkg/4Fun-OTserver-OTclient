# Execution Playbook (Step 10 Operationalized)

This playbook turns the Step 10 checklist into an executable workflow for future tasks across `crystalserver` and `otclient`.

## 1) Scope Lock
Create a short design brief before coding.

Required outputs:
- **Problem statement** (what is changing and why).
- **Boundaries** (explicitly in-scope / out-of-scope).
- **Protocol impact** (login/game opcodes, payload changes, compatibility needs).
- **Data impact** (DB migrations, config changes, Lua/module changes).
- **Rollback unit** (what can be reverted independently).

Exit criteria:
- Affected files and subsystems are listed.
- Compatibility strategy is selected: (a) dual-path compatibility, (b) feature-flagged compatibility, or (c) breaking-change with migration window.

---

## 2) Design Review
Document behavior before implementation.

Required outputs:
- **Sequence diagram** (request -> validation -> state change -> broadcast/update).
- **Failure-mode table** (what fails, detection, mitigation, user-visible behavior).
- **Security impact review**:
  - authn/authz implications
  - input validation changes
  - trust-boundary changes
  - sensitive data logging check

Template to use:
- `docs/templates/TASK_EXECUTION_TEMPLATE.md`

Exit criteria:
- At least one reviewer sign-off (or self-review with rationale in single-maintainer contexts).

---

## 3) Implementation
Apply guarded, backward-compatible changes.

Rules:
- **Server authoritative** for gameplay state and rule validation.
- **Backward compatibility gates** for protocol and data transitions.
- **Feature flags** for risky or partial-rollout changes.

Implementation checklist:
- Add/adjust server-side validation first.
- Keep client behavior tolerant to unknown/optional fields where possible.
- Add metrics/log events for the new code path.
- Avoid leaking secrets in logs and errors.

Exit criteria:
- Feature flag exists (or explicit “not needed” justification).
- Compatibility behavior is covered by tests.

---

## 4) Validation
Validate correctness, performance, and security.

Minimum validation matrix:
- **Unit tests** for pure/domain logic.
- **Integration tests** for protocol/state transitions.
- **Load/soak tests** for concurrency-sensitive paths.
- **Security checks**:
  - static checks/linting
  - dependency vulnerability scan
  - targeted abuse test for new endpoints/opcodes

Suggested practical test categories:
- Login/auth flow success/failure and replay attempts.
- Movement/combat/event burst under high packet rate.
- DB migration forward/backward check.
- Feature flag ON/OFF behavior parity.

Exit criteria:
- No P0/P1 failures.
- Known limitations documented with mitigation.

---

## 5) Rollout
Ship safely with observability and rollback readiness.

Required outputs:
- **Staged rollout plan** (dev -> canary -> wider rollout).
- **Dashboards/alerts**:
  - login success/failure rate
  - opcode latency/error rates
  - DB/query latency and saturation
  - crash/restart frequency
- **Rollback criteria** with clear trigger thresholds.

Operational checklist:
- Create release note with migration steps.
- Verify on-call/runbook updates.
- Confirm rollback command/procedure tested.

Exit criteria:
- Rollout checkpoints passed.
- Post-release review completed.

---

## Definition of Done for Complex Tasks
A task is considered complete only when:
1. Scope/design/implementation/validation/rollout artifacts are present.
2. Backward compatibility and feature-flag strategy are explicit.
3. Security and performance impacts are measured (or explicitly waived with rationale).
4. Rollback has been tested or simulated.
