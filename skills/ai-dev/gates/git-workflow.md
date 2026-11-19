# Gate: Git Workflow

Apply when creating branches, staging, committing, opening PRs, merging, or rolling back.

## Branching (Lightweight Trunk-Based)

- `main`: Always releasable; only verified and reviewed changes merge here.
- Naming: `feat/<name>`, `fix/<name>`, `refactor/<name>`, `docs/<name>`, `chore/<name>`, `hotfix/<name>`.
- One branch = one verifiable unit. Never mix unrelated features, refactors, and formatting.

## Staging & Commits

- Always inspect before staging: `git status --short`, `git diff`, `git diff --staged`.
- Stage specific files intentionally; avoid blind `git add .` when unrelated or user-dirty changes exist. Never revert or overwrite pre-existing user changes.
- Use Conventional Commits: `type(scope): summary` (`feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `revert`).
- One commit per intent; check diff for secrets, debug logs, or stray edits before committing.

## Rollback Readiness

- Every PR/release must state how to revert safely (`git revert` or feature flag off). If a change includes a destructive DB migration, `Expand & Contract` is mandatory.
