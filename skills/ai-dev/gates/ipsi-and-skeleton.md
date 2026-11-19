# Gate: IPSI-G & System Skeleton

Apply before implementing a new product, new module, new page, or changes involving multi-role access or persistent data. (Exempt: trivial local scripts or single-file bug fixes.)

## 1. IPSI-G (Idea → Product → System → Implementation)

1. **Idea**: What specific pain point does this solve, for whom, and why now?
2. **Product**: What is the smallest MVP that proves value? What is explicitly **out of scope**?
3. **System**: What is the end-to-end data flow (`input -> processing -> storage -> output`)?
4. **Implementation**: Only after 1–3 are clear, define the smallest verifiable implementation unit.

## 2. System Skeleton Check

Before writing feature code, confirm these 5 skeleton questions:

- **Roles & Auth**: Who can access this (owner, admin, member, guest)? Where are permissions enforced?
- **Data Ownership**: Which records belong to a `user_id` / `owner_id` / `org_id`?
- **State Transitions**: What are the valid states and illegal transitions?
- **Failure & Bad Paths**: What happens on invalid input, network/API failure, partial write, or timeout?
- **Observability / Admin**: How do you inspect or recover stuck state?
