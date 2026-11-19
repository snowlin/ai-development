#!/bin/zsh

set -e

CHECK_ONLY=0
if [ "${1:-}" = "--check" ]; then
  CHECK_ONLY=1
fi

SCRIPT_DIR="${0:A:h}"
REPO_DIR="${SCRIPT_DIR:h}"
SKILLS_SRC_DIR="$REPO_DIR/skills"
BACKUP_ROOT="$HOME/.ai-development-skill-backups"

if [ ! -d "$SKILLS_SRC_DIR" ]; then
  echo "错误：未找到 skills 目录：$SKILLS_SRC_DIR"
  exit 1
fi

# 支持的工具全局 skills 父目录（仅对已存在父目录的工具进行分发）
typeset -a TOOL_BASES
TOOL_BASES=(
  "$HOME/.agents"
  "$HOME/.claude"
  "$HOME/.codex"
  "$HOME/.gemini/config"
  "$HOME/.cursor"
)

typeset -a SKILL_NAMES
SKILL_NAMES=("ai-dev" "product-selection")

sync_one_skill() {
  local src_dir="$1"
  local target_dir="$2"
  local skill_name="$3"
  local target_link="$target_dir/$skill_name"
  local current_target=""
  local backup_dir=""
  local stamp=""

  if [ -L "$target_link" ]; then
    current_target="$(/usr/bin/readlink "$target_link")"
    if [ "$current_target" = "$src_dir" ]; then
      echo "[OK] 已链接：$target_link -> $src_dir"
      return 0
    fi
  fi

  if [ "$CHECK_ONLY" -eq 1 ]; then
    if [ -e "$target_link" ] || [ -L "$target_link" ]; then
      echo "[DRIFT] 需要更新：$target_link (当前指向非本仓库)"
    else
      echo "[MISSING] 未链接：$target_link"
    fi
    return 1
  fi

  /bin/mkdir -p "$target_dir"

  if [ -e "$target_link" ] || [ -L "$target_link" ]; then
    stamp="$(/bin/date +%Y%m%d%H%M%S)"
    backup_dir="$BACKUP_ROOT/$stamp"
    /bin/mkdir -p "$backup_dir"
    /bin/mv "$target_link" "$backup_dir/${skill_name}"
    echo "[BACKUP] 已备份旧目标到：$backup_dir/${skill_name}"
  fi

  /bin/ln -s "$src_dir" "$target_link"
  echo "[LINKED] $target_link -> $src_dir"
}

echo "同步 ai-development skills（源目录：$SKILLS_SRC_DIR）"
if [ "$CHECK_ONLY" -eq 1 ]; then
  echo "模式：仅检查（--check）"
fi
echo ""

HAS_ERROR=0
TOOL_BASE=""
SKILL_NAME=""
SRC_DIR=""
TARGET_SKILLS_DIR=""

for TOOL_BASE in "${TOOL_BASES[@]}"; do
  if [ ! -d "$TOOL_BASE" ]; then
    continue
  fi

  TARGET_SKILLS_DIR="$TOOL_BASE/skills"
  for SKILL_NAME in "${SKILL_NAMES[@]}"; do
    SRC_DIR="$SKILLS_SRC_DIR/$SKILL_NAME"
    if [ ! -d "$SRC_DIR" ]; then
      echo "跳过缺失的源 skill：$SRC_DIR"
      continue
    fi

    if ! sync_one_skill "$SRC_DIR" "$TARGET_SKILLS_DIR" "$SKILL_NAME"; then
      HAS_ERROR=1
    fi
  done
done

echo ""
if [ "$CHECK_ONLY" -eq 1 ] && [ "$HAS_ERROR" -ne 0 ]; then
  echo "检查完成：存在未同步项，请运行 ./scripts/sync-skills.sh 修复。"
  exit 1
fi

echo "同步完成。"
