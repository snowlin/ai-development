#!/bin/zsh

set -e

PROJECT_DIR="${1:-$(pwd)}"
SCRIPT_DIR="${0:A:h}"
TEMPLATE_DIR="${SCRIPT_DIR:h}/templates"

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

/bin/mkdir -p "$PROJECT_DIR/docs" "$PROJECT_DIR/.gemini"

BACKUP_DIR="$PROJECT_DIR/.ai-development-backups"

merge_from_file() {
  local SOURCE="$1"
  local TARGET="$2"
  local LABEL="$3"
  local START_MARKER="<!-- ai-development:start $LABEL -->"
  local END_MARKER="<!-- ai-development:end $LABEL -->"
  local TMP_FILE

  if [ ! -e "$TARGET" ]; then
    /bin/cp "$SOURCE" "$TARGET"
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
      /bin/rm -f "$TMP_FILE"
      echo "错误：整合文件失败"
      echo "$TARGET"
      return 1
    fi

    /bin/mv "$TMP_FILE" "$TARGET"

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
  /bin/rm -f "$TMP_SOURCE"
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
    /bin/cp "$SOURCE" "$TARGET"
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

    /bin/cp "$SOURCE" "$TMP_FILE"

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
      /bin/rm -f "$TMP_FILE" "$LOCAL_FILE"
      echo "协议文件内容未变化：$TARGET"
      return 0
    fi

    /bin/mkdir -p "$BACKUP_DIR"
    BACKUP_BASENAME="${TARGET:t}.ai-development-backup.$(date +%Y%m%d%H%M%S)"
    BACKUP_FILE="$BACKUP_DIR/$BACKUP_BASENAME"
    BACKUP_SUFFIX=1
    while [ -e "$BACKUP_FILE" ]; do
      BACKUP_FILE="$BACKUP_DIR/$BACKUP_BASENAME.$BACKUP_SUFFIX"
      BACKUP_SUFFIX=$((BACKUP_SUFFIX + 1))
    done

    /bin/cp "$TARGET" "$BACKUP_FILE"
    /bin/mv "$TMP_FILE" "$TARGET"
    /bin/rm -f "$LOCAL_FILE"

    echo "已升级协议文件：$TARGET"
    echo "旧版本备份：$BACKUP_FILE"
  fi
}

merge_gemini_settings() {
  local SOURCE="$1"
  local TARGET="$2"
  local TMP_FILE

  if [ ! -e "$TARGET" ]; then
    /bin/cp "$SOURCE" "$TARGET"
    echo "已创建：$TARGET"
    return 0
  fi

  if ! command -v ruby >/dev/null 2>&1; then
    /bin/cp "$SOURCE" "$TARGET.ai-development.json"
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
      /bin/rm -f "$TMP_FILE"
      echo "已有 Gemini 配置已是最新：$TARGET"
    else
      /bin/mv "$TMP_FILE" "$TARGET"
      echo "已整合 Gemini 配置：$TARGET"
    fi
  else
    /bin/rm -f "$TMP_FILE"
    /bin/cp "$SOURCE" "$TARGET.ai-development.json"
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
  merge_generated_file "$TARGET" "PROJECT.md" <<'EOF'
# PROJECT

本文件是项目的跨会话事实来源（记录产品定位、MVP 边界、核心数据归属、上线检查与关键决策变更）。
详细 Gate 检查表位于 `docs/gates.md`，按需触发读取，不在本文件重复维护静态空表。

## 1. Idea & Product（产品定位与边界）

- **一句话价值**：待补充
- **目标用户与触发场景**：待补充
- **核心用户动作**：待补充
- **MVP 第一阶段边界（只做什么）**：待补充
- **本阶段明确不做什么（Parking Lot）**：待补充
- **Never Fake 清单（严禁伪装的能力）**：待补充

## 2. System & Data（系统对象与数据流）

- **核心业务对象**：待补充
- **核心数据流（`输入 -> 处理 -> 输出`）**：待补充
- **AI / 规则 / 人工职责边界**：
  - **AI 负责**：待补充
  - **确定性规则负责**：待补充
  - **人工判断/审核负责**：待补充
- **关键状态流转与异常降级**：待补充

## 3. System Skeleton & Productization（系统骨架与产品化边界 · 按需填写）

> 注：个人单机工具、局部功能或纯演示原型可标注“当前豁免”，仅在涉及多用户、持久化数据归属或外部计费 API 时填写。

- **当前形态**：`Personal Tool` / `Internal Tool` / `Beta Product` / `Paid Product`
- **用户与管理角色**：待补充
- **数据归属策略（`owner_id` / `user_id`）**：待补充
- **AI/API 计费记录与配额控制（`usage_events` / `quota`）**：待补充
- **暂不实现项与未来补齐触发条件**：待补充

## 4. Production Readiness & 上线前 5 道必过关卡（进入真实用户/生产前核对）

| 必过关卡 | 状态 | 项目落地方案或豁免说明 |
| --- | --- | --- |
| 1. **DB 变更与代码部署分阶段对齐**（Expand 先迁移后发版；Contract 先下线旧代码再收缩） | 未核对 | 待补充 |
| 2. **重试配备精准错误鉴别器**（`429/408/5xx` 指数退避重试；`400/401/403/404/422` 及 Schema 错误立即熔断告警） | 未核对 | 待补充 |
| 3. **计费 API 真正幂等与断点续传**（外部传递 `Idempotency-Key` + 本地 `IN_FLIGHT` 中间态核验，防崩溃重扣） | 未核对 | 待补充 |
| 4. **Dev/Prod Key 隔离与双重预算熔断**（应用层自建调用/Token 熔断器 + 服务商后台 Hard/Soft Limit） | 未核对 | 待补充 |
| 5. **上线前 Bad Path 坏路径测试**（断网/DB 断连、第三方 5xx/429、并发重复触发、配额耗尽下优雅降级） | 未核对 | 待补充 |

## 5. 关键决策与需求变化记录

| 日期 | 决策 / 变化内容 | 原因与依据 | 影响范围 |
| --- | --- | --- | --- |
| 待补充 | 待补充 | 待补充 | 待补充 |
EOF
}

merge_project_doc \
  "$PROJECT_DIR/PROJECT.md"

echo ""
echo "AI 开发协议初始化完成。"
echo ""
echo "已支持："
echo "- Codex CLI：AGENTS.md"
echo "- Claude Code：CLAUDE.md"
echo "- WorkBuddy / CodeBuddy：AGENTS.md"
echo "- Gemini CLI / Antigravity：.gemini/settings.json + AGENTS.md（GEMINI.md 兜底）"
echo "- 详细 Gate 清单：docs/gates.md（按需读取）"
echo "- Git 管理规范：docs/git-workflow.md"
echo "- Product Selection Gate：按需读取 templates/product-selection.md"
echo "- 协议备份目录：.ai-development-backups/（仅协议内容变化时生成）"
echo ""
echo "💡 开发者建议："
echo "1. 按需补充 PROJECT.md 中的产品边界与核心数据流（无需填写未激活的 Gate 表格）。"
echo "2. 架构、数据流或决策沉淀文档仅在有真实内容时按需创建于 docs/，不再预生成空白占位文件。"
echo ""
