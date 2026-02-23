#!/usr/bin/env bash
# aria-status.sh — Show status of all bridge agents (dual-paradigm)
# Supports both tri-agent (gemini/claude/opencode) and Constellation models
# Usage: bash aria-status.sh

BRIDGE_DIR="$(cd "$(dirname "$0")" && pwd)"

# Auto-detect which agent model is active
TRI_AGENTS=""
CONSTELLATION_AGENTS=""

for agent in gemini claude opencode; do
  [[ -d "$BRIDGE_DIR/agents/$agent" ]] && TRI_AGENTS="$TRI_AGENTS $agent"
done
for agent in logician oracle auditor craftsman archivist; do
  [[ -d "$BRIDGE_DIR/agents/$agent" ]] && CONSTELLATION_AGENTS="$CONSTELLATION_AGENTS $agent"
done

# Fallback: check inbox/ directory (original format)
INBOX_AGENTS=""
if [[ -d "$BRIDGE_DIR/inbox" ]]; then
  for f in "$BRIDGE_DIR/inbox/"*.md; do
    [[ -f "$f" ]] && INBOX_AGENTS="$INBOX_AGENTS $(basename "$f" .md)"
  done
fi

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║         ARIA Bridge Status                           ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "  Platform : $(uname -s) $(uname -m)"
echo "  Bridge   : $BRIDGE_DIR"

# tmux session check
SESSION="aria-constellation"
if command -v tmux >/dev/null 2>&1 && tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "  Session  : $SESSION [ACTIVE]"
  echo "  Windows  : $(tmux list-windows -t "$SESSION" -F '#W' 2>/dev/null | tr '\n' ' ')"
else
  echo "  Session  : $SESSION [NOT RUNNING]"
fi

# --- Tri-Agent Model ---
if [[ -n "$TRI_AGENTS" ]]; then
  echo ""
  echo "  Tri-Agent Model (tool-based routing):"
  echo "  ─────────────────────────────────────────────────────"
  for agent in $TRI_AGENTS; do
    INBOX="$BRIDGE_DIR/agents/$agent/inbox.md"
    if [[ -f "$INBOX" ]]; then
      STATUS=$(grep -m1 "^STATUS:" "$INBOX" 2>/dev/null | awk '{print $2}' || echo "—")
      TASK=$(grep -m1 "^TASK_ID:" "$INBOX" 2>/dev/null | awk '{print $2}' || echo "—")
    else
      STATUS="IDLE" TASK="—"
    fi
    printf "  %-12s  status: %-12s  task: %s\n" "$agent" "$STATUS" "$TASK"
  done
fi

# --- Inbox Model (legacy) ---
if [[ -n "$INBOX_AGENTS" ]]; then
  echo ""
  echo "  Inbox Model (legacy):"
  echo "  ─────────────────────────────────────────────────────"
  for agent in $INBOX_AGENTS; do
    INBOX="$BRIDGE_DIR/inbox/$agent.md"
    LINES=$(wc -l < "$INBOX" 2>/dev/null | tr -d ' ')
    printf "  %-20s  %s lines\n" "$agent" "$LINES"
  done
fi

# --- Constellation Model ---
if [[ -n "$CONSTELLATION_AGENTS" ]]; then
  echo ""
  echo "  Constellation Model (role-based routing):"
  echo "  ─────────────────────────────────────────────────────"
  for agent in $CONSTELLATION_AGENTS; do
    INBOX="$BRIDGE_DIR/agents/$agent/inbox.md"
    if [[ -f "$INBOX" ]]; then
      STATUS=$(grep -m1 "^STATUS:" "$INBOX" 2>/dev/null | awk '{print $2}' || echo "—")
      TASK=$(grep -m1 "^TASK_ID:" "$INBOX" 2>/dev/null | awk '{print $2}' || echo "—")
    else
      STATUS="NO_INBOX" TASK="—"
    fi
    printf "  %-12s  status: %-12s  task: %s\n" "$agent" "$STATUS" "$TASK"
  done
fi

# --- Shared Context ---
echo ""
echo "  Shared Context:"
echo "  ─────────────────────────────────────────────────────"
STATE_FILE="$BRIDGE_DIR/shared-context/project-state.md"
DELTA_FILE="$BRIDGE_DIR/shared-context/delta.md"
if [[ -f "$STATE_FILE" ]]; then
  LINES=$(wc -l < "$STATE_FILE" | tr -d ' ')
  echo "  project-state.md : $LINES lines"
fi
if [[ -f "$DELTA_FILE" ]]; then
  DLINES=$(wc -l < "$DELTA_FILE" | tr -d ' ')
  echo "  delta.md         : $DLINES lines"
fi

echo ""
