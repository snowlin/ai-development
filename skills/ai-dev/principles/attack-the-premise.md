# Attack the Premise

- **When to apply**: Two or more fixes sharing the same assumption have failed the same check.
- **Rule**: Stop editing downstream, write the shared premise down, and test that premise directly.
- **Avoid**: Tweaking retry counts or edge guards for a third time when the underlying root assumption is false.
