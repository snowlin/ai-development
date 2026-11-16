# Git 管理规范

本文件定义项目的 Git 分支、提交、PR、review、合并和回滚规则。

## 目标

- 让每次改动都有清晰原因、验证证据和回退路径。
- 让 AI 生成的改动可以被人类低成本 review。
- 避免把半成品、未验证代码、密钥或无关文件混进提交。
- 保持主分支随时接近可发布状态。

## 分支策略

默认采用轻量 trunk-based workflow：

- `main`：稳定主分支，只合并通过验证和 review 的改动。
- `feat/<short-name>`：新功能。
- `fix/<short-name>`：问题修复。
- `refactor/<short-name>`：不改变行为的重构。
- `docs/<short-name>`：文档和规则更新。
- `chore/<short-name>`：工具、脚本、依赖或维护性改动。
- `hotfix/<short-name>`：生产紧急修复。

原则：

- 一个分支只做一个可验证闭环。
- 分支名使用小写英文、数字和连字符。
- 长期实验可以使用 `experiment/<short-name>`，但不能直接合入 `main`。
- 不在同一分支混合功能、重构、格式化和无关文档。

## 提交规范

提交信息使用 Conventional Commits：

```text
type(scope): summary
```

常用类型：

| type | 用途 |
| --- | --- |
| feat | 新功能 |
| fix | Bug 修复 |
| refactor | 不改变行为的重构 |
| docs | 文档 |
| test | 测试 |
| chore | 构建、脚本、工具、依赖 |
| perf | 性能优化 |
| revert | 回滚提交 |

要求：

- summary 使用语义清晰的中文或祈使句简短描述（如 `feat(auth): 增加登录限流校验`），控制在一行内。
- 一个 commit 对应一个意图，不把无关改动揉在一起。
- 提交前检查 `git diff`，确认没有密钥、临时日志、调试输出或无关格式化。
- 如果改动来自 AI，提交说明或 PR 描述中写清验证命令和人工 review 焦点。

## 暂存规则

提交前必须分层检查：

```bash
git status --short
git diff
git diff --staged
```

原则：

- 只暂存本次闭环需要的文件。
- 工作区已有他人或用户改动时，不自动回滚、不覆盖、不顺手格式化。
- 不使用 `git add .` 暂存不确定内容；优先按文件暂存。
- 生成文件、锁文件、迁移文件必须说明来源和验证方式。

## PR 规范

PR 描述至少包含：

```text
## What

本次改了什么。

## Why

为什么需要这次改动。

## Verification

- [ ] lint / typecheck / test / build / manual verification

## Review Focus

需要 reviewer 重点看的文件、调用链或风险点。

## Rollback

如何撤回这次改动。
```

要求：

- PR 尽量小，能在 10-20 分钟内 review 完。
- UI、数据、安全、权限、AI 输出、依赖或发布相关 PR 必须写风险和回滚。
- 如果跳过测试，必须写明原因和剩余风险。
- 截图、录屏或日志只作为证据补充，不能替代可复现验证。

## Review 规则

Review 级别和项目协议里的 Review Load Budget 对齐：

| 级别 | 适用场景 | 必看内容 |
| --- | --- | --- |
| Light | 文档、注释、小脚本说明 | 改动意图是否正确 |
| Targeted | 单个功能闭环、Bug 修复、局部重构 | 关键文件、边界条件、验证结果 |
| Full | 数据、权限、安全、AI 行为、发布前 | 全部 diff、风险路径、回滚方案 |

原则：

- reviewer 优先看行为变化、数据流、错误处理、权限、安全和测试缺口。
- AI 生成的大段 diff 必须压缩成 review 焦点，不把审查负担全部丢给人。
- 发现问题时，优先要求补测试、缩小范围或拆 PR。

## 合并规则

- 合并前确认工作流检查通过，或明确记录未执行原因。
- 默认使用 squash merge，保持主分支历史清晰。
- 多 commit 保留历史只适用于迁移、逐步重构或需要审计的变更。
- 合并后可提示清理已完成分支，但实际删除分支（本地或远端）前必须先获得用户确认。
- 生产发布相关合并必须确认 Release / Rollback Gate。

## 回滚规则

优先使用可追踪回滚：

```bash
git revert <commit>
```

规则：

- 不在共享分支使用 `git reset --hard` 重写历史。
- 回滚 PR 必须说明影响范围、回滚原因和后续修复计划。
- 数据迁移、配置变更、发布操作必须有代码回滚以外的恢复步骤。
- 紧急修复可以先走 `hotfix/`，事后补齐验证和复盘。

## AI 协作规则

AI 可以直接做：

- 读取 `git status`、`git diff`、`git diff --staged`、`git log`。
- 解释 diff、整理 PR 描述、生成 review checklist。
- 在用户授权范围内修改文件并运行低风险验证。

AI 必须先确认：

- 创建或切换分支。
- 暂存、提交、推送、创建 PR。
- 修改依赖、迁移、权限、发布配置。
- 回滚、删除、重写历史或处理冲突。

AI 禁止自动做：

- 使用 `git reset --hard`、`git clean`、强推或删除远端分支。
- 覆盖用户未提交改动。
- 把未验证结果写成已验证。
- 把密钥、Token、个人信息、真实生产数据提交到仓库。

## 每次交付检查

```text
分支:
改动范围:
验证命令:
验证结果:
未验证项:
Review 级别:
回滚方式:
```
