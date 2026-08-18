# Product Selection 跨工具接入

`templates/product-selection.md` 是完整方法论的唯一事实来源，`templates/product-selection-trigger.md` 是跨工具复用的轻量触发规则。

不要把完整方法论复制到每个项目。根据 AI 工具的能力，把触发规则放入对应的全局 Instructions、Rules、Skill 或项目协议中；触发后再读取完整模板。

## 推荐接入方式

| 工具类型 | 接入触发规则 | 完整模板 |
| --- | --- | --- |
| 支持 Skill 的工具 | 安装为 Product Selection Skill | 由 Skill 引用或加载中央模板 |
| 支持全局 Rules 的工具 | 放入全局规则 | 配置模板路径或上传模板 |
| 只支持项目规则的工具 | 放入项目初始化模板 | 项目外讨论时手动提供或上传 |
| ChatGPT Custom GPT | 放入 Instructions | 上传为 Knowledge |
| 不支持本地文件的工具 | 粘贴触发规则 | 粘贴或上传完整模板 |

## 项目创建前

先让 AI 使用触发规则识别产品想法，再读取完整模板完成筛选。结果保存在独立想法记录中；确认继续后，才执行 `ai-init` 并把结论摘要写入 `PROJECT.md`。

## 维护规则

- 只维护一份完整方法论。
- 修改触发条件时同步更新各工具适配层。
- 工具适配层只包含触发和加载方式，不复制完整方法论。
