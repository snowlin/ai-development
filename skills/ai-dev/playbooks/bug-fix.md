# Playbook: Bug Fix

Use when reproducing, root-causing, and fixing a defect.

## Steps

1. **Reproduce first**: Establish a minimal, reliable reproduction (failing test, CLI command, or browser/runtime trace) before editing code. Apply `principles/prove-it-works.md`.
2. **Trace to root cause**: Follow the data/control flow back to the earliest point where the system went wrong (`principles/fix-root-causes.md`). If 2+ fixes sharing an assumption fail, apply `principles/attack-the-premise.md`.
3. **Minimal fix**: Make the smallest clean fix (`principles/laziness-protocol.md`). Do not add downstream `null`/fallback guards unless the state is genuinely valid at a boundary (`principles/boundary-discipline.md`).
4. **Add regression test**: Write a test asserting user-observable behavior (`principles/test-behavior-not-implementation.md`).
5. **Verify & clean**: Run the appropriate Verification Budget (`Targeted` or `Full`), inspect `git diff` to remove debug logs/slop comments, and report root cause, fix, and observed test output.
