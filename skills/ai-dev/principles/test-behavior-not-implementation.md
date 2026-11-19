# Test Behavior, Not Implementation

- **When to apply**: Writing, updating, or reviewing tests.
- **Rule**: Assert what users or callers observe (outputs, state, side effects) so tests survive internal refactors.
- **Avoid**: Mocking internal private helpers or asserting exact call counts on internal functions.
