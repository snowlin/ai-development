# Model the Domain

- **When to apply**: Writing stateful logic or repeating branch checks across multiple files.
- **Rule**: Encode domain rules in a typed model, state machine, or lookup table instead of scattered conditionals.
- **Avoid**: Duplicating `if (status === 'a' && !flag)` checks across controllers and UI components.
