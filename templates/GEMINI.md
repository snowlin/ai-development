# Gemini CLI fallback

本项目以 `AGENTS.md` 为统一 AI 开发协议，以 `PROJECT.md` 为产品规划、需求说明和系统边界来源。

如果当前工具没有自动读取项目上下文，请先读取：

- `AGENTS.md`
- `PROJECT.md`

详细 Gate 清单在 `docs/gates.md`。只在对应 Gate 被激活时读取相关章节。

`.gemini/settings.json` 会让 Gemini 默认读取 `AGENTS.md`。
