# Boundary Discipline

- **When to apply**: Wiring validation, error handling, or external adapters.
- **Rule**: Concentrate parsing and guards at system boundaries (CLI, config, HTTP/API); trust internal types and keep core logic pure.
- **Avoid**: Re-validating and defensive-checking internal trusted arguments in every helper function.
