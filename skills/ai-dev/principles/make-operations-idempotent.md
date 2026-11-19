# Make Operations Idempotent

- **When to apply**: Designing scripts, lifecycle hooks, migrations, or retryable jobs.
- **Rule**: Ensure repeated or partial runs converge cleanly to the same end state without corrupting data.
- **Avoid**: Appending duplicate records or failing on already-created directories when re-run.
