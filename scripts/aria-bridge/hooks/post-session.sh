#!/usr/bin/env bash
# post-session.sh — ARIA post-session memory hook
# Runs lightweight memory checks and compression reminders after a session ends.
# Usage: bash /root/.aria-bridge/hooks/post-session.sh

set -euo pipefail

BRIDGE_DIR="/root/.aria-bridge"
MEMORY_DIR="/root/.claude/projects/-root/memory"
EVOLUTION_LOG="$BRIDGE_DIR/evolution-log.md"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║         ARIA Post-Session Memory Hook                ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "  Timestamp : $TIMESTAMP"
echo ""

# --- Memory size check ---
MEMORY_LINES=$(wc -l < "$MEMORY_DIR/MEMORY.md" 2>/dev/null || echo 0)
echo "  Memory check:"
echo "    MEMORY.md : $MEMORY_LINES lines"

if [[ "$MEMORY_LINES" -gt 200 ]]; then
  echo ""
  echo "  [WARN] MEMORY.md exceeds 200 lines ($MEMORY_LINES)."
  echo "  Recommendation: Route a compression task to the Archivist."
  echo "    bash $BRIDGE_DIR/aria-assign.sh archivist MEM-$(date +%s) P2 <task.md>"
else
  echo "    Size: OK (under 200 lines)"
fi

# --- Evolution log freshness check ---
LAST_ENTRY=$(grep -m1 "^## Entry" "$EVOLUTION_LOG" 2>/dev/null || echo "none")
echo ""
echo "  Evolution log:"
echo "    Last entry: $LAST_ENTRY"

# --- Archivist inbox check ---
ARCHIVIST_INBOX="$BRIDGE_DIR/agents/archivist/inbox.md"
if [[ -f "$ARCHIVIST_INBOX" ]]; then
  INBOX_STATUS=$(grep -m1 "^STATUS:" "$ARCHIVIST_INBOX" 2>/dev/null | awk '{print $2}' || echo "UNKNOWN")
  echo ""
  echo "  Archivist inbox: $INBOX_STATUS"
  if [[ "$INBOX_STATUS" == "PENDING" ]]; then
    echo "  [WARN] Archivist has unprocessed tasks — consider running aria-spawn.sh archivist"
  fi
fi

# --- Git memory repo status ---
if git -C "$MEMORY_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
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
else
  echo ""
  echo "  [INFO] Memory directory is not a git repo."
  echo "  Run session-start.sh or git init $MEMORY_DIR to enable versioning."
fi

echo ""
echo "── Post-session check complete ─────────────────────────"
echo ""
