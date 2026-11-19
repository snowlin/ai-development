# Playbook: Prototype

Use to settle an empirical fork ("which library is faster?", "does layout A feel better?") or explore an unfamiliar design space cheaply.

## Steps

1. **Define the question**: State the exact decision the prototype must settle and the pass/fail signal.
2. **Build throwaway sketch(es)**: Keep it minimal and isolated (scratch script, isolated branch, or 2-3 competing spikes per `principles/exhaust-the-design-space.md`). Do not polish production scaffolding yet.
3. **Measure & observe**: Run the prototype against real inputs. Report `Measured` observations rather than opinions (`principles/explain-the-number.md`).
4. **Decide & clean up**: Present the comparison and recommendation. Delete throwaway artifacts before implementing the chosen path cleanly.
