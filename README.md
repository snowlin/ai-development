# AI Development

用于给项目初始化一套轻量、高信噪比的 AI 开发协议文件，方便 Codex CLI、Claude Code、WorkBuddy / CodeBuddy、Gemini CLI / Antigravity 等工具读取统一的项目规则和上下文文档。

这套协议的核心是：先用 IPSI-G 防止 AI 在产品未定义时过早写代码；新产品或涉及多角色/持久化数据/计费的模块进入实现前，按需用 System Skeleton Gate 与 Productization Boundary Gate 检查数据归属、权限边界与成本控制（个人单机小工具默认豁免，防止过度设计）；新开发页面先用 UI Draft First 确认界面方向；涉及高风险判断时用 Human Judgment Gate 区分事实、推测、反例和人的判断；原型进入真实用户或生产前用 Production Readiness Gate 与《上线前 5 道必过关卡》核对数据库 Expand/Contract 迁移顺序、重试错误鉴别器、计费 API 幂等与双重预算熔断；交付时按改动风险匹配验证预算（纯文档/注释/孤立微调享受零开销免验证极速交付）。

## 会创建什么

执行初始化后，会在目标项目中创建精简的核心协议文件（不再生成空白的 `prompts/*.md` 与空白的 `docs/*.md` 占位空壳）：

- `AGENTS.md`：Codex CLI / WorkBuddy / Antigravity / OpenCode 使用的常驻项目协议（Version 3.0，约 190 行高信噪比路由表与核心红线）
- `CLAUDE.md`：Claude Code 使用的极薄入口，导入 `AGENTS.md` 和 `PROJECT.md`
- `GEMINI.md`：Gemini CLI / Antigravity 兜底说明
- `.gemini/settings.json`：让 Gemini 默认读取 `AGENTS.md`
- `PROJECT.md`：精简的跨会话项目事实源（仅保留产品定位与 MVP 边界、系统与数据流、按需系统骨架/产品化边界、上线前 5 道必过关卡核对表、关键决策变化记录 5 个核心模块，不再重复维护 23 个 Gate 的静态空表）
- `docs/gates.md`：详细 Gate 清单，只在对应 Gate 被激活时按需读取对应章节
- `docs/git-workflow.md`：Git 分支、提交、PR、review、合并、回滚和 AI 协作规范
- `templates/product-selection.md`（位于本仓库）：可选 Product Selection Gate 完整方法论，不会复制到每个项目
- `templates/product-selection-trigger.md`（位于本仓库）：跨 AI 工具复用的轻量常驻触发规则
- `docs/product-selection-integration.md`（位于本仓库）：Codex CLI、Claude Code、WorkBuddy、Antigravity 等工具的接入原则

> 注：架构说明（`docs/architecture.md`）、数据流（`docs/data-flow.md`）、技术决策记录（`docs/decision-log.md`）等文档仅在项目有真实沉淀内容时按需创建，避免空白模板文件干扰 AI 上下文。

如果目标文件已经存在，脚本会按文件类型处理：

- 协议入口文件：`AGENTS.md`、`CLAUDE.md`、`GEMINI.md`、`docs/gates.md` 会升级为当前最新模板；只有最终内容确实变化时，旧文件才会备份到 `.ai-development-backups/`。
- 项目资料文件：`PROJECT.md` 和 `docs/git-workflow.md` 会保留原内容，并更新 `ai-development` 标记块。

如果你需要在协议入口文件里保留项目专属规则，请放在本地补充标记中：

```md
<!-- ai-development:local start AGENTS.md -->
这里写项目专属规则。
<!-- ai-development:local end AGENTS.md -->
```

再次执行 `ai-init` 时，本地补充会被保留到新版协议末尾。

## 直接使用

### 项目创建前：先做 Product Selection

如果还没有项目目录，但已经在讨论新产品、新 SaaS、新 AI 功能或重大方向，不需要先运行 `ai-init`。直接让 AI 读取本仓库的中央模板：

```text
请读取 templates/product-selection.md，
对下面的想法执行 Product Selection Gate。不要写代码；请输出事实、假设、未知、
最大未知、最便宜的决定性测试，以及 Continue / Define Only / Parking Lot / Reject 决策。
```

把结果保存在项目外的想法记录中，例如 `~/product-ideas/<idea-name>.md` 或一个独立笔记，而不是复制到未来项目。只有决定继续后，再执行 `ai-init <project-dir>`，并将 Product Selection 的结论摘要填入新项目的 `PROJECT.md` 的 Idea & Product 部分。

这样可以区分两个阶段：

- 项目创建前：中央模板负责选择、验证和是否投入的判断。
- 项目创建后：项目级 `PROJECT.md` 记录已确认的结论，`docs/gates.md` 只保留按需触发规则。

### 跨 AI 工具自动触发

为了避免忘记 Product Selection，不要只依赖手动输入文件名。将 `templates/product-selection-trigger.md` 放入目标工具的全局 Instructions、Rules 或 Skill 中；完整的 `templates/product-selection.md` 仍然只保留一份，触发后按需读取。具体适配方式见 `docs/product-selection-integration.md`。

先给脚本增加执行权限（使用 `/bin/chmod` 避免本机 shim 拦截）：

```bash
/bin/chmod +x ./scripts/init-ai-project.sh
```

在目标项目目录中执行：

```bash
/path/to/ai-development/scripts/init-ai-project.sh .
```

也可以指定其他项目目录：

```bash
./scripts/init-ai-project.sh /path/to/your/project
```

## 设置 ai-init 命令

如果想在任意目录直接使用 `ai-init`，可以把它加到 `~/.zshrc` alias（将 `<repo-path>` 替换为本仓库实际路径）：

```bash
grep -n 'alias ai-init=' ~/.zshrc 2>/dev/null || true
```

```bash
echo 'alias ai-init="<repo-path>/scripts/init-ai-project.sh"' >> ~/.zshrc
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

当任务涉及生产环境、真实数据改写、安全鉴权、权限调整、付费 API 调用或不可逆操作时，必须明确区分“底层沙箱能否执行”与“业务是否授权执行”：

- **AI 可直接执行**：低风险闭环内的代码修改、只读分析与定向验证。
- **必须用户确认**：删除数据/文件、数据库破坏性迁移（Contract 删列）、权限模型变更、消耗真实资金的批量 API 调用、Git 提交/推送/删分支与生产发布。

通过标准：

- 工具执行权限与业务授权边界清晰分离。
- 高风险与不可逆操作有明确人工确认点。

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

1. **数据库变更与代码部署分阶段对齐 (Data Gate & Release Gate)**：
   - *新项目冷启动*：直接跑全量版本化 Migration。
   - *存量迭代 · Expand 扩展阶段（加表/加可空列/加索引）*：DB Migration 必须先于新代码上线；新代码强制向前兼容（`NULLABLE` / `DEFAULT` 与 Fallback 避免 500）。
   - *存量迭代 · Contract 收缩阶段（删列/改名/收紧非空约束）*：采用 `Expand & Contract` 拆分发布，**破坏性 DB 收缩操作必须在旧版本代码完全下线、确认无旧读写流量之后才可执行**。
2. **为任务重试配备精准“错误鉴别器” (Performance Gate & System Gate)**：
   - *可重试（配合指数退避 Exponential Backoff + Jitter / `Retry-After`）*：网络瞬断、`408 Request Timeout`、`409` 可恢复并发冲突、**`429 Too Many Requests`（限流）**、偶发 `500/502/503/504`。
   - *不可重试（立即终止并告警）*：`400/401/403/404/422` 等确定性客户端错误、SQL Schema 错误（如字段不存在）。
3. **计费 API 任务实现真正幂等与断点续传 (Cost Gate & Productization Gate)**：
   - 优先向外部付费接口传递确定性幂等键（`Idempotency-Key`），并在本地数据库预写 `task_id` + 请求指纹 + `IN_FLIGHT` 中间态；重试时跳过已 `COMPLETED` 步骤，并核验崩溃遗留的 `IN_FLIGHT` 状态，防止“外部扣费成功但本地写库前崩溃”导致二次扣费。
4. **彻底隔离环境 API Key 并建立双重预算熔断 (Security Gate & Cost Gate)**：
   - 生产与测试环境 Key 彻底隔离；在**应用层代码自建单任务/单日调用次数与 Token 预算硬熔断器（Circuit Breaker）**，同时在服务商后台配置 **Hard Limit（若平台支持）** 与 **Soft Limit（软上限预警）**。
5. **上线前进行“坏路径”（Bad Path）场景测试 (Verification Gate & Production Gate)**：
   - 显式测试断网/DB断连、第三方 5xx/429、并发重复触发、额度耗尽，验证系统优雅降级而非死循环放大费用。

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

- ASCII 布局 / Mermaid 状态与页面流程（适合轻量快速对齐）
- 单文件可交互 HTML 原型 / Generative UI
- 线框图 / 低保真视觉草图
- 已确认的参考截图、Figma 或设计系统组件

草图必须说明：

- 核心用户动作
- 页面区域与主要组件
- 加载、空状态、错误、成功、禁用、编辑、确认、撤销等关键状态
- 信息层级与颜色策略

可跳过的情况：

- 只改文案、图标、间距、颜色 token 或单个已有组件内的小样式。
- 已有确认过的设计稿、截图、Figma、参考页面或组件规范。
- 用户明确要求直接实现，并接受后续按实现结果微调。

## AI-XP 短反馈循环

AI-XP 不是完整照搬 XP，而是把 XP 的短反馈循环用于 Human-AI Pair Programming。

每个实质性代码实现闭环遵守：

1. 先定义验证命令或手动验证步骤。
2. TDD Gate 激活时，先说明 Red / Green。
3. 验证通过后，最多做一次小重构。
4. 小重构后再次运行同一验证。
5. 阶段结束时记录 1-3 个学习点、黑盒风险或后续理解入口。

## Verification Budget

验证不是越多越好，而是要与改动风险严格匹配：

| 级别 | 适用场景 | 执行 |
| --- | --- | --- |
| **Exempt（零开销豁免）** | 纯文档、注释、排版、独立配置微调、不改变上下游调用的孤立文案/小样式改动 | **免编译、免测试、免写跳过理由**，直接极速交付 |
| **Light Verification** | 单页面非关键 UI 调整、辅助脚本改动（不涉及数据/AI/权限/写入） | 定向语法/类型检查，或可复现手动检查 |
| **Targeted Verification** | 单个功能闭环、API 调用链调整、页面请求方式变化、非持久化 AI 输出 | 跑相关前端/后端测试，跑 typecheck |
| **Full Verification** | 数据写入、审核流程、AI 模型调用、保存到知识库、架构边界变化、发布前检查 | 受影响测试全集、typecheck、build、Bad Path 测试 |

原则：

- 不伪造验证结果；没跑就明确写未执行。
- 纯文档和孤立微调零开销极速交付，不做形式主义重型验证。
- 核心业务、状态机与计费链路改动绝不跳过测试闭环。

## Token 与注意力控制方式

协议已拆分为常驻精简路由（`AGENTS.md`）与按需字典（`docs/gates.md`）：

1. `AGENTS.md` 控制在 ~190 行内，避免常驻上下文过长导致大模型指令注意力稀释（Instruction Dilution）。
2. Simple 任务不读取 `docs/gates.md`。
3. Standard / High-risk 任务只按 `AGENTS.md` 第 6 节路由表读取被激活的 Gate 章节。
4. 只有做完整审计或上线前全面检查时，才读取全部相关 Gate。

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
- Trust Calibration Gate：工具沙箱执行权与业务授权分离、高危不可逆操作人工确认
- Dependency Gate：Twelve-Factor App、OpenSSF Scorecard、npm package.json、Python Packaging
- Cost Gate：FinOps Framework、Idempotency-Key 幂等控制、应用层 Circuit Breaker 与平台限额双重防护
- Compatibility Gate：MDN Baseline、npm engines / os / cpu、Python Requires-Python
- CS Core / Mental Model Gate：算法复杂度、数据结构、性能、并发、网络、缓存、安全、权限、跨模块 Bug、架构取舍
- AI-XP Feedback Gate：Extreme Programming 短反馈循环、Human-AI Pair Programming、TDD Red / Green / Refactor
- Documentation Gate：Diataxis、Google Developer Documentation Style Guide、按需沉淀不建空壳
- Review Load Budget Gate：review 预算、必看文件、关键调用链、二次 review 条件
- Requirement Discovery / Scope Triage Gate：Core Path、Product Foundation、UX Enhancement、Future Monetization、Nice-to-have、Parking Lot
- Git Management Gate：trunk-based workflow、Conventional Commits、PR review、squash merge、revert rollback、AI 协作边界
- Productization Boundary Gate：用户身份、数据归属、使用记录、权益额度、AI/API 成本控制、BYOK、手动 Pro
- System Skeleton Gate：多角色/后台/权限/数据归属/异常处理（个人单机小工具默认豁免）
- Verification Gate：Exempt / Light / Targeted / Full 四级验证预算与 Bad Path 测试
- Production Readiness Gate：生产就绪清单、上线前 5 道必过关卡、Observability、Backup、Rollback、Owner
- Release / Rollback Gate：Google SRE Release Engineering、Twelve-Factor Build / Release / Run、DORA metrics

## 系统兼容性限制

当前脚本按照 macOS + zsh 环境编写（`#!/bin/zsh`），内部文件操作已统一使用 `/bin/cp`、`/bin/mv`、`/bin/rm`、`/bin/mkdir` 绝对路径以兼容本机 WorkBuddy shim 环境，且模板目录通过 `${0:A:h:h}/templates` 动态解析，支持仓库目录任意移动。

## 其他限制

- 当前脚本只负责初始化核心协议文件，不会预生成空白的 `prompts/*.md` 或空白的 `docs/project-map.md` 等空壳文件。
- 如果目标项目里已经存在协议入口文件，脚本会升级为最新版模板，保留 `<!-- ai-development:local ... -->` 本地补充块，并将旧文件备份至 `.ai-development-backups/`。
- 如果目标项目里已经存在 `PROJECT.md` 或 `docs/git-workflow.md`，脚本会保留原内容，并更新 `ai-development` 标记块中的协议内容。
- 如果目标项目里已经存在 `.gemini/settings.json`，脚本会自动将 `AGENTS.md` 合入 `context.fileName`。
- 这个工具只创建通用 AI 协议文件，不会自动配置第三方工具账号、API Key、MCP 服务或插件权限。
