# Playbook: Performance Issue

Use when investigating and improving measured slowness, high CPU/memory, or latency regressions.

## Steps

1. **Establish a baseline**: Capture a reproducible benchmark or trace (CPU profile, heap snapshot, timing script) before changing code. Record environment, input size, and variance.
2. **Explain the number (`principles/explain-the-number.md`)**: Identify the actual bottleneck (I/O, N+1 query, serialization, render loop, lock contention) and rule out measurement artifacts.
3. **Optimize the bottleneck**: Change only what targets the measured bottleneck. Avoid speculative micro-optimizations.
4. **Verify before/after**: Re-run the exact baseline benchmark under the same conditions, verify behavior tests still pass, and report before/after numbers as `Measured`.
