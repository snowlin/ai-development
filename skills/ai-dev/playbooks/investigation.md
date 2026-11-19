# Playbook: Investigation (Read-Only)

Use for questions like "how does X work", "why was Y built this way", or "what breaks if we change Z".

## Steps

1. **Scope**: Restate the question and identify the entry points, symbols, or git history to inspect. Do not edit source files.
2. **Trace real code & history**:
   - Follow actual call chains (`input -> transform -> output`) in source files.
   - For "why" questions, check `git log` / commit messages / docs rather than guessing intent from code alone.
3. **Isolate bulk**: If tracing spans many files, delegate exploration to a read-only subagent (`guard-the-context-window`).
4. **Report with evidence**:
   - Lead with the direct conclusion (`Conclusion -> Skeleton -> Details`).
   - Cite exact file paths, line ranges, and symbols observed.
   - Explicitly separate `Measured` / observed facts from `Inferred` conclusions, and state what remains unknown.
