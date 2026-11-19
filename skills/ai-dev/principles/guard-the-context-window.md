# Guard the Context Window

- **When to apply**: Reading large files, running broad searches, or fanning out exploration.
- **Rule**: Offload bulk exploration to subagents or targeted `rg` searches; keep concise summaries in the main thread.
- **Avoid**: Dumping entire 1,000-line files or raw command logs into the main conversation.
