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

mkdir -p "$PROJECT_DIR/docs" "$PROJECT_DIR/prompts"

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

create_project_doc_if_missing() {
  TARGET="$1"

  if [ -e "$TARGET" ]; then
    echo "跳过已有文件：$TARGET"
  else
    cat > "$TARGET" <<EOF
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

## Implementation

### 第一阶段 MVP 闭环

待补充。

### 修改范围

待补充。

### 验证方式

待补充。

### 回滚方式

待补充。

### 完成标准

待补充。

## IPSI-G Gate 状态

| Gate | 是否通过 | 证据 |
| --- | --- | --- |
| Idea Gate | 未确认 | 待补充 |
| Product Gate | 未确认 | 待补充 |
| System Gate | 未确认 | 待补充 |
| Implementation Gate | 未确认 | 待补充 |

## 需求变化记录

| 日期 | 变化内容 | 原因 | 影响范围 |
| --- | --- | --- | --- |
| 待补充 | 待补充 | 待补充 | 待补充 |

EOF

    echo "已创建：$TARGET"
  fi
}

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

create_project_doc_if_missing \
  "$PROJECT_DIR/PROJECT.md"

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

create_doc_if_missing \
  "$PROJECT_DIR/prompts/github-review.md" \
  "GitHub Review Prompt" \
  "用于记录 GitHub PR 评审、评论处理和代码审查时的提示词。"

create_doc_if_missing \
  "$PROJECT_DIR/prompts/feature-design.md" \
  "Feature Design Prompt" \
  "用于记录新功能设计、需求澄清和方案拆解时的提示词。"

create_doc_if_missing \
  "$PROJECT_DIR/prompts/bug-fix.md" \
  "Bug Fix Prompt" \
  "用于记录问题复现、根因分析和修复验证时的提示词。"

create_doc_if_missing \
  "$PROJECT_DIR/prompts/refactor.md" \
  "Refactor Prompt" \
  "用于记录重构目标、边界、风险和验证方式相关的提示词。"

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
echo "1. 先补 PROJECT.md，完成 IPSI-G 的产品和系统定义"
echo "2. 再补 AGENTS.md，添加项目专属规则"
echo "3. 让 AI 读取 PROJECT.md、AGENTS.md 和 docs/"
echo "4. 先做 IPSI-G 分析，不要直接写代码"
echo ""
