#!/usr/bin/env bash
# aria-assign.sh — Write a task to an agent's inbox
# Usage: bash aria-assign.sh <agent> <task-id> <priority> <task-file>
# Example: bash aria-assign.sh craftsman BRIDGE-C001 HIGH /tmp/task.md

set -euo pipefail

AGENT="${1:-}"
TASK_ID="${2:-}"
PRIORITY="${3:-MEDIUM}"
TASK_FILE="${4:-}"
BRIDGE_DIR="/root/.aria-bridge"

VALID_AGENTS="logician oracle auditor craftsman archivist"
VALID_PRIORITY="HIGH MEDIUM LOW"

usage() {
  echo "Usage: $0 <agent> <task-id> <priority> <task-file>"
  echo "  agent    : $VALID_AGENTS"
  echo "  priority : $VALID_PRIORITY"
  echo "  task-file: path to markdown file with ## Task, ## Context, ## Expected Output sections"
  exit 1
}

[[ -z "$AGENT" || -z "$TASK_ID" || -z "$TASK_FILE" ]] && usage
[[ ! " $VALID_AGENTS " =~ " $AGENT " ]] && { echo "Unknown agent: $AGENT"; usage; }
[[ ! -f "$TASK_FILE" ]] && { echo "Task file not found: $TASK_FILE"; exit 1; }

INBOX="$BRIDGE_DIR/agents/$AGENT/inbox.md"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DELTA_HASH=$(sha256sum "$BRIDGE_DIR/shared-context/project-state.md" 2>/dev/null | cut -d' ' -f1 || echo "none")

cat > "$INBOX" << HEADER
---
FROM: conductor
TO: $AGENT
TASK_ID: $TASK_ID
PRIORITY: $PRIORITY
STATUS: PENDING
TIMESTAMP: $TIMESTAMP
CONTEXT_HASH: $DELTA_HASH
---

HEADER

cat "$TASK_FILE" >> "$INBOX"

cat >> "$INBOX" << FOOTER

## Handoff
Write your result to: /root/.aria-bridge/agents/$AGENT/outbox.md
Format:
\`\`\`
TASK_ID: $TASK_ID
STATUS: DONE
TIMESTAMP: [your completion time]
[your result]
\`\`\`
FOOTER

echo "Task assigned:"
echo "  Agent   : $AGENT"
echo "  Task ID : $TASK_ID"
echo "  Priority: $PRIORITY"
echo "  Inbox   : $INBOX"
echo ""
echo "Notify agent:"
echo "  tmux send-keys -t aria-constellation:$AGENT 'Read $INBOX and execute $TASK_ID. Write results to /root/.aria-bridge/agents/$AGENT/outbox.md.' Enter"
