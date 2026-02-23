#!/usr/bin/env bash
# aria-spawn.sh — Spawn a Constellation agent in a tmux window
# Usage: bash aria-spawn.sh <agent> [working-dir]
# Agents: logician | oracle | auditor | craftsman | archivist

set -euo pipefail

AGENT="${1:-}"
WORKDIR="${2:-$HOME}"
BRIDGE_DIR="$(cd "$(dirname "$0")" && pwd)"
KERNEL_DIR="$BRIDGE_DIR/agent-kernels"
SESSION="aria-constellation"

VALID_AGENTS="logician oracle auditor craftsman archivist"

usage() {
  echo "Usage: $0 <agent> [working-dir]"
  echo "Agents: $VALID_AGENTS"
  exit 1
}

[[ -z "$AGENT" ]] && usage
[[ ! " $VALID_AGENTS " =~ " $AGENT " ]] && { echo "Unknown agent: $AGENT"; usage; }

# Check for agent kernel
if [[ ! -f "$KERNEL_DIR/$AGENT.md" ]]; then
  echo "  [INFO] Kernel not found: $KERNEL_DIR/$AGENT.md"
  echo "  Create agent kernels in $KERNEL_DIR/ for role-specific behavior."
  echo "  Spawning without custom kernel..."
fi

# Check tmux
if ! command -v tmux >/dev/null 2>&1; then
  echo "ERROR: tmux is required. Install with: brew install tmux" >&2
  exit 1
fi

# Create tmux session if it doesn't exist
if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux new-session -d -s "$SESSION" -n "conductor"
  echo "Created tmux session: $SESSION"
fi

# Kill existing window for this agent if present
tmux kill-window -t "$SESSION:$AGENT" 2>/dev/null || true

# Create agent working directory
AGENT_DIR="$WORKDIR/.aria-agents/$AGENT"
mkdir -p "$AGENT_DIR"

# Copy kernel if it exists
[[ -f "$KERNEL_DIR/$AGENT.md" ]] && cp "$KERNEL_DIR/$AGENT.md" "$AGENT_DIR/CLAUDE.md"

# Spawn agent in new tmux window
tmux new-window -t "$SESSION" -n "$AGENT" -c "$AGENT_DIR"

INBOX="$BRIDGE_DIR/agents/$AGENT/inbox.md"

echo ""
echo "Spawned: $AGENT"
echo "  Session : $SESSION:$AGENT"
echo "  Dir     : $AGENT_DIR"
echo "  Inbox   : $INBOX"
echo ""
echo "Attach: tmux attach -t $SESSION"
echo "Switch: tmux select-window -t $SESSION:$AGENT"
