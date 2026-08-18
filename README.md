# AI Development

用于给项目初始化一套 AI 开发协议文件，方便 Codex、OpenCode、Claude Code、Gemini CLI 等工具读取统一的项目规则和上下文文档。

这套协议的核心是：先用 IPSI-G 防止 AI 在产品未定义时过早写代码；新产品、新功能或新页面进入实现前，用 System Skeleton Gate 检查用户角色、后台管理、数据归属、权限边界、状态流转、异常处理和 MVP 暂不实现，避免开发到一半才发现缺用户体系或后台；新开发页面先用 UI Draft First 确认界面方向；涉及高风险判断时用 Human Judgment Gate 区分事实、推测、反例和人的判断；多轮对话或阶段切换时用 Context Management Gate 防止上下文污染；把决策、实现、验证或发布交给 AI 前用 Trust Calibration Gate 明确授权边界；review AI 生成 diff 前用 Review Load Budget Gate 控制审查负担；开发中发现新需求或范围变宽时，用 Requirement Discovery / Scope Triage Gate 区分主路径缺口、产品地基、体验增强、未来商业化和可选项；涉及算法复杂度、性能、并发、网络、安全、权限、跨模块 Bug 或架构取舍时，用 CS Core / Mental Model Gate 明确人类必须理解的计算机科学核心概念；涉及分支、提交、PR、合并或回滚时用 Git 管理规范保护历史和用户改动；个人工具、原型或内部工具准备给别人用、未来收费或产生 AI/API 成本时，用 Productization Boundary Gate 提前检查用户身份、数据归属、使用记录、权益额度和成本控制；原型进入真实用户或生产前用 Production Readiness Gate 检查上线条件；如果涉及界面、数据、安全、性能、AI 行为、依赖、成本或兼容性，再用对应 Gate 明确边界、指标和验证方式；实现前用 TDD 定义可验证行为；开发中用 AI-XP 短反馈循环约束 AI 的快速执行；交付前用 Documentation、Verification、Release / Rollback Gate 防止代码、文档、验证和上线脱节。

## 会创建什么

执行初始化后，会在目标项目中创建：

- `AGENTS.md`：Codex / OpenCode 使用的项目规则
- `CLAUDE.md`：Claude Code 使用的极薄入口，导入 `AGENTS.md` 和 `PROJECT.md`
- `GEMINI.md`：Gemini CLI fallback 说明
- `.gemini/settings.json`：让 Gemini 默认读取 `AGENTS.md`
- `PROJECT.md`：产品规划、需求说明、IPSI-G Gate 状态、System Skeleton Gate、UI Draft First、UI/UX 策略、数据策略、安全策略、性能策略、AI 评估、Human Judgment、上下文管理、AI 信任校准、review 预算、需求发现与范围分流、CS 核心心智模型、产品化边界、生产就绪、依赖策略、成本策略、兼容策略、TDD 策略、AI-XP 短反馈记录、文档策略、验证记录、发布回滚和需求变化记录
- `docs/gates.md`：详细 Gate 清单，只在对应 Gate 被激活时读取
- `templates/product-selection.md`：可选 Product Selection Gate 完整方法论，不会复制到每个项目
- `templates/product-selection-trigger.md`：跨 AI 工具复用的轻量常驻触发规则
- `docs/product-selection-integration.md`：Codex、Claude、Cursor、Gemini、ChatGPT 等工具的接入原则
- `docs/project-map.md`：项目地图
- `docs/architecture.md`：架构说明
- `docs/data-flow.md`：数据流说明
- `docs/decision-log.md`：技术决策记录
- `docs/learning-notes.md`：学习记录
- `docs/git-workflow.md`：Git 分支、提交、PR、review、合并、回滚和 AI 协作规范
- `prompts/github-review.md`：GitHub PR 评审提示词
- `prompts/feature-design.md`：功能设计提示词
- `prompts/bug-fix.md`：问题修复提示词
- `prompts/refactor.md`：重构提示词

如果目标文件已经存在，脚本会按文件类型处理：

- 协议入口文件：`AGENTS.md`、`CLAUDE.md`、`GEMINI.md`、`docs/gates.md` 会升级为当前最新模板；只有最终内容确实变化时，旧文件才会备份到 `.ai-development-backups/`。
- 项目资料文件：`PROJECT.md`、`docs/project-map.md`、`docs/architecture.md`、`docs/data-flow.md`、`docs/decision-log.md`、`docs/learning-notes.md`、`docs/git-workflow.md` 和 `prompts/` 会保留原内容，并更新 `ai-development` 标记块。

如果你需要在协议入口文件里保留项目专属规则，请放在本地补充标记中：

```md
<!-- ai-development:local start AGENTS.md -->
这里写项目专属规则。
<!-- ai-development:local end AGENTS.md -->
```

再次执行 `ai-init` 时，本地补充会被保留到新版协议末尾。

## 直接使用

### 项目创建前：先做 Product Selection

如果还没有项目目录，但已经在讨论新产品、新 SaaS、新 AI 功能或重大方向，不需要先运行 `ai-init`。直接让 AI 读取中央模板：

```text
请读取 /Users/lingxr/Documents/myproduct/ai-development/templates/product-selection.md，
对下面的想法执行 Product Selection Gate。不要写代码；请输出事实、假设、未知、
最大未知、最便宜的决定性测试，以及 Continue / Define Only / Parking Lot / Reject 决策。
```

把结果保存在项目外的想法记录中，例如 `~/product-ideas/<idea-name>.md` 或一个独立笔记，而不是复制到未来项目。只有决定继续后，再执行 `ai-init <project-dir>`，并将 Product Selection 的结论摘要填入新项目的 `PROJECT.md` 的 Idea / Product 部分。

这样可以区分两个阶段：

- 项目创建前：中央模板负责选择、验证和是否投入的判断。
- 项目创建后：项目级 `PROJECT.md` 记录已确认的结论，`docs/gates.md` 只保留按需触发规则。

### 跨 AI 工具自动触发

为了避免忘记 Product Selection，不要只依赖手动输入文件名。将 `templates/product-selection-trigger.md` 放入目标工具的全局 Instructions、Rules 或 Skill 中；完整的 `templates/product-selection.md` 仍然只保留一份，触发后按需读取。具体适配方式见 `docs/product-selection-integration.md`。

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

执行前先确认脚本路径存在，并检查 `~/.zshrc` 里是否已经有 `ai-init`，避免重复追加：

```bash
test -f /Users/lingxr/Documents/myproduct/ai-development/scripts/init-ai-project.sh
grep -n 'alias ai-init=' ~/.zshrc 2>/dev/null || true
```

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
4. 打开生成的 `AGENTS.md`，补充少量项目专属常驻规则。
5. 让 AI 先读取 `PROJECT.md` 和 `AGENTS.md`，判断任务等级和 Gate 激活清单。
6. 如果涉及系统骨架、UI、数据、安全、性能、AI、Human Judgment、上下文管理、AI 授权、依赖、成本、兼容、CS 核心概念、TDD、AI-XP、review、需求发现与范围分流、Git 管理、产品化边界、文档、验证、生产就绪或发布回滚，只读取 `docs/gates.md` 中对应 Gate 章节。
7. 新产品、新 SaaS、新 AI 功能或重大方向选择时，激活 Product Selection Gate；按需读取 ai-development 仓库中的 `templates/product-selection.md`，不要把完整模板复制到项目中。
8. 新产品、新功能或新页面涉及 UI 时，先通过 Idea / Product / System Gate，再执行 UI Draft First。
9. UI Draft First 输出线框图、低保真 UI 图、ASCII 布局、Mermaid 流程或可预览原型，确认方向后再开发。
10. 多轮对话、阶段切换、AI 反复犯错或上下文变乱时，执行 Context Management Gate。
11. 将决策、实现、验证、发布或高风险操作交给 AI 前，执行 Trust Calibration Gate。
12. 新产品、新功能或新页面进入实现前，要求 AI 执行 System Skeleton Gate，先检查用户角色、后台管理、数据归属、权限、状态和异常处理。
13. 进入实现前，要求 AI 说明本次闭环、修改文件、验证方式和回退方式。
14. Review AI 生成 diff 前，先选择 Light / Targeted / Full Review，明确必看文件和风险焦点。
15. 验证前先选择 Light / Targeted / Full Verification，说明为什么这个强度与风险匹配。
16. 涉及算法复杂度、性能、并发、网络、安全、权限、跨模块 Bug 或架构取舍时，执行 CS Core / Mental Model Gate。
17. 开发中发现新需求或范围变宽时，执行 Requirement Discovery / Scope Triage Gate，决定 Do Now / Define Only / Parking Lot / Reject。
18. 涉及分支、提交、PR、合并或回滚时，读取 `docs/git-workflow.md`。
19. 个人工具、原型或内部工具准备给别人用、未来收费或产生 AI/API 成本时，执行 Productization Boundary Gate。
20. 原型进入真实用户、生产、团队协作或长期维护前，执行 Production Readiness Gate。
21. 验证通过后，如果需要小重构，只允许做一次能改善重复、命名、数据流或可测试性的重构，并再次运行同一验证。
22. 交付前，要求 AI 明确验证预算、验证结果、未验证项、学习点和剩余风险。

## Productization Boundary Gate

当个人工具、原型或内部工具可能给别人用、未来收费、限制额度或产生 AI/API 成本时，先执行 Productization Boundary Gate。

固定提问：

```text
请执行 Productization Boundary Gate：
1. 当前形态：Personal Tool / Internal Tool / Beta Product / Paid Product
2. 目标使用者：只有自己、少量熟人、真实用户、团队还是客户
3. 数据归属：哪些数据需要 owner_id 或 user_id
4. 使用记录：哪些 AI/API 行为需要 usage_events
5. 权益额度：是否需要 plan、quota、feature entitlement 或 BYOK
6. 暂不实现：如果不做用户体系，未来什么条件触发补齐
7. 最小预留：current_user、owner_id/user_id、usage_events、plan/quota 的最小策略
```

原则：

- 商业化地基不是支付按钮，而是用户身份、数据归属、使用记录、权益边界和成本控制。
- 个人工具可以先默认 `current_user = owner`，但保存、历史、笔记、知识库、报告和 AI/API 调用要明确未来归属。
- 支付、订阅、积分或早鸟 Pro 应晚于身份、使用记录、权益和成本边界。

## Human Judgment Gate

AI 可以提供模式识别、方案生成、总结和推理辅助，但 AI 的输出不能自动等同于真实理解、事实正确或价值判断。

触发场景：

- 产品方向
- 架构选择
- 安全判断
- 性能判断
- 商业判断
- UI 审美
- 学习路线
- 高风险决策
- AI 输出看起来很有道理但没有证据

固定提问：

```text
请执行 Human Judgment Gate：
1. Checkable Evidence：可验证事实
2. AI Assumption：AI 推测
3. Human Judgment：需要我亲自判断的部分
4. Counterexample：可能反例或失败场景
5. Verification：下一步验证方式
```

原则：

- AI 负责生成可能性。
- 人负责判断真实性和重要性。
- 没有证据的内容必须标记为推测。

## Context Management Gate

当对话超过一个开发闭环、AI 前后说法不一致、反复犯同类错误、需求阶段发生变化，或你感觉“上下文开始混乱”时，先整理上下文，再继续开发。

固定提问：

```text
请执行 Context Management Gate：
1. 当前可信上下文是什么？
2. 已确认决策有哪些？
3. 当前激活哪些 Gate？
4. 哪些信息可能过期、冲突或未经验证？
5. 是否建议压缩上下文、重开任务或重新确认需求？
6. 下一闭环是什么？
```

通过标准：

- AI 后续回答只使用当前可信上下文。
- 过期、冲突或未经验证的信息被明确标记。
- 用户能一眼看到哪些内容需要重新确认。

## Trust Calibration Gate

当你准备把决策、实现、验证、依赖变更、数据操作、发布或回滚交给 AI 时，先确认 AI 的权限级别。

| 权限级别 | AI 可以做什么 | 必须用户确认 |
| --- | --- | --- |
| Suggest | 只给建议、方案、风险和验证方式 | 所有文件修改和命令执行 |
| Draft | 生成草案、补全文档、准备 patch | 应用修改、运行高风险命令 |
| Modify | 修改低风险文件、运行低风险验证 | 依赖、数据、权限、发布、删除 |
| Execute | 执行已确认闭环内的修改和验证 | 不可逆操作、高风险上线、真实数据变更 |

通过标准：

- AI 权限边界明确。
- 高风险操作有人工确认点。
- 禁止项被写清楚，而不是靠 AI 自己猜。

## Review Load Budget Gate

当 AI 生成 diff、修改核心路径、跨多个文件改动，或你准备 review AI 输出时，先确定 review 预算。

| Review 级别 | 适用场景 | 用户重点看什么 |
| --- | --- | --- |
| Light Review | 文案、注释、局部样式、非关键文档 | 改动意图是否正确 |
| Targeted Review | 单个功能闭环、API 调整、状态流变化 | 关键文件、调用链、边界条件 |
| Full Review | 数据写入、权限、安全、AI 输出、发布前 | 全部 diff、风险路径、回滚方案 |

原则：

- AI 不能把所有文件都丢给用户“自己看一下”。
- 必须指出必看文件、可看摘要文件、关键调用链和风险点。
- review 负担要与改动风险匹配。

## Production Readiness Gate & 上线前 5 道必过关卡

当原型、内部工具或实验功能准备进入真实用户、生产环境、团队协作或长期维护时，执行 Production Readiness Gate。

| 阶段 | 判断标准 |
| --- | --- |
| Prototype | 可以不完整，但必须标记为原型，不能伪装生产能力 |
| Internal Tool | 可给自己或小范围使用，需要基本错误处理和数据保护 |
| Beta | 可给真实用户试用，需要监控、反馈入口和回滚方式 |
| Production | 面向正式使用，需要 owner、日志、告警、安全、备份和回滚，且必须核对上线前 5 道必过关卡 |

### AI 产品上线前必过 5 道关卡 Check List (阶段化防护)

1. **数据库变更优先于代码部署 (Data Gate & Release Gate)**：
   - *新项目冷启动*：直接跑全量版本化 Migration。
   - *存量项目迭代*：Migration 必须优先上线；新代码强制向前兼容（`NULLABLE` / `DEFAULT` 与 Fallback 避免 500）；涉及删/改列必须采用 `Expand & Contract`（两阶段扩展与收缩双写）。
2. **为任务重试配备“错误鉴别器” (Performance Gate & System Gate)**：
   - *可重试*：网络超时、偶发 5xx 等，配合 Exponential Backoff（指数退避）。
   - *不可重试*：4xx 客户端错误、SQL 字段不存在等确定性失败，**立即终止任务并报警**。
3. **计费 API 任务实现幂等性与断点续传 (Cost Gate & Productization Gate)**：
   - 在数据库记录 `task_id` + `status`，重试时自动跳过已完成的高成本 LLM/付费 API 调用。
4. **彻底隔离环境 API Key 并设置预算硬上限 (Security Gate & Cost Gate)**：
   - 生产与测试环境 Key 彻底隔离；后台配置 **Hard Limit（硬上限强熔断）** 防死循环刷爆卡，配置 **Soft Limit（软上限预警）**。
5. **上线前进行“坏路径”（Bad Path）场景测试 (Verification Gate & Production Gate)**：
   - 显式测试断网/DB断连、第三方 500、并发重复触发、额度耗尽，验证系统优雅降级而非死循环放大费用。

固定检查：

- 是否涉及真实用户、真实账号、真实数据或真实费用。
- 是否已核对“上线前必过的 5 道关卡 Check List”。
- 是否有监控、日志、错误处理、备份和回滚方式。
- 是否有维护 owner 和停止条件。
- 哪些生产缺口还没有补齐。

## UI Draft First

新产品、新功能或新页面涉及 UI 时，必须先验证产品和系统闭环，再确认 UI 方向，最后进入实现。

推荐顺序：

```text
Idea Gate
-> Product Gate
-> System Gate
-> UI Draft First
-> Implementation Gate
-> Development
-> Verification
```

原则：

- UI 草图不能替代产品定义。
- UI 草图不能替代 MVP 边界。
- UI 草图不能替代系统数据流。
- UI 未确认时，不直接开发新页面。

可接受的 UI 草图形式：

- 线框图
- 低保真 UI 图
- ASCII 布局
- Mermaid 页面流程
- 可预览原型
- 已确认的参考截图、Figma 或设计系统组件

草图必须说明：

- 核心用户动作
- 页面区域
- 主要组件
- 加载、空状态、错误、成功、禁用、编辑、确认、撤销等关键状态
- 颜色方向和参考规范

可跳过的情况：

- 只改文案、图标、间距、颜色 token 或单个已有组件内的小样式。
- 已有确认过的设计稿、截图、Figma、参考页面或组件规范。
- 用户明确要求直接实现，并接受后续按实现结果微调。

## AI-XP 短反馈循环

AI-XP 不是完整照搬 XP，而是把 XP 的短反馈循环用于 Human-AI Pair Programming。

每个实现闭环遵守：

1. 先定义验证命令或手动验证步骤。
2. TDD Gate 激活时，先说明 Red / Green。
3. 验证通过后，最多做一次小重构。
4. 小重构后再次运行同一验证。
5. 阶段结束时记录 1-3 个学习点、黑盒风险或后续理解入口。

## Verification Budget

验证不是越多越好，而是要与改动风险匹配。

| 级别 | 适用场景 | 执行 |
| --- | --- | --- |
| Light Verification | 文案修改、样式微调、单页面非关键 UI 调整、不涉及数据/AI/权限/写入 | 只跑相关测试，或 typecheck，或可复现手动检查 |
| Targeted Verification | 单个功能闭环、API 调用链调整、页面请求方式变化、非持久化 AI 输出 | 跑相关前端/后端测试，跑 typecheck |
| Full Verification | 数据写入、审核流程、AI 模型调用、保存到知识库、架构边界变化、发布前检查 | 后端测试全集、前端测试全集、typecheck、build |

原则：

- 不伪造验证结果。
- 没跑就明确写未执行。
- 不为了省 token 跳过关键链路验证。
- 不为了形式主义对小改动做过度验证。

## Token 控制方式

协议已经拆成常驻规则和按需清单。`AGENTS.md` 保持短上下文，`docs/gates.md` 只在 Gate 被激活时读取。

推荐使用方式：

1. 每次任务先让 AI 输出任务等级和 Gate 激活清单。
2. Simple 任务不读取 `docs/gates.md`。
3. Standard 任务只读取被激活的 Gate 章节。
4. High-risk 任务读取对应 Gate 和 Release / Rollback Gate。
5. 只有做完整审计、上线前检查或高风险改动时，才展开全部 Gate。

示例：

```text
请先判断本次任务需要激活哪些 Gate。
只展开激活 Gate。
不适用 Gate 用一行说明原因。
不要读取完整 docs/gates.md，除非这是完整审计或上线前检查。
```

## Gate 参考标准

Security Gate 默认参考：

- OWASP Top 10:2025
- OWASP ASVS 5.0.0
- OWASP API Security Top 10 2023
- OWASP Top 10 for LLM Applications 2025
- NIST SSDF SP 800-218

Performance Gate 默认参考：

- Core Web Vitals：LCP <= 2.5s、INP <= 200ms、CLS <= 0.1
- Lighthouse：Performance、Accessibility、Best Practices、SEO
- 后端服务指标：P50 / P95 / P99、RPS/QPS、错误率、CPU、内存、数据库耗时、队列深度、缓存命中率、外部 API 耗时
- OpenTelemetry：Traces、Metrics、Logs

其他 Gate 默认参考：

- Data Gate：W3C Data on the Web Best Practices、ISO/IEC 25012、数据质量维度
- AI Evaluation Gate：NIST AI RMF、OpenAI Evals、OWASP LLM / GenAI
- Human Judgment Gate：Checkable Evidence、Assumption Labeling、Counterexample、Verification、Human-in-the-loop Decision
- Context Management Gate：可信上下文清单、上下文压缩、过期上下文检测、冲突信息标记
- Trust Calibration Gate：AI 权限分级、Human-in-the-loop、Least Privilege、不可逆操作人工确认
- Dependency Gate：Twelve-Factor App、OpenSSF Scorecard、npm package.json、Python Packaging
- Cost Gate：FinOps Framework、FinOps Usage Optimization、OpenAI API rate limit guidance
- Compatibility Gate：MDN Baseline、npm engines / os / cpu、Python Requires-Python
- CS Core / Mental Model Gate：算法复杂度、数据结构、性能、并发、网络、缓存、安全、权限、跨模块 Bug、架构取舍
- AI-XP Feedback Gate：Extreme Programming 的短反馈循环、Human-AI Pair Programming、TDD Red / Green / Refactor
- Documentation Gate：Diataxis、Google Developer Documentation Style Guide、NLPM 规则
- Review Load Budget Gate：review 预算、必看文件、关键调用链、二次 review 条件
- Requirement Discovery / Scope Triage Gate：Core Path、Product Foundation、UX Enhancement、Future Monetization、Nice-to-have、Parking Lot
- Git Management Gate：trunk-based workflow、Conventional Commits、PR review、squash merge、revert rollback、AI 协作边界
- Productization Boundary Gate：用户身份、数据归属、使用记录、权益额度、AI/API 成本控制、BYOK、手动 Pro
- System Skeleton Gate：用户角色、后台管理、数据归属、权限边界、状态流转、异常处理、MVP 暂不实现
- Verification Gate：Verification Budget、Lint、Type Check、Unit Test、Integration / E2E Test、Build、Manual Verification
- Production Readiness Gate：生产就绪清单、Observability、Error Handling、Backup、Rollback、Owner
- Release / Rollback Gate：Google SRE Release Engineering、Google SRE rollback practice、Twelve-Factor Build / Release / Run、DORA metrics

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
- 如果目标项目里已经存在协议入口文件，脚本会把最新版模板放到文件顶部，并备份旧文件。
- 如果目标项目里已经存在项目资料 Markdown 文件，脚本会保留原内容，并更新 `ai-development` 标记块中的协议内容。
- 如果目标项目里已经存在 `.gemini/settings.json`，脚本会尝试把 `AGENTS.md` 合入 `context.fileName`；如果原文件不是合法 JSON，会生成 `.gemini/settings.json.ai-development.json` 参考文件，不会破坏原配置。
- 当前脚本使用的是本机固定模板目录：`/Users/lingxr/Documents/myproduct/ai-development/templates`。如果移动了这个项目目录，需要同步修改脚本里的 `TEMPLATE_DIR`。
- 这个工具只创建通用 AI 协议文件，不会自动配置第三方工具账号、API Key、MCP 服务或插件权限。
- Antigravity 如果没有自动读取项目规则，需要在对话里手动要求它读取 `AGENTS.md`。
