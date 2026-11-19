# Migrate Callers Then Delete Legacy APIs

- **When to apply**: Introducing a replacement internal API while old callers still exist.
- **Rule**: Migrate all callers and delete the legacy API in the same wave instead of leaving deprecated wrappers indefinitely.
- **Avoid**: Leaving `legacyFoo()` around forever 'just in case'.
