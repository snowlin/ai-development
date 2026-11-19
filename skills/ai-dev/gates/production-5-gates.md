# Gate: Production Readiness & 5 Mandatory Pre-Launch Gates

Apply before moving a prototype to real users, production traffic, or rolling deployments.

- **0-to-1 New Project**: Focus heavily on API key isolation, dual budget circuit breakers, and basic bad-path tests.
- **1-to-N Live Project**: Enforce all 5 gates strictly.

## The 5 Mandatory Pre-Launch Gates

1. **Database & Deployment Alignment (`Expand & Contract`)**:
   - *Expand phase* (new tables, nullable columns, indexes): Run DB migration **before** deploying new code; new code must handle missing/default fields gracefully.
   - *Contract phase* (drop/rename columns, tighten `NOT NULL`): Deploy only **after** old code traffic is completely drained.
2. **Error Discriminator for Retries**:
   - Never blindly retry all failures.
   - *Retryable* (exponential backoff + jitter / honor `Retry-After`): transient network timeouts, `408`, recoverable `409`, `429` rate limits, sporadic `500/502/503/504`.
   - *Non-retryable* (fail fast + alert): `400/401/403/404/422`, DB schema errors.
3. **True Idempotency & Resume for Paid APIs**:
   - Pass deterministic `Idempotency-Key` to external paid APIs.
   - Persist local `IN_FLIGHT` state (`task_id` + request fingerprint) before calling, update to `COMPLETED` after; on retry, skip `COMPLETED` steps and reconcile `IN_FLIGHT` before re-billing.
4. **Isolated Env API Keys & Dual Budget Circuit Breakers**:
   - Strictly separate dev/staging/prod API keys.
   - Implement **application-level** hard circuit breakers (per-task, per-user, daily token/call caps) in addition to provider dashboard limits.
5. **Bad-Path Testing**:
   - Explicitly test network/DB disconnects, sustained `5xx` or `429` throttling, duplicate concurrent triggers, and quota exhaustion to prove graceful degradation and bounded cost.
