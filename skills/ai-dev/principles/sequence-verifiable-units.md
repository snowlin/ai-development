# Sequence Verifiable Units

- **When to apply**: Multi-step refactors, migrations, or stacked commits.
- **Rule**: Break work into small units that each end in a runnable check, verifying each before starting the next.
- **Avoid**: Making 15 unverified edits across subsystems and testing only at the very end.
