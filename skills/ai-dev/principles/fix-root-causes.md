# Fix Root Causes

- **When to apply**: Debugging errors, race conditions, or unexpected states.
- **Rule**: Trace each symptom back to the earliest point where the system went wrong and fix it there.
- **Avoid**: Adding a downstream null check to silence a crash caused by an upstream bug.
