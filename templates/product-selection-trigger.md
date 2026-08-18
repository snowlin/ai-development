# Product Selection Trigger

这是一个跨 AI 工具使用的轻量常驻触发规则。它只负责识别场景，不包含完整 Product Selection 方法论。

当用户讨论以下内容时，触发 Product Selection Gate：

- “我想做一个……”
- “帮我做一个 SaaS / AI 产品……”
- “这个想法值不值得做？”
- “帮我设计 MVP……”
- “这个功能有没有商业价值？”
- “我想把这个工作流做成软件……”

触发后：

1. 暂停直接写代码或设计完整功能。
2. 告知用户正在进入 Product Selection Gate。
3. 读取 `product-selection.md` 完整方法论。
4. 区分事实、假设、未知和需要用户判断的部分。
5. 先输出最大未知和最便宜的决定性测试。
6. 未经用户确认，不把未经验证的假设转换成开发需求。

如果当前工具无法读取本地文件，请要求用户提供 `product-selection.md`，或使用已经上传的同名知识文件。
