# Playbook: Opening a PR

Use when preparing commits and opening or updating a pull request. Also read `gates/git-workflow.md` if branch/staging rules are needed.

## Steps

1. **Inspect & clean diff**: Run `git status --short` and `git diff`. Strip:
   - Narrating comments (`// Step 1: ...`)—keep only non-obvious *why* comments.
   - Debug logs, dead compatibility shims, and unrelated formatting edits.
   - Secrets, `.env`, or unintended generated files.
2. **Stage intentionally**: Stage only files belonging to this verifiable unit (`git add <file>`, avoid blind `git add .` when unrelated changes exist).
3. **Small ordered commits**: Use Conventional Commits (`type(scope): summary`), one intent per commit.
4. **Verify final head**: Confirm the matching Verification Budget (`Light` / `Targeted` / `Full`) passed on the final committed state.
5. **Write briefing-style PR body**:
   - `## What`: Concise summary of changes.
   - `## Why`: User goal and problem solved.
   - `## Verification`: Exact commands run and observed results (or `Exempt` reason).
   - `## Review Focus`: Key files, state transitions, or risks to inspect.
   - `## Rollback`: How to revert safely.
