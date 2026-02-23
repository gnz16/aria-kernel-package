#!/usr/bin/env bash
# post-session.sh — ARIA post-session memory hook
# Memory size check, git status, and compression reminders.
# Usage: bash hooks/post-session.sh

set -euo pipefail

BRIDGE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Platform-aware memory directory
if [[ "$(uname)" == "Darwin" ]]; then
  MEMORY_DIR="${HOME}/.gemini/antigravity/scratch/_scripts"
  MEMORY_FILE="$MEMORY_DIR/CONTINUITY.md"
else
  MEMORY_DIR="${HOME}/.claude/projects/-root/memory"
  MEMORY_FILE="$MEMORY_DIR/MEMORY.md"
fi

EVOLUTION_LOG="$BRIDGE_DIR/evolution-log.md"

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║         ARIA Post-Session Memory Hook                ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "  Timestamp : $TIMESTAMP"
echo "  Platform  : $(uname -s)"
echo ""

# --- Memory size check ---
if [[ -f "$MEMORY_FILE" ]]; then
  MEMORY_LINES=$(wc -l < "$MEMORY_FILE" | tr -d ' ')
  echo "  Memory check:"
  echo "    $(basename "$MEMORY_FILE") : $MEMORY_LINES lines"

  if [[ "$MEMORY_LINES" -gt 200 ]]; then
    echo ""
    echo "  [WARN] Memory file exceeds 200 lines ($MEMORY_LINES)."
    echo "  Recommendation: Compress — archive completed items."
  else
    echo "    Size: OK (under 200 lines)"
  fi
else
  echo "  Memory file not found: $MEMORY_FILE"
fi

# --- Evolution log freshness ---
if [[ -f "$EVOLUTION_LOG" ]]; then
  LAST_ENTRY=$(grep -m1 "^## Entry" "$EVOLUTION_LOG" 2>/dev/null || echo "none")
  echo ""
  echo "  Evolution log:"
  echo "    Last entry: $LAST_ENTRY"
else
  echo ""
  echo "  Evolution log: NOT FOUND — run rotate-log.sh to initialize"
fi

# --- Git memory repo status ---
if [[ -d "$MEMORY_DIR" ]] && git -C "$MEMORY_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
  DIRTY=$(git -C "$MEMORY_DIR" status --porcelain 2>/dev/null)
  echo ""
  echo "  Memory git repo:"
  if [[ -n "$DIRTY" ]]; then
    echo "    Uncommitted changes detected:"
    git -C "$MEMORY_DIR" status --short 2>/dev/null | sed 's/^/    /'
    echo "    Run: git -C $MEMORY_DIR add -A && git -C $MEMORY_DIR commit -m \"session: $TIMESTAMP\""
  else
    echo "    Clean — no uncommitted changes."
  fi
fi

echo ""
echo "── Post-session check complete ─────────────────────────"
echo ""
