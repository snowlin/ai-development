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

if [ ! -f "$TEMPLATE_DIR/AGENTS.md" ]; then
  echo "错误：缺少 AGENTS.md 模板"
  echo "$TEMPLATE_DIR/AGENTS.md"
  exit 1
fi

mkdir -p "$PROJECT_DIR/docs"

copy_if_missing() {
  SOURCE="$1"
  TARGET="$2"

  if [ -e "$TARGET" ]; then
    echo "跳过已有文件：$TARGET"
  else
    cp "$SOURCE" "$TARGET"
    echo "已创建：$TARGET"
  fi
}

copy_if_missing \
  "$TEMPLATE_DIR/AGENTS.md" \
  "$PROJECT_DIR/AGENTS.md"

copy_if_missing \
  "$TEMPLATE_DIR/CLAUDE.md" \
  "$PROJECT_DIR/CLAUDE.md"

copy_if_missing \
  "$TEMPLATE_DIR/GEMINI.md" \
  "$PROJECT_DIR/GEMINI.md"

create_doc_if_missing() {
  TARGET="$1"
  TITLE="$2"
  DESCRIPTION="$3"

  if [ -e "$TARGET" ]; then
    echo "跳过已有文件：$TARGET"
  else
    cat > "$TARGET" <<EOF
# $TITLE

$DESCRIPTION

待 AI 阅读项目后补充。
EOF

    echo "已创建：$TARGET"
  fi
}

create_doc_if_missing \
  "$PROJECT_DIR/docs/project-map.md" \
  "项目地图" \
  "记录项目入口、目录职责、核心模块和重要文件。"

create_doc_if_missing \
  "$PROJECT_DIR/docs/architecture.md" \
  "架构说明" \
  "记录技术栈、项目分层、状态管理、接口层和架构边界。"

create_doc_if_missing \
  "$PROJECT_DIR/docs/data-flow.md" \
  "数据流" \
  "记录核心功能从用户操作到最终页面反馈的数据流。"

create_doc_if_missing \
  "$PROJECT_DIR/docs/decision-log.md" \
  "技术决策记录" \
  "记录重要技术选择、原因、替代方案和影响。"

create_doc_if_missing \
  "$PROJECT_DIR/docs/learning-notes.md" \
  "学习记录" \
  "记录项目拥有者需要掌握的知识、文件入口和代码理解结论。"

echo ""
echo "AI 开发协议初始化完成。"
echo ""
echo "已支持："
echo "- Codex：AGENTS.md"
echo "- OpenCode：AGENTS.md"
echo "- Claude Code：CLAUDE.md"
echo "- Gemini CLI：GEMINI.md"
echo "- Antigravity：手动要求读取 AGENTS.md"
echo ""
echo "下一步："
echo "1. 打开项目中的 AGENTS.md"
echo "2. 添加项目专属规则"
echo "3. 让 AI 执行第一次项目认知扫描"
echo ""