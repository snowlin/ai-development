# `ai-dev` 中文导读手册

> 本手册写给你自己阅读与维护用；AI 执行时直接读取精炼的英文 `SKILL.md`、`playbooks/`、`principles/` 和 `gates/`，兼顾执行准确度与低 Token 消耗。

---

## 1. 整体结构一眼看懂

- **[SKILL.md](file:///Users/lingxr/Documents/myproduct/ai-development/skills/ai-dev/SKILL.md)**：总控入口。AI 每次被触发时只读它，根据你的任务类型自动路由到下面对应的剧本和门禁。
- **[../product-selection/SKILL.md](file:///Users/lingxr/Documents/myproduct/ai-development/skills/product-selection/SKILL.md)**：独立立项/选品 Skill，写代码前先用它判断“值不值得做”（默认 NO，必须靠证据反转）。
- **`playbooks/`（8 个高频执行剧本）**：
  - `investigation.md`：只读调研（查源码、查 git 历史，不改文件，结论带证据级别）。
  - `bug-fix.md`：修 Bug（先复现 → 追根因 → 最小修复 → 补行为测试）。
  - `feature.md`：新功能（先过 IPSI-G/系统骨架 → UI 草图确认 → 定数据结构 → 小步闭环）。
  - `refactoring.md`：重构（先保测试基线 → 先删死代码 → 一步切完不留兼容包袱）。
  - `prototype.md`：原型实验（有技术/交互分歧时，先写低成本一次性原型用实测结果拍板，不空聊）。
  - `perf-issue.md`：性能优化（先抓基线 → 找到真实瓶颈 → 改完同条件复测对比）。
  - `opening-a-pr.md`：提交与 PR（清理 AI 废话注释/无关改动 → 规范提交 → 写简报式 PR 说明）。
  - `autonomous-run.md`：长任务/通宵模式（可逆操作自主推进，不可逆操作才暂停，分步验证）。
- **`gates/`（你原有的核心产品与上线护城河）**：
  - `ipsi-and-skeleton.md`：IPSI-G + 系统骨架 5 问（角色权限、数据归属、状态流转、失败路径、可观测性）。
  - `productization.md`：商业化边界（用户归属、用量记录、额度、成本控制）。
  - `production-5-gates.md`：AI 产品上线前必过 5 道关卡（DB Expand/Contract、重试错误鉴别器、计费 API 幂等断点续传、环境 Key 隔离与双熔断、坏路径测试）。
  - `git-workflow.md`：分支、暂存、Conventional Commits 与回滚规范。
- **`principles/`（24 条工程原则）**：吸收自 `pstack`，按需读取，防止 AI 写过度抽象、掩盖根因或只测实现细节的代码。

---

## 2. 怎么在日常开发中使用

1. **挂载 Skill 到所有 AI 工具**：运行仓库里的 `./scripts/sync-skills.sh`，它会通过软链把 `skills/ai-dev` 和 `skills/product-selection` 分发到本机各个 AI 工具的全局 skills 目录。
2. **新开主力项目（可选）**：在项目目录下运行 `ai-init .`（瘦身版），只生成项目专属的 `PROJECT.md` 和极薄的 `AGENTS.md` 入口，不再往业务仓库塞几十 KB 的通用文档。
3. **外部/临时项目**：直接口头说或用 `/ai-dev` 呼出即可，零文件侵入。

---

## 3. 24 条原则速查（遇到对应场景 AI 会按需加载）

- **核心类**：`laziness-protocol`（能删不加，最小改动）、`foundational-thinking`（先定数据结构）、`redesign-from-first-principles`（从第一性原理重设计）、`attack-the-premise`（连错两次就质疑前提）、`subtract-before-you-add`（先减后加）、`minimize-reader-load`（减少跳转层数）、`outcome-oriented-execution`（迁移直奔终态）、`experience-first`（体验优先）、`exhaust-the-design-space`（多原型对比）、`build-the-lever`（批量活写脚本/工具）。
- **架构类**：`model-the-domain`（状态机/类型替代散落 if/else）、`boundary-discipline`（边界校验、内部纯函数）、`type-system-discipline`（非法状态不可表示）、`make-operations-idempotent`（操作幂等）、`migrate-callers-then-delete-legacy-apis`（迁移完即删旧接口）、`separate-before-serializing-shared-state`（先隔离共享状态再考虑加锁）。
- **验证类**：`prove-it-works`（用真实运行结果证明）、`fix-root-causes`（修最早出错点）、`sequence-verifiable-units`（拆成可验证小步）、`test-behavior-not-implementation`（测行为不测实现）、`explain-the-number`（先找瓶颈再报数字）。
- **协作与元规则**：`guard-the-context-window`（大读取丢给子代理保护上下文）、`never-block-on-the-human`（可逆操作别卡在问人上）、`encode-lessons-in-structure`（重复叮嘱的规则变成 lint/脚本）。
