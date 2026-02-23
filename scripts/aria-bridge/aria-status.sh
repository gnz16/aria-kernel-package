#!/usr/bin/env bash
# aria-status.sh — Show status of all Constellation agents
# Usage: bash aria-status.sh

BRIDGE_DIR="/root/.aria-bridge"
SESSION="aria-constellation"
AGENTS="logician oracle auditor craftsman archivist"

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║         ARIA Constellation Status                    ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

# tmux session
if tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "  Session  : $SESSION [ACTIVE]"
  echo "  Windows  : $(tmux list-windows -t $SESSION -F '#W' 2>/dev/null | tr '\n' ' ')"
else
  echo "  Session  : $SESSION [NOT RUNNING]"
  echo "  Start   : tmux new-session -s $SESSION"
fi

echo ""
echo "  Agent Inboxes:"
echo "  ─────────────────────────────────────────────────────"

for agent in $AGENTS; do
  INBOX="$BRIDGE_DIR/agents/$agent/inbox.md"
  OUTBOX="$BRIDGE_DIR/agents/$agent/outbox.md"

  if [[ -f "$INBOX" ]]; then
    STATUS=$(grep -m1 "^STATUS:" "$INBOX" 2>/dev/null | awk '{print $2}' || echo "UNKNOWN")
    TASK=$(grep -m1 "^TASK_ID:" "$INBOX" 2>/dev/null | awk '{print $2}' || echo "—")
  else
    STATUS="NO_INBOX"
    TASK="—"
  fi

  # Pad agent name
  printf "  %-12s  inbox: %-12s  task: %s\n" "$agent" "$STATUS" "$TASK"
done

echo ""
echo "  Shared Context:"
echo "  ─────────────────────────────────────────────────────"
if [[ -f "$BRIDGE_DIR/shared-context/project-state.md" ]]; then
  LINES=$(wc -l < "$BRIDGE_DIR/shared-context/project-state.md")
  UPDATED=$(grep -m1 "Last Updated" "$BRIDGE_DIR/shared-context/project-state.md" | sed 's/.*: //' || echo "—")
  echo "  project-state.md : $LINES lines | updated: $UPDATED"
else
  echo "  project-state.md : NOT FOUND"
fi

if [[ -f "$BRIDGE_DIR/shared-context/delta.md" ]]; then
  DLINES=$(wc -l < "$BRIDGE_DIR/shared-context/delta.md")
  echo "  delta.md         : $DLINES lines"
fi

echo ""
echo "  Commands:"
echo "  ─────────────────────────────────────────────────────"
echo "  Spawn agent  : bash $BRIDGE_DIR/aria-spawn.sh <agent>"
echo "  Assign task  : bash $BRIDGE_DIR/aria-assign.sh <agent> <task-id> <priority> <task.md>"
echo "  Collect      : bash $BRIDGE_DIR/aria-collect.sh"
echo "  Attach       : tmux attach -t $SESSION"
echo ""
