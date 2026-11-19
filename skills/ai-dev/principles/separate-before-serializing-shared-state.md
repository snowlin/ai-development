# Separate Before Serializing Shared State

- **When to apply**: Concurrent workers or flows might write the same file, branch, or key.
- **Rule**: Eliminate the sharing first (partition by worker/ID); add locks or serialization only for true single-writer invariants.
- **Avoid**: Adding global mutexes around state that never needed to be shared.
