# Laziness Protocol

- **When to apply**: Refactoring, sizing a diff, or tempted to add abstractions, helpers, or config flags.
- **Rule**: Bias toward deletion and the smallest change that solves the problem.
- **Avoid**: Adding a 3-layer factory or new configuration knob for a single call site.
