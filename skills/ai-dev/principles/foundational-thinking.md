# Foundational Thinking

- **When to apply**: Before writing logic across modules, concurrent actors, or stateful flows.
- **Rule**: Define core types, data structures, and shared-state boundaries first so downstream code becomes obvious.
- **Avoid**: Writing control flow first and patching data structures repeatedly afterward.
