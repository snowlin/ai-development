# Playbook: Autonomous Run

Use when the user asks to complete a multi-step task unattended ("keep going until done", "run overnight", "don't stop").

## Steps

1. **Lock scope & autonomy boundaries**:
   - Proceed without asking on all reversible work (`principles/never-block-on-the-human.md`).
   - Still pause on irreversible actions: force-pushing shared branches, production deploys, destructive data deletion, or external customer messages.
2. **Work in verifiable units (`principles/sequence-verifiable-units.md`)**:
   - Break work into small milestones; verify and commit each clean unit before starting the next.
   - Ensure operations and scripts are idempotent (`principles/make-operations-idempotent.md`).
3. **Keep a decision trail**: Log key choices, failed attempts, and verification results concisely so the user can audit them upon return.
4. **Final verification**: Run `Targeted`/`Full` checks on the final state, clean `git diff`, and deliver a structured summary of completed items, verified outputs, and any blocked/open calls.
