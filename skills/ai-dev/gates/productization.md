# Gate: Productization Boundary, Cost & Dependencies

Apply when a personal/internal tool may be shared with others, monetized, or incur external AI/API costs.

## 1. Productization Boundary Check

1. **Current Stage**: Personal Tool / Internal Tool / Beta / Paid Product.
2. **Target Users**: Self only / small circle / public users / teams / paying customers.
3. **Data Ownership**: Identify which records require `owner_id` or `user_id`. Even for personal tools, avoid hardcoding global single-tenant assumptions into saved reports, histories, or knowledge bases.
4. **Usage Metering**: Identify which AI/API calls need `usage_events` logging.
5. **Entitlements & Quotas**: Decide whether `plan`, `quota`, feature flags, or BYOK is needed now or later (name the exact trigger condition if deferred).
6. **Monetization Sequence**: Identity, data ownership, usage logging, and cost bounds come **before** payment/subscription UI.

## 2. Cost & Dependency Discipline

- Estimate per-request and worst-case loop cost before enabling unbounded AI/API calls.
- Prefer built-in or existing project dependencies over adding new packages; verify license, maintenance, and bundle/runtime impact for every new dependency.
