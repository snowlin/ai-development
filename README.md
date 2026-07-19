# AI Development

用于给项目初始化一套 AI 开发协议文件，方便 Codex、OpenCode、Claude Code、Gemini CLI 等工具读取统一的项目规则和上下文文档。

## 会创建什么

执行初始化后，会在目标项目中创建：

- `AGENTS.md`：Codex / OpenCode 使用的项目规则
- `CLAUDE.md`：Claude Code 使用的项目规则
- `GEMINI.md`：Gemini CLI 使用的项目规则
- `PROJECT.md`：产品规划、需求说明、IPSI-G Gate 状态和需求变化记录
- `docs/project-map.md`：项目地图
- `docs/architecture.md`：架构说明
- `docs/data-flow.md`：数据流说明
- `docs/decision-log.md`：技术决策记录
- `docs/learning-notes.md`：学习记录
- `prompts/github-review.md`：GitHub PR 评审提示词
- `prompts/feature-design.md`：功能设计提示词
- `prompts/bug-fix.md`：问题修复提示词
- `prompts/refactor.md`：重构提示词

如果目标文件已经存在，脚本会跳过，不会覆盖已有内容。

## 直接使用

先给脚本增加执行权限：

```bash
chmod +x /Users/lingxr/Documents/myproduct/ai-development/scripts/init-ai-project.sh
```

在目标项目目录中执行：

```bash
/Users/lingxr/Documents/myproduct/ai-development/scripts/init-ai-project.sh .
```

也可以指定其他项目目录：

```bash
/Users/lingxr/Documents/myproduct/ai-development/scripts/init-ai-project.sh /path/to/your/project
```

## 设置 ai-init 命令

如果想在任意目录直接使用 `ai-init`，可以把它加到 zsh alias：

```bash
echo 'alias ai-init="/Users/lingxr/Documents/myproduct/ai-development/scripts/init-ai-project.sh"' >> ~/.zshrc
source ~/.zshrc
```

之后进入任意项目目录，执行：

```bash
ai-init .
```

`ai-init .` 表示初始化当前目录。

## 推荐流程

1. 进入你要初始化的项目目录。
2. 执行 `ai-init .`。
3. 打开生成的 `PROJECT.md`，按 IPSI-G 补充想法、产品、系统和 Gate 状态。
4. 打开生成的 `AGENTS.md`，补充项目专属规则。
5. 让 AI 读取 `PROJECT.md`、`AGENTS.md` 和 `docs/` 下的文档，先做 IPSI-G 分析，不要直接写代码。

## 系统兼容性限制

当前脚本是按照 macOS + zsh 环境编写的，脚本头部使用：

```bash
#!/bin/zsh
```

不同系统使用时需要注意：

- macOS：推荐使用方式，默认自带 zsh，可以直接使用本文档里的命令。
- Linux：如果系统没有 zsh，需要先安装 zsh，或者把脚本第一行改成 `#!/bin/bash` 后再使用。Linux 下的项目路径也需要改成自己的真实路径。
- Windows：不能在原生 CMD 或 PowerShell 里直接运行这个 `.sh` 脚本。推荐使用 WSL、Git Bash 或其他类 Unix shell 环境；如果要在 PowerShell 原生环境使用，需要另外写 `.ps1` 脚本。

`ai-init` 这个命令也不是系统自带命令。macOS 和 Linux 通常写入 `~/.zshrc` 或 `~/.bashrc`；Windows 的 WSL / Git Bash 也需要写入对应 shell 的配置文件。

## 其他限制

- 当前脚本只负责初始化协议文件和基础文档，不会自动分析项目代码，也不会自动补全项目专属规则。
- 如果目标项目里已经存在同名文件，脚本会跳过，不会覆盖已有内容。
- 当前脚本使用的是本机固定模板目录：`/Users/lingxr/Documents/myproduct/ai-development/templates`。如果移动了这个项目目录，需要同步修改脚本里的 `TEMPLATE_DIR`。
- 这个工具只创建通用 AI 协议文件，不会自动配置第三方工具账号、API Key、MCP 服务或插件权限。
- Antigravity 目前不会自动读取专属配置文件，需要在对话里手动要求它读取 `AGENTS.md`。
