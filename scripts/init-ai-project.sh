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

for REQUIRED_TEMPLATE in AGENTS.md CLAUDE.md GEMINI.md docs/gates.md .gemini/settings.json; do
  if [ ! -f "$TEMPLATE_DIR/$REQUIRED_TEMPLATE" ]; then
    echo "错误：缺少模板文件"
    echo "$TEMPLATE_DIR/$REQUIRED_TEMPLATE"
    exit 1
  fi
done

mkdir -p "$PROJECT_DIR/docs" "$PROJECT_DIR/prompts" "$PROJECT_DIR/.gemini"

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

    BACKUP_FILE="$TARGET.ai-development-backup.$(date +%Y%m%d%H%M%S)"
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
  "$TEMPLATE_DIR/docs/gates.md" \
  "$PROJECT_DIR/docs/gates.md" \
  "docs/gates.md"

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
| TDD | 未确认 | 待补充 |
| AI-XP Feedback | 未确认 | 待补充 |
| Documentation | 未确认 | 待补充 |
| Review Load Budget | 未确认 | 待补充 |
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
| TDD Gate | 未确认 | 待补充 |
| AI-XP Feedback Gate | 未确认 | 待补充 |
| Documentation Gate | 未确认 | 待补充 |
| Review Load Budget Gate | 未确认 | 待补充 |
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
echo ""
echo "下一步："
echo "1. 先补 PROJECT.md，完成 IPSI-G 的产品和系统定义"
echo "2. 再补 AGENTS.md，添加项目专属规则"
echo "3. 让 AI 读取 PROJECT.md 和 AGENTS.md"
echo "4. 先判断任务等级和 Gate 激活清单"
echo "5. 涉及 UI 时，先过 Idea / Product / System，再出 UI 草图"
echo "6. UI 草图确认后，再进入实现"
echo "7. 涉及高风险判断时，执行 Human Judgment Gate，区分事实、推测、反例和人的判断"
echo "8. 多轮对话、阶段切换或上下文混乱时，执行 Context Management Gate"
echo "9. 将决策、实现、验证或发布交给 AI 前，执行 Trust Calibration Gate"
echo "10. 涉及 UI、数据、安全、性能、AI、依赖、成本、兼容或 AI-XP 时，只读取 docs/gates.md 中对应 Gate"
echo "11. 进入实现前，说明 TDD 状态和验证方式"
echo "12. Review AI 生成 diff 前，选择 Light / Targeted / Full Review"
echo "13. 验证前，先选择 Light / Targeted / Full Verification"
echo "14. 原型进入真实用户、生产、团队协作或长期维护前，执行 Production Readiness Gate"
echo "15. 验证通过后，如需小重构，只做一次并再次验证"
echo "16. 交付前，完成文档、验证、发布和回滚检查"
echo ""
