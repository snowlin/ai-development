#!/bin/zsh

set -e

PROJECT_DIR="${1:-$(pwd)}"
TEMPLATE_DIR="/Users/lingxr/Documents/myproduct/ai-development/templates"

echo ""
echo "初始化 AI 开发协议"
echo "项目目录：$PROJECT_DIR"
echo ""

if [ ! -d "$PROJECT_DIR" ]; then
  echo "错误：项目目录不存在"
  echo "$PROJECT_DIR"
  exit 1
fi

PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd -P)"

if [ "$PROJECT_DIR" = "/" ]; then
  echo "错误：不能把系统根目录作为项目目录"
  exit 1
fi

if [ -n "$HOME" ] && [ -d "$HOME" ]; then
  HOME_DIR="$(cd "$HOME" && pwd -P)"
  if [ "$PROJECT_DIR" = "$HOME_DIR" ]; then
    echo "错误：不能把用户 HOME 目录作为项目目录"
    echo "$PROJECT_DIR"
    echo "请进入具体项目目录后再执行，例如：ai-init ."
    exit 1
  fi
fi

case "$PROJECT_DIR" in
  /Applications|/Library|/System|/Users|/bin|/etc|/sbin|/usr|/var|/private|/tmp)
    echo "错误：不能把系统级目录作为项目目录"
    echo "$PROJECT_DIR"
    echo "请指定具体项目目录。"
    exit 1
    ;;
esac

if [ ! -w "$PROJECT_DIR" ]; then
  echo "错误：项目目录不可写"
  echo "$PROJECT_DIR"
  exit 1
fi

for REQUIRED_TEMPLATE in AGENTS.md CLAUDE.md GEMINI.md gates.md git-workflow.md .gemini/settings.json; do
  if [ ! -f "$TEMPLATE_DIR/$REQUIRED_TEMPLATE" ]; then
    echo "错误：缺少模板文件"
    echo "$TEMPLATE_DIR/$REQUIRED_TEMPLATE"
    exit 1
  fi
done

mkdir -p "$PROJECT_DIR/docs" "$PROJECT_DIR/prompts" "$PROJECT_DIR/.gemini"

BACKUP_DIR="$PROJECT_DIR/.ai-development-backups"

merge_from_file() {
  local SOURCE="$1"
  local TARGET="$2"
  local LABEL="$3"
  local START_MARKER="<!-- ai-development:start $LABEL -->"
  local END_MARKER="<!-- ai-development:end $LABEL -->"
  local TMP_FILE

  if [ ! -e "$TARGET" ]; then
    cp "$SOURCE" "$TARGET"
    echo "已创建：$TARGET"
  elif cmp -s "$SOURCE" "$TARGET"; then
    echo "已有文件已是最新：$TARGET"
  else
    TMP_FILE="$(mktemp "$TARGET.tmp.XXXXXX")"

    if ! {
      awk \
        -v start="$START_MARKER" \
        -v end="$END_MARKER" \
        'index($0, start) { skipping = 1; next } index($0, end) { skipping = 0; next } !skipping { print }' \
        "$TARGET"

      echo ""
      echo "$START_MARKER"
      cat "$SOURCE"
      echo "$END_MARKER"
    } > "$TMP_FILE"; then
      rm -f "$TMP_FILE"
      echo "错误：整合文件失败"
      echo "$TARGET"
      return 1
    fi

    mv "$TMP_FILE" "$TARGET"

    echo "已整合已有文件：$TARGET"
  fi
}

merge_generated_file() {
  local TARGET="$1"
  local LABEL="$2"
  local TMP_SOURCE

  TMP_SOURCE="$(mktemp)"

  cat > "$TMP_SOURCE"
  merge_from_file "$TMP_SOURCE" "$TARGET" "$LABEL"
  rm -f "$TMP_SOURCE"
}

upgrade_protocol_file() {
  local SOURCE="$1"
  local TARGET="$2"
  local LABEL="$3"
  local LOCAL_START="<!-- ai-development:local start $LABEL -->"
  local LOCAL_END="<!-- ai-development:local end $LABEL -->"
  local TMP_FILE
  local LOCAL_FILE
  local BACKUP_FILE
  local BACKUP_BASENAME
  local BACKUP_SUFFIX

  if [ ! -e "$TARGET" ]; then
    cp "$SOURCE" "$TARGET"
    echo "已创建：$TARGET"
  elif cmp -s "$SOURCE" "$TARGET"; then
    echo "协议文件已是最新：$TARGET"
  else
    TMP_FILE="$(mktemp "$TARGET.tmp.XXXXXX")"
    LOCAL_FILE="$(mktemp)"

    awk \
      -v start="$LOCAL_START" \
      -v end="$LOCAL_END" \
      'index($0, start) { capture = 1; next } index($0, end) { capture = 0; next } capture { print }' \
      "$TARGET" > "$LOCAL_FILE"

    cp "$SOURCE" "$TMP_FILE"

    if [ -s "$LOCAL_FILE" ]; then
      {
        echo ""
        echo "## Local Project Overrides"
        echo ""
        echo "$LOCAL_START"
        cat "$LOCAL_FILE"
        echo "$LOCAL_END"
      } >> "$TMP_FILE"
    fi

    if cmp -s "$TMP_FILE" "$TARGET"; then
      rm -f "$TMP_FILE" "$LOCAL_FILE"
      echo "协议文件内容未变化：$TARGET"
      return 0
    fi

    mkdir -p "$BACKUP_DIR"
    BACKUP_BASENAME="${TARGET:t}.ai-development-backup.$(date +%Y%m%d%H%M%S)"
    BACKUP_FILE="$BACKUP_DIR/$BACKUP_BASENAME"
    BACKUP_SUFFIX=1
    while [ -e "$BACKUP_FILE" ]; do
      BACKUP_FILE="$BACKUP_DIR/$BACKUP_BASENAME.$BACKUP_SUFFIX"
      BACKUP_SUFFIX=$((BACKUP_SUFFIX + 1))
    done

    cp "$TARGET" "$BACKUP_FILE"
    mv "$TMP_FILE" "$TARGET"
    rm -f "$LOCAL_FILE"

    echo "已升级协议文件：$TARGET"
    echo "旧版本备份：$BACKUP_FILE"
  fi
}

merge_gemini_settings() {
  local SOURCE="$1"
  local TARGET="$2"
  local TMP_FILE

  if [ ! -e "$TARGET" ]; then
    cp "$SOURCE" "$TARGET"
    echo "已创建：$TARGET"
    return 0
  fi

  if ! command -v ruby >/dev/null 2>&1; then
    cp "$SOURCE" "$TARGET.ai-development.json"
    echo "已有 Gemini 配置，当前环境缺少 ruby，已生成参考文件：$TARGET.ai-development.json"
    return 0
  fi

  TMP_FILE="$(mktemp "$TARGET.tmp.XXXXXX")"

  if ruby -rjson - "$TARGET" "$TMP_FILE" <<'RUBY'
target = ARGV[0]
tmp = ARGV[1]

data = {}
if File.exist?(target) && File.size?(target)
  data = JSON.parse(File.read(target))
end

unless data.is_a?(Hash)
  abort "settings root must be a JSON object"
end

context = data["context"]
context = {} unless context.is_a?(Hash)

file_name = context["fileName"]
files =
  case file_name
  when Array
    file_name
  when String
    [file_name]
  when nil
    []
  else
    abort "context.fileName must be a string or array"
  end

context["fileName"] = ["AGENTS.md"] + files.reject { |item| item == "AGENTS.md" }
data["context"] = context

File.write(tmp, JSON.pretty_generate(data) + "\n")
RUBY
  then
    if cmp -s "$TMP_FILE" "$TARGET"; then
      rm -f "$TMP_FILE"
      echo "已有 Gemini 配置已是最新：$TARGET"
    else
      mv "$TMP_FILE" "$TARGET"
      echo "已整合 Gemini 配置：$TARGET"
    fi
  else
    rm -f "$TMP_FILE"
    cp "$SOURCE" "$TARGET.ai-development.json"
    echo "警告：已有 Gemini 配置不是可自动合并的 JSON"
    echo "已生成参考文件：$TARGET.ai-development.json"
  fi
}

upgrade_protocol_file \
  "$TEMPLATE_DIR/AGENTS.md" \
  "$PROJECT_DIR/AGENTS.md" \
  "AGENTS.md"

upgrade_protocol_file \
  "$TEMPLATE_DIR/CLAUDE.md" \
  "$PROJECT_DIR/CLAUDE.md" \
  "CLAUDE.md"

upgrade_protocol_file \
  "$TEMPLATE_DIR/GEMINI.md" \
  "$PROJECT_DIR/GEMINI.md" \
  "GEMINI.md"

merge_gemini_settings \
  "$TEMPLATE_DIR/.gemini/settings.json" \
  "$PROJECT_DIR/.gemini/settings.json"

upgrade_protocol_file \
  "$TEMPLATE_DIR/gates.md" \
  "$PROJECT_DIR/docs/gates.md" \
  "docs/gates.md"

merge_from_file \
  "$TEMPLATE_DIR/git-workflow.md" \
  "$PROJECT_DIR/docs/git-workflow.md" \
  "docs/git-workflow.md"

merge_project_doc() {
  TARGET="$1"
  merge_generated_file "$TARGET" "PROJECT.md" <<EOF
# PROJECT

用于记录产品规划、需求说明、系统边界和需求变化。

本文件是 IPSI-G 的产品承载文档：先把想法变成产品，把产品变成系统，通过闸门后，才允许 AI 写代码。

## Idea

### 一句话想法

待补充。

### 价值判断

待补充。

## Product

### 产品定位

待补充。

### 目标用户

待补充。

### 用户动作

待补充。

### 不做什么

待补充。

### MVP 边界

待补充。

### Never Fake 清单

- 待补充。

## System

### 核心对象

待补充。

### 数据来源

待补充。

### AI / 规则 / 人工边界

| 角色 | 负责什么 | 不负责什么 |
| --- | --- | --- |
| AI | 待补充 | 待补充 |
| 规则 | 待补充 | 待补充 |
| 人工 | 待补充 | 待补充 |

### 状态流转

待补充。

### 失败处理

待补充。

### 数据流

待补充。

## System Skeleton

### 是否需要系统骨架检查

待补充。

### 用户角色

| 角色 | 核心动作 | 是否本轮支持 |
| --- | --- | --- |
| 游客 | 待补充 | 待补充 |
| 注册用户 | 待补充 | 待补充 |
| 付费用户 | 待补充 | 待补充 |
| 管理员 | 待补充 | 待补充 |
| 运营 / 审核员 | 待补充 | 待补充 |

### 后台管理

| 管理对象 | 最小后台能力 | 是否本轮实现 | 暂不实现依据 |
| --- | --- | --- | --- |
| 用户 | 列表 / 详情 / 禁用 / 权限调整 | 待补充 | 待补充 |
| 内容 / 数据 | 列表 / 详情 / 编辑 / 删除 / 审核 | 待补充 | 待补充 |
| 订单 / 权益 / 额度 | 查看 / 调整 / 退款 / 超额处理 | 待补充 | 待补充 |
| 配置 / 日志 | 配置开关 / 操作日志 / 错误追踪 | 待补充 | 待补充 |

### 数据归属

| 数据对象 | 归属字段 | 归属说明 |
| --- | --- | --- |
| 待补充 | owner_id / user_id / team_id / 默认 owner / 待补充 | 待补充 |

### 权限边界

| 动作 | 谁可以做 | 谁不可以做 | 验证方式 |
| --- | --- | --- | --- |
| 查看 | 待补充 | 待补充 | 待补充 |
| 创建 | 待补充 | 待补充 | 待补充 |
| 修改 | 待补充 | 待补充 | 待补充 |
| 删除 | 待补充 | 待补充 | 待补充 |
| 审核 / 发布 | 待补充 | 待补充 | 待补充 |
| 导出 | 待补充 | 待补充 | 待补充 |

### 状态流转

| 对象 | 状态 | 触发动作 | 操作者 |
| --- | --- | --- | --- |
| 待补充 | 草稿 / 已提交 / 处理中 / 成功 / 失败 / 已发布 / 已归档 / 待补充 | 待补充 | 待补充 |

### 异常处理

| 异常 | 用户看到什么 | 后台如何处理 | 是否需要日志 |
| --- | --- | --- | --- |
| 失败 | 待补充 | 待补充 | 待补充 |
| 违规 | 待补充 | 待补充 | 待补充 |
| 重复 | 待补充 | 待补充 | 待补充 |
| 超额 | 待补充 | 待补充 | 待补充 |
| 误删 / 投诉 / 退款 | 待补充 | 待补充 | 待补充 |

### MVP 暂不实现

| 暂不实现项 | 原因 | 最小预留 | 未来触发条件 |
| --- | --- | --- | --- |
| 用户体系 | 待补充 | current_user / owner_id / user_id / 待补充 | 待补充 |
| 后台管理 | 待补充 | 管理入口 / 操作日志 / 配置表 / 待补充 | 待补充 |
| 权限细分 | 待补充 | role / permission check / 待补充 | 待补充 |

## Data

### 是否涉及数据设计

待补充。

### 数据来源

待补充。

### 数据所有权

待补充。

### 核心字段和语义

| 字段 | 类型 | 含义 | 是否必填 | 约束 |
| --- | --- | --- | --- | --- |
| 待补充 | 待补充 | 待补充 | 待补充 | 待补充 |

### 状态流转规则

待补充。

### 数据质量规则

| 维度 | 规则 | 验证方式 |
| --- | --- | --- |
| 准确性 | 待补充 | 待补充 |
| 完整性 | 待补充 | 待补充 |
| 一致性 | 待补充 | 待补充 |
| 及时性 | 待补充 | 待补充 |
| 唯一性 | 待补充 | 待补充 |
| 有效性 | 待补充 | 待补充 |

### 数据生命周期

待补充。

### 数据迁移和回滚

待补充。

### 异常数据处理

待补充。

### Data Never Fake 清单

- 待补充。

## UI/UX

### 是否涉及用户界面

待补充。

### UI Draft First

| 项目 | 内容 |
| --- | --- |
| 是否需要先出 UI 草图 | 待补充 |
| 前置 Gate 状态 | Idea / Product / System / 待补充 |
| MVP 闭环 | 待补充 |
| 核心用户动作 | 待补充 |
| 系统数据流是否已确认 | 待补充 |
| 草图形式 | 线框图 / 低保真 UI 图 / ASCII 布局 / Mermaid 流程 / 可预览原型 / 待补充 |
| 草图位置 | 待补充 |
| 用户确认状态 | 未确认 |
| 跳过原因 | 待补充 |

### 目标用户

待补充。

### 核心用户动作

待补充。

### 页面区域

待补充。

### 主要组件

待补充。

### 信息层级

待补充。

### 交互流程

待补充。

### 页面状态

| 状态 | 呈现方式 |
| --- | --- |
| 加载 | 待补充 |
| 空状态 | 待补充 |
| 错误 | 待补充 |
| 成功 | 待补充 |
| 禁用 | 待补充 |
| 编辑 | 待补充 |
| 确认 / 撤销 | 待补充 |

### 参考设计系统

待补充。

### 中国用户适配

待补充。

### 颜色策略

待补充。

### 组件来源

待补充。

### UI Never Fake 清单

- 待补充。

## Security

### 是否涉及安全边界

待补充。

### 信任边界

待补充。

### 认证 / 授权 / 角色

待补充。

### 敏感数据

待补充。

### 用户输入与输出处理

待补充。

### 外部 API / Webhook / 依赖

待补充。

### AI / Agent / RAG 安全边界

待补充。

### 审计与告警

待补充。

### 参考安全标准

| 标准 | 是否适用 | 说明 |
| --- | --- | --- |
| OWASP Top 10:2025 | 待补充 | Web 应用安全风险 |
| OWASP ASVS 5.0.0 | 待补充 | 应用安全验证 |
| OWASP API Security Top 10 2023 | 待补充 | API 安全风险 |
| OWASP Top 10 for LLM Applications 2025 | 待补充 | AI / LLM 应用安全风险 |
| NIST SSDF SP 800-218 | 待补充 | 安全开发流程 |

### 安全风险清单

| 风险 | 影响 | 防护方式 | 验证方式 |
| --- | --- | --- | --- |
| 待补充 | 待补充 | 待补充 | 待补充 |

### Security Never Fake 清单

- 不伪造认证状态。
- 不伪造授权结果。
- 不伪造支付、审核、风控、加密、审计或安全扫描结果。
- 不在代码、日志、测试快照或文档中暴露真实密钥和真实个人信息。

## Performance

### 是否涉及性能敏感路径

待补充。

### 受影响用户路径

待补充。

### 核心性能指标

待补充。

### 性能预算

| 指标 | 预算 | 说明 |
| --- | --- | --- |
| LCP | <= 2.5s | Web 前端首屏加载 |
| INP | <= 200ms | Web 前端交互响应 |
| CLS | <= 0.1 | Web 前端视觉稳定性 |
| 接口 P95 | 待补充 | 后端响应时间 |
| 错误率 | 待补充 | 服务可靠性 |

### 前端性能风险

待补充。

### 后端性能风险

待补充。

### AI / 模型调用性能风险

待补充。

### 可观测性

待补充。

### 性能验证方式

待补充。

## AI Evaluation

### 是否涉及 AI 行为

待补充。

### AI 任务定义

待补充。

### 输入样例

| 类型 | 样例 | 期望处理 |
| --- | --- | --- |
| 正常样例 1 | 待补充 | 待补充 |
| 正常样例 2 | 待补充 | 待补充 |
| 正常样例 3 | 待补充 | 待补充 |
| 边界样例 | 待补充 | 待补充 |
| 失败 / 恶意样例 | 待补充 | 待补充 |

### 期望输出标准

待补充。

### 评价方式

待补充。

### 通过标准

待补充。

### 失败处理

待补充。

### 人工审核边界

待补充。

### Prompt / 模型 / 参数 / 数据集版本

待补充。

## Human Judgment

### 是否涉及高风险判断

待补充。

### Checkable Evidence

| 事实 | 来源 | 验证方式 |
| --- | --- | --- |
| 待补充 | 待补充 | 待补充 |

### AI Assumption

| 推测 | 为什么是推测 | 如何验证 |
| --- | --- | --- |
| 待补充 | 待补充 | 待补充 |

### Human Judgment

| 需要用户判断的部分 | 取舍点 | 判断依据 |
| --- | --- | --- |
| 待补充 | 待补充 | 待补充 |

### Counterexample

待补充。

### Wrong-if Cost

待补充。

### 下一步验证方式

待补充。

## Context Management

### 是否涉及多轮上下文或阶段切换

待补充。

### 当前目标

待补充。

### 已确认决策

| 决策 | 证据来源 | 是否仍有效 |
| --- | --- | --- |
| 待补充 | 待补充 | 待补充 |

### 活跃 Gate

待补充。

### 可信上下文

待补充。

### 过期或冲突上下文

待补充。

### 建议动作

| 动作 | 是否需要 | 原因 |
| --- | --- | --- |
| 压缩上下文 | 待补充 | 待补充 |
| 重开新任务 | 待补充 | 待补充 |
| 重新确认需求 | 待补充 | 待补充 |

### 下一闭环

待补充。

## Trust Calibration

### 是否涉及 AI 代理高风险任务

待补充。

### AI 权限级别

| 项目 | 内容 |
| --- | --- |
| 风险等级 | Light / Targeted / Full / 待补充 |
| AI 权限级别 | Suggest / Draft / Modify / Execute / 待补充 |
| AI 可直接做 | 待补充 |
| 必须用户确认 | 待补充 |
| 禁止自动执行 | 待补充 |
| 信任依据 | 待补充 |

## Dependency

### 是否涉及依赖变化

待补充。

### 依赖清单

| 依赖 | 版本 | 用途 | 替代方案 | 维护状态 | 安全 / 许可证风险 |
| --- | --- | --- | --- | --- | --- |
| 待补充 | 待补充 | 待补充 | 待补充 | 待补充 | 待补充 |

### 版本锁定策略

待补充。

### 体积 / 安装 / 冷启动影响

待补充。

### 移除成本

待补充。

## Cost

### 是否涉及持续费用

待补充。

### 成本来源

待补充。

### 计费单位

待补充。

### 调用频率和预算

| 资源 | 频率 | 单次成本 | 月度上限 | 控制方式 |
| --- | --- | --- | --- | --- |
| 待补充 | 待补充 | 待补充 | 待补充 | 待补充 |

### 成本可见性

待补充。

### 价值判断

待补充。

## Compatibility

### 目标环境

待补充。

### 最低版本

| 类型 | 最低版本 | 说明 |
| --- | --- | --- |
| macOS | 待补充 | 待补充 |
| Linux | 待补充 | 待补充 |
| Windows / WSL | 待补充 | 待补充 |
| Node.js | 待补充 | 待补充 |
| Python | 待补充 | 待补充 |
| 浏览器 | 待补充 | 待补充 |

### 路径 / Shell / 权限差异

待补充。

### 编码 / 换行 / 时区差异

待补充。

### 不支持环境的提示

待补充。

## CS Core / Mental Model

### 是否涉及计算机科学核心概念

待补充。

### 核心概念

| 概念 | 为什么相关 | 需要理解到什么程度 |
| --- | --- | --- |
| 待补充 | 待补充 | 待补充 |

### 复杂度或资源影响

待补充。

### 规模增长风险

待补充。

### 网络 / 并发 / 缓存 / 权限 / 安全

待补充。

### 人类必须理解

- 待补充。

### 记录到 learning-notes

待补充。

## Implementation

### 第一阶段 MVP 闭环

待补充。

### 修改范围

待补充。

### 验证方式

待补充。

### TDD 策略

| 项目 | 内容 |
| --- | --- |
| 是否需要 TDD | 待补充 |
| 失败测试描述 | 待补充 |
| Red 验证命令 | 待补充 |
| Green 验证命令 | 待补充 |
| 跳过 TDD 的原因 | 待补充 |

### AI-XP 短反馈循环

| 项目 | 内容 |
| --- | --- |
| 当前闭环 | 待补充 |
| 验证命令 | 待补充 |
| 是否进行小重构 | 待补充 |
| 小重构目标 | 待补充 |
| 二次验证结果 | 待补充 |
| 本次学习点 | 待补充 |
| 黑盒风险 | 待补充 |

### 回滚方式

待补充。

### 完成标准

待补充。

## Documentation

### 是否需要同步文档

待补充。

### 需要更新的文档

| 文档 | 是否需要更新 | 原因 |
| --- | --- | --- |
| PROJECT.md | 待补充 | 待补充 |
| docs/project-map.md | 待补充 | 待补充 |
| docs/architecture.md | 待补充 | 待补充 |
| docs/data-flow.md | 待补充 | 待补充 |
| docs/decision-log.md | 待补充 | 待补充 |
| docs/learning-notes.md | 待补充 | 待补充 |
| docs/git-workflow.md | 待补充 | 涉及分支、提交、PR、review、合并或回滚时更新 |
| README.md | 待补充 | 待补充 |

### 文档事实来源

待补充。

## Review Load Budget

### 是否需要 review AI 生成内容

待补充。

### Review 预算

| 项目 | 内容 |
| --- | --- |
| 预算级别 | Light / Targeted / Full / 待补充 |
| 必须看的文件 | 待补充 |
| 只看摘要的文件 | 待补充 |
| 关键调用链 | 待补充 |
| 风险点 | 待补充 |
| 是否需要二次 review | 待补充 |

## Requirement Discovery / Scope Triage

### 是否发现新增需求或范围扩大

待补充。

### 当前主路径

待补充。

### 本轮闭环

待补充。

### 新发现需求分流

| 需求 | 分类 | 是否阻塞主路径 | 处理决定 | 未来触发条件 |
| --- | --- | --- | --- | --- |
| 待补充 | Core Path / Product Foundation / UX Enhancement / Future Monetization / Nice-to-have | Yes / No / 待补充 | Do Now / Define Only / Parking Lot / Reject / 待补充 | 待补充 |

### Parking Lot 位置

待补充。

## Productization Boundary

### 是否从个人工具进入产品化

待补充。

### 当前形态

Personal Tool / Internal Tool / Beta Product / Paid Product / 待补充

### 产品化边界检查

| 项目 | 状态 | 说明 |
| --- | --- | --- |
| 目标使用者 | 待补充 | 只有自己 / 少量熟人 / 真实用户 / 团队 / 客户 |
| 数据归属 | 待补充 | 是否需要 owner_id 或 user_id |
| AI/API 成本行为 | 待补充 | 是否需要 usage_events |
| 权益和额度 | 待补充 | 是否需要 plan、quota 或 feature entitlement |
| BYOK / 支付 | 待补充 | 是否需要 BYOK、手动 Pro 或支付 |
| 暂不实现的依据 | 待补充 | 为什么现在可以不做用户体系 |
| 未来触发条件 | 待补充 | 什么时候必须补齐 |
| 最小预留策略 | 待补充 | current_user、owner_id/user_id、usage_events、plan/quota |

## Verification

### 验证预算

| 项目 | 内容 |
| --- | --- |
| 预算级别 | Light / Targeted / Full / 待补充 |
| 选择原因 | 待补充 |
| 风险匹配说明 | 待补充 |

### 验证命令

| 检查 | 命令 | 结果 |
| --- | --- | --- |
| Lint | 待补充 | 待补充 |
| Type Check | 待补充 | 待补充 |
| Unit Test | 待补充 | 待补充 |
| Integration / E2E Test | 待补充 | 待补充 |
| Build | 待补充 | 待补充 |
| Manual Verification | 待补充 | 待补充 |

### 未执行检查

待补充。

### 剩余风险

待补充。

## Production Readiness

### 是否准备进入真实使用或生产

待补充。

### 当前阶段

Prototype / Internal Tool / Beta / Production / 待补充

### 生产检查

| 项目 | 状态 | 说明 |
| --- | --- | --- |
| 是否涉及真实用户 | 待补充 | 待补充 |
| 是否涉及敏感数据 | 待补充 | 待补充 |
| 上线 5 道必过关卡 (DB/重试/幂等/Key隔离/坏路径) | 未核对 | 包含：DB变更优先、重试错误鉴别、计费API幂等断点续传、API Key隔离与预算硬上限、Bad Path坏路径测试 (见 docs/gates.md#27) |
| 生产缺口 | 待补充 | 待补充 |
| 监控和日志 | 待补充 | 待补充 |
| 回滚方式 | 待补充 | 待补充 |
| 维护 owner | 待补充 | 待补充 |
| 是否可进入生产 | 待补充 | 待补充 |

## Release / Rollback

### 是否涉及发布

待补充。

### 发布范围

待补充。

### 环境差异

待补充。

### 发布步骤

待补充。

### 回滚方案

待补充。

### 不可逆变化

待补充。

### 发布后观察指标

待补充。

### 停止条件

待补充。

## IPSI-G Gate 状态

| Gate | 是否通过 | 证据 |
| --- | --- | --- |
| Idea Gate | 未确认 | 待补充 |
| Product Gate | 未确认 | 待补充 |
| System Gate | 未确认 | 待补充 |
| Implementation Gate | 未确认 | 待补充 |

## Gate 激活清单

| Gate | 状态 | 原因 |
| --- | --- | --- |
| IPSI-G | 激活 | 默认激活，用于防止产品和系统未定义时过早实现 |
| System Skeleton | 未确认 | 新产品、新功能或新页面进入实现前检查用户体系、后台管理、权限、状态和异常处理 |
| UI/UX | 未确认 | 待补充 |
| Data | 未确认 | 待补充 |
| Security | 未确认 | 待补充 |
| Performance | 未确认 | 待补充 |
| AI Evaluation | 未确认 | 待补充 |
| Human Judgment | 未确认 | 待补充 |
| Context Management | 未确认 | 待补充 |
| Trust Calibration | 未确认 | 待补充 |
| Dependency | 未确认 | 待补充 |
| Cost | 未确认 | 待补充 |
| Compatibility | 未确认 | 待补充 |
| CS Core / Mental Model | 未确认 | 待补充 |
| TDD | 未确认 | 待补充 |
| AI-XP Feedback | 未确认 | 待补充 |
| Documentation | 未确认 | 待补充 |
| Review Load Budget | 未确认 | 待补充 |
| Requirement Discovery / Scope Triage | 未确认 | 待补充 |
| Git Management | 未确认 | 待补充 |
| Productization Boundary | 未确认 | 待补充 |
| Verification | 激活 | 默认激活，用于交付前验证 |
| Production Readiness | 未确认 | 待补充 |
| Release / Rollback | 未确认 | 待补充 |

## 扩展 Gate 状态

| Gate | 是否通过 | 证据 |
| --- | --- | --- |
| UI/UX Gate | 未确认 | 待补充 |
| Data Gate | 未确认 | 待补充 |
| Security Gate | 未确认 | 待补充 |
| Performance Gate | 未确认 | 待补充 |
| AI Evaluation Gate | 未确认 | 待补充 |
| Human Judgment Gate | 未确认 | 待补充 |
| Context Management Gate | 未确认 | 待补充 |
| Trust Calibration Gate | 未确认 | 待补充 |
| Dependency Gate | 未确认 | 待补充 |
| Cost Gate | 未确认 | 待补充 |
| Compatibility Gate | 未确认 | 待补充 |
| CS Core / Mental Model Gate | 未确认 | 待补充 |
| TDD Gate | 未确认 | 待补充 |
| AI-XP Feedback Gate | 未确认 | 待补充 |
| Documentation Gate | 未确认 | 待补充 |
| Review Load Budget Gate | 未确认 | 待补充 |
| Requirement Discovery / Scope Triage Gate | 未确认 | 待补充 |
| Git Management Gate | 未确认 | 待补充 |
| Productization Boundary Gate | 未确认 | 待补充 |
| System Skeleton Gate | 未确认 | 待补充 |
| Verification Gate | 未确认 | 待补充 |
| Production Readiness Gate | 未确认 | 待补充 |
| Release / Rollback Gate | 未确认 | 待补充 |

## 需求变化记录

| 日期 | 变化内容 | 原因 | 影响范围 |
| --- | --- | --- | --- |
| 待补充 | 待补充 | 待补充 | 待补充 |

EOF
}

merge_doc() {
  TARGET="$1"
  LABEL="$2"
  TITLE="$3"
  DESCRIPTION="$4"

  merge_generated_file "$TARGET" "$LABEL" <<EOF
# $TITLE

$DESCRIPTION

待 AI 阅读项目后补充。
EOF
}

merge_project_doc \
  "$PROJECT_DIR/PROJECT.md"

merge_doc \
  "$PROJECT_DIR/docs/project-map.md" \
  "docs/project-map.md" \
  "项目地图" \
  "记录项目入口、目录职责、核心模块和重要文件。"

merge_doc \
  "$PROJECT_DIR/docs/architecture.md" \
  "docs/architecture.md" \
  "架构说明" \
  "记录技术栈、项目分层、状态管理、接口层和架构边界。"

merge_doc \
  "$PROJECT_DIR/docs/data-flow.md" \
  "docs/data-flow.md" \
  "数据流" \
  "记录核心功能从用户操作到最终页面反馈的数据流。"

merge_doc \
  "$PROJECT_DIR/docs/decision-log.md" \
  "docs/decision-log.md" \
  "技术决策记录" \
  "记录重要技术选择、原因、替代方案和影响。"

merge_doc \
  "$PROJECT_DIR/docs/learning-notes.md" \
  "docs/learning-notes.md" \
  "学习记录" \
  "记录项目拥有者需要掌握的知识、文件入口和代码理解结论。"

merge_doc \
  "$PROJECT_DIR/prompts/github-review.md" \
  "prompts/github-review.md" \
  "GitHub Review Prompt" \
  "用于记录 GitHub PR 评审、评论处理和代码审查时的提示词。"

merge_doc \
  "$PROJECT_DIR/prompts/feature-design.md" \
  "prompts/feature-design.md" \
  "Feature Design Prompt" \
  "用于记录新功能设计、需求澄清和方案拆解时的提示词。"

merge_doc \
  "$PROJECT_DIR/prompts/bug-fix.md" \
  "prompts/bug-fix.md" \
  "Bug Fix Prompt" \
  "用于记录问题复现、根因分析和修复验证时的提示词。"

merge_doc \
  "$PROJECT_DIR/prompts/refactor.md" \
  "prompts/refactor.md" \
  "Refactor Prompt" \
  "用于记录重构目标、边界、风险和验证方式相关的提示词。"

echo ""
echo "AI 开发协议初始化完成。"
echo ""
echo "已支持："
echo "- Codex：AGENTS.md"
echo "- OpenCode：AGENTS.md"
echo "- Claude Code：CLAUDE.md"
echo "- Gemini CLI：.gemini/settings.json + GEMINI.md fallback"
echo "- Antigravity：优先读取 AGENTS.md，必要时参考 GEMINI.md fallback"
echo "- 详细 Gate：docs/gates.md"
echo "- Git 管理规范：docs/git-workflow.md"
echo "- Product Selection Gate：按需读取仓库模板中的 templates/product-selection.md"
echo "- Product Selection Trigger：跨工具触发规则见 templates/product-selection-trigger.md"
echo "- 协议备份目录：.ai-development-backups/（仅协议内容变化时生成）"
echo ""
echo "💡 开发者建议："
echo "1. 可根据需要补充 PROJECT.md（产品定义）或 AGENTS.md（项目专属规则）。"
echo "2. 现在可以直接向 AI 助手提出你的日常开发、重构或修 Bug 需求。"
echo ""
echo "🤖 AI 协作规范（AI 助手在后续开发中将自动遵守）："
echo "- 自动评估 Gate 闸门与验证方案 (TDD / Verification)"
echo "- 新产品、新功能或新页面进入实现前，先执行系统骨架检查 (System Skeleton)"
echo "- 涉及 UI 先画 UI 草图，高风险决策引导人工确认 (Human Judgment)"
echo "- 严格遵守 Git 规范与数据库资产保护规则 (Rule 3.18)"
echo ""
