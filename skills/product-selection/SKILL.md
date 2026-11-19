---
name: product-selection
description: Product opportunity selection, validation, and productization gate. Use before writing code when evaluating a new product idea, SaaS, AI feature, or major pivot ("should we build this", "product selection", "选品", "立项评估"). Do not use for routine bug fixes or well-defined engineering tasks.
---

# Product Selection Gate

Building became cheap; selection, judgment, attention, and delivery did not. Optimize for **better selection before more construction**.

## Core Rules

1. **Default = NO (`should_build: false`)**: An idea does not earn code because it sounds interesting, AI can build it fast, or competitors exist. Evidence must reverse `NO -> YES`.
2. **Validate the Transaction First**: Before discussing features, UI, or architecture, verify whether a real transaction exists (buyer, trigger, painful problem, desired outcome, urgency, and concrete commitment like deposit/LOI/paid pilot/data access).
3. **Never Turn Assumptions Into Requirements**: Label every claim as `Fact`, `Assumption`, or `Unknown`. Never build features around unverified assumptions.

## Execution Steps

1. **Frame the Bet**: State the target user, job-to-be-done, and why existing alternatives fail.
2. **Audit Evidence**: Separate:
   - **Facts** (observed behavior, committed users, existing data)
   - **Assumptions** (unproven hypotheses)
   - **Unknowns** (gaps that could kill the idea)
3. **Identify the Riskiest Unknown**: Name the single assumption most likely to invalidate the idea.
4. **Design the Cheapest Decisive Test**: Propose the lowest-cost experiment (landing page, concierge MVP, manual workflow, prototype) that produces real evidence without full engineering.
5. **Render Decision**: Output one clear verdict:
   - `Continue`: Evidence supports building an MVP -> summarize into `PROJECT.md` Idea & Product section.
   - `Define Only`: Worth clarifying problem/transaction before coding.
   - `Parking Lot`: Interesting, but not the highest-leverage bet right now.
   - `Reject`: Fails transaction or differentiation check; drop it.
