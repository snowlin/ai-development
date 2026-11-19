# Minimize Reader Load

- **When to apply**: Shaping or reviewing code that requires jumping across many files or tracking hidden state.
- **Rule**: Count indirection layers between question and answer; collapse single-caller wrappers and shrink mutable scope.
- **Avoid**: Splitting a 20-line cohesive flow into five 4-line single-use files.
