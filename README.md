# AI Development

用于给项目初始化一套 AI 开发协议文件，方便 Codex、OpenCode、Claude Code、Gemini CLI 等工具读取统一的项目规则和上下文文档。

## 会创建什么

执行初始化后，会在目标项目中创建：

- `AGENTS.md`：Codex / OpenCode 使用的项目规则
- `CLAUDE.md`：Claude Code 使用的项目规则
- `GEMINI.md`：Gemini CLI 使用的项目规则
- `docs/project-map.md`：项目地图
- `docs/architecture.md`：架构说明
- `docs/data-flow.md`：数据流说明
- `docs/decision-log.md`：技术决策记录
- `docs/learning-notes.md`：学习记录

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
3. 打开生成的 `AGENTS.md`，补充项目专属规则。
4. 让 AI 读取 `AGENTS.md` 和 `docs/` 下的文档，做第一次项目认知扫描。

