# Gemini CLI 项目说明

开始任何开发任务之前，请先读取项目根目录的：

- `AGENTS.md`
- `PROJECT.md`

并根据任务读取：

- `docs/project-map.md`
- `docs/architecture.md`
- `docs/data-flow.md`
- `docs/decision-log.md`
- `docs/learning-notes.md`

## 项目规则

1. 将 `AGENTS.md` 作为主要开发协议。
2. 将 `PROJECT.md` 作为产品规划、需求说明和 IPSI-G Gate 状态的来源。
3. 修改代码之前，先完成 IPSI-G 检查、项目定位和方案设计。
4. 如果产品定义、系统数据流或验收标准不清楚，先输出分析，不要写代码。
5. 每次只完成一个最小、可验证闭环。
6. 不进行与当前任务无关的重构。
7. 修改完成后，解释入口、数据流、文件职责和验证方式。
8. 如果没有执行测试，必须明确说明。
