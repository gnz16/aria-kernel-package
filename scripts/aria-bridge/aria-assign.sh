#!/usr/bin/env bash
# aria-assign.sh — Write a task to an agent's inbox
# Usage: bash aria-assign.sh <agent> <task-id> <priority> <task-file>
# Example: bash aria-assign.sh craftsman BRIDGE-C001 HIGH /tmp/task.md

set -euo pipefail

AGENT="${1:-}"
TASK_ID="${2:-}"
PRIORITY="${3:-MEDIUM}"
TASK_FILE="${4:-}"
BRIDGE_DIR="$(cd "$(dirname "$0")" && pwd)"

# Dual-paradigm: support both agent models
VALID_AGENTS="gemini claude opencode logician oracle auditor craftsman archivist"
VALID_PRIORITY="HIGH MEDIUM LOW"

# Cross-platform hash command
HASH_CMD="sha256sum"
[[ "$(uname)" == "Darwin" ]] && HASH_CMD="shasum -a 256"

usage() {
  echo "Usage: $0 <agent> <task-id> <priority> <task-file>"
  echo "  agent    : $VALID_AGENTS"
  echo "  priority : $VALID_PRIORITY"
  echo "  task-file: markdown with ## Task, ## Context, ## Expected Output sections"
  exit 1
}

[[ -z "$AGENT" || -z "$TASK_ID" || -z "$TASK_FILE" ]] && usage
[[ ! " $VALID_AGENTS " =~ " $AGENT " ]] && { echo "Unknown agent: $AGENT"; usage; }
[[ ! -f "$TASK_FILE" ]] && { echo "Task file not found: $TASK_FILE"; exit 1; }

# Ensure agent directory exists
mkdir -p "$BRIDGE_DIR/agents/$AGENT"

INBOX="$BRIDGE_DIR/agents/$AGENT/inbox.md"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Compute context hash
DELTA_HASH="none"
if [[ -f "$BRIDGE_DIR/shared-context/project-state.md" ]]; then
  DELTA_HASH=$($HASH_CMD "$BRIDGE_DIR/shared-context/project-state.md" | cut -d' ' -f1)
fi

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
Write your result to: $BRIDGE_DIR/agents/$AGENT/outbox.md
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
