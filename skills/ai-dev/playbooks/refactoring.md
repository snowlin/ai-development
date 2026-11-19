# Playbook: Refactoring

Use for behavior-preserving structural improvements.

## Steps

1. **Baseline behavior**: Confirm existing tests or observable behavior checks pass before touching structure. If coverage is missing for critical paths, add behavior tests first (`principles/test-behavior-not-implementation.md`).
2. **Subtract before adding**: Remove dead code, unused flags, and redundant wrappers first (`principles/subtract-before-you-add.md`, `principles/minimize-reader-load.md`).
3. **Converge cleanly**: Migrate all callers and delete legacy APIs in the same wave (`principles/migrate-callers-then-delete-legacy-apis.md`, `principles/outcome-oriented-execution.md`). Do not leave compatibility shims unless explicitly required.
4. **Verify**: Re-run the baseline checks (`Targeted` or `Full` per risk) and verify no behavior regressed. Clean `git diff` before reporting.
