# Type System Discipline

- **When to apply**: Designing types, schemas, or function signatures.
- **Rule**: Make illegal states unrepresentable, use discriminated unions, exhaust variants, and parse untrusted input at boundaries.
- **Avoid**: Using loose `string` / `any` / optional bags where mutually exclusive states exist.
