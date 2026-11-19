# Playbook: Feature

Use when adding new behavior or modifying product capabilities.

## Steps

1. **Gate check**:
   - If the idea or direction is unvalidated, run `../product-selection/SKILL.md` first.
   - Read `gates/ipsi-and-skeleton.md` to confirm Idea/Product/System clarity and System Skeleton (roles, data ownership, permissions, error states; exempt trivial local scripts).
   - If the feature may be shared, billed, or incur AI/API cost, check `gates/productization.md`.
2. **UI Draft First (if UI is involved)**: Present a low-fidelity wireframe, ASCII layout, or Mermaid flow to align on UX before writing heavy UI code (`principles/experience-first.md`).
3. **Design data shape first**: Name the core types, state transitions, and module boundaries before writing logic (`principles/foundational-thinking.md`, `principles/model-the-domain.md`).
4. **Implement in small verifiable units**: Build one end-to-end vertical slice at a time (`principles/sequence-verifiable-units.md`). Keep abstractions minimal (`principles/laziness-protocol.md`).
5. **Verify & clean**: Run the matching Verification Budget, prove the feature works end-to-end (`principles/prove-it-works.md`), clean `git diff`, and summarize changes, checks, and remaining risks.
