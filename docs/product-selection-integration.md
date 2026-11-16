# Product Selection 跨工具接入

`templates/product-selection.md` 是完整方法论的唯一事实来源，`templates/product-selection-trigger.md` 是跨工具复用的轻量触发规则。

不要把完整方法论复制到每个项目。根据 AI 工具的能力，把触发规则放入对应的全局 Instructions、Rules、Skill 或项目协议中；触发后再读取完整模板。

## 推荐接入方式

| 工具 / 环境 | 接入触发规则 | 完整模板读取方式 |
| --- | --- | --- |
| Codex CLI / Claude Code / WorkBuddy / Antigravity | 安装为公共 Skill（`~/.codex/skills/`）或合入全局 `~/.agents/AGENTS.md` | 触发后按需直接读取 `templates/product-selection.md` |
| 仅加载项目级 `AGENTS.md` 的环境 | 由项目 `AGENTS.md` / `docs/gates.md#2.1` 保留触发条件 | 触发时按需读取中央仓库的 `templates/product-selection.md` |
| 无本地文件系统权限的对话环境 | 在会话首轮粘贴 `templates/product-selection-trigger.md` | 触发后提供 `templates/product-selection.md` 全文 |

## 项目创建前

先让 AI 使用触发规则识别产品想法，再读取完整模板完成筛选。结果保存在独立想法记录中；确认继续后，才执行 `ai-init` 并把结论摘要写入 `PROJECT.md`。

## 维护规则

- 只维护一份完整方法论。
- 修改触发条件时同步更新各工具适配层。
- 工具适配层只包含触发和加载方式，不复制完整方法论。
