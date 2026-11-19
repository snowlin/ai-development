---
name: ai-dev
description: Rigorous, high-signal AI engineering workflow combining product/production gates (IPSI-G, System Skeleton, Productization Boundary, Production Readiness) with structured execution playbooks, engineering principles, and verification budgets. Use for non-trivial coding, debugging, refactoring, architecture, investigation, PRs, or when asked to run /ai-dev.
---

# AI Dev Mode

Read `PROJECT.md` in the workspace first if it exists, to align on product positioning, MVP scope, and system boundaries.
Load referenced `playbooks/*.md`, `principles/*.md`, and `gates/*.md` **on demand** when triggered—never preload all files.

## Non-negotiables

1. **Restate goal & smallest change first**: On your first turn for any non-trivial task, state in plain words the user's goal, the problem being solved, and the smallest change expected to meet it. Do not wait for confirmation unless an irreversible action or genuine product call requires it.
2. **Experiment before asking**: Never ask the human a question (`AskQuestion`) that can be answered by reading code or running a quick check/prototype (`playbooks/prototype.md`). Reserve questions for irreversible actions, product direction, or genuine preference calls.
3. **Data shape first**: Before writing logic across modules or state machines, name the core data shape and organizing structure (`principles/model-the-domain.md`, `principles/foundational-thinking.md`).
4. **Separate Evidence, Assumptions, Counterexamples, and Judgment**: For architectural, security, performance, or product tradeoffs, label claims explicitly (`Measured`, `Inferred`, or `Guess`). Never present a guess as fact.
5. **Verification Budget (match risk, skip theater)**:
   - `Exempt`: Pure docs, comments, formatting, isolated copy/style tweaks → skip build/tests, deliver immediately.
   - `Light`: Local non-critical UI or helper script → targeted syntax/typecheck or minimal repro.
   - `Targeted`: Single feature loop, API contract, or state change → affected unit tests + typecheck.
   - `Full`: Core state machines, billing/orders, DB writes/migrations, auth/security, pre-release → full relevant suite, build, and bad-path checks.
6. **Diff Hygiene & Unslop (no `cursor-team-kit` needed)**: Before committing or delivering code, inspect `git diff` and strip: (a) narrating comments that restate what code does, (b) unsupported defensive guards, (c) dead compatibility shims, (d) unrelated edits. Keep replies concise, direct, and free of AI filler.
7. **Tool-agnostic verification**: Use whatever browser/Playwright or CLI/terminal tool is available in the current environment to prove behavior live. If a surface has no runtime driver available, state clearly what was not verified live instead of faking it.

## Playbook Routing

Match the task to one playbook and follow its steps:

| Task | Playbook |
|---|---|
| Read-only question ("how does X work", "why is Y built this way") | `playbooks/investigation.md` |
| Reproduce and fix a defect with runtime evidence | `playbooks/bug-fix.md` |
| New behavior or feature (includes IPSI-G & System Skeleton checks) | `playbooks/feature.md` |
| Behavior-preserving structural improvement | `playbooks/refactoring.md` |
| Settle an empirical fork or design choice with a throwaway sketch | `playbooks/prototype.md` |
| Trace measured slowness and improve against a baseline | `playbooks/perf-issue.md` |
| Long or unattended task ("keep going until done") | `playbooks/autonomous-run.md` |
| Clean diff, commit cleanly, and prepare a PR briefing | `playbooks/opening-a-pr.md` |

## Gate Triggers (Read `gates/*.md` only when triggered)

- **New product / SaaS / major unvalidated direction** → Invoke the `product-selection` skill (`../product-selection/SKILL.md`).
- **New feature / page / multi-role or persistent data** → Read `gates/ipsi-and-skeleton.md` (Idea / Product / System / System Skeleton Gate).
- **Tool could be shared, billed, or incur AI/API cost** → Read `gates/productization.md` (Productization Boundary, Cost, Dependency).
- **Moving from prototype to real users or production** → Read `gates/production-5-gates.md` (Production Readiness & 5 Mandatory Pre-launch Gates).
- **Git branch, commit, PR, merge, or rollback** → Read `gates/git-workflow.md`.

## Principles Index (Read `principles/<name>.md` when applied)

**Core**
- `laziness-protocol`: Bias toward deletion and the smallest change that solves the problem.
- `foundational-thinking`: Define core types, data structures, and shared state before writing logic.
- `redesign-from-first-principles`: Integrate new requirements as if foundational from day one, not bolted on.
- `attack-the-premise`: When 2+ fixes sharing a premise fail, stop and test the premise directly.
- `subtract-before-you-add`: Delete dead weight and redundant checks before building on top.
- `minimize-reader-load`: Reduce indirection layers and hidden mutable state; collapse single-caller wrappers.
- `outcome-oriented-execution`: Converge on target architecture in planned migrations; avoid throwaway shims.
- `experience-first`: Favor user clarity and delight over implementation convenience.
- `exhaust-the-design-space`: Build 2-3 competing prototypes for novel decisions before committing.
- `build-the-lever`: Build reusable scripts/codemods/checks for non-trivial bulk or repeatable work.

**Architecture**
- `model-the-domain`: Encode domain rules in types, state machines, or tables instead of scattered `if/else`.
- `boundary-discipline`: Validate at system boundaries (CLI, config, API); keep internal business logic pure.
- `type-system-discipline`: Make illegal states unrepresentable; exhaust variants; parse at boundaries.
- `make-operations-idempotent`: Converge to the same end state across retries and partial runs.
- `migrate-callers-then-delete-legacy-apis`: Migrate callers and remove old APIs in the same wave.
- `separate-before-serializing-shared-state`: Eliminate shared mutable state first; serialize only when invariant.

**Verification**
- `prove-it-works`: Verify against the real running artifact or output, never "it compiles".
- `fix-root-causes`: Trace symptoms back to the earliest point of failure; do not mask with downstream guards.
- `sequence-verifiable-units`: Break multi-step work into small units, each ending in a verified check.
- `test-behavior-not-implementation`: Assert user-observable behavior so tests survive internal refactors.
- `explain-the-number`: Identify bottlenecks and rule out measurement artifacts before reporting metrics.

**Delegation & Meta**
- `guard-the-context-window`: Offload bulk reads/scans to subagents; keep concise summaries in main thread.
- `never-block-on-the-human`: Proceed on reversible work and report; pause only for irreversible actions.
- `encode-lessons-in-structure`: Turn repeated instructions into lints, type checks, or scripts instead of prose.
