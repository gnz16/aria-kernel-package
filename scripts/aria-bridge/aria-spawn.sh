#!/usr/bin/env bash
# aria-spawn.sh — Spawn a Constellation agent in a tmux window
# Usage: bash aria-spawn.sh <agent> [working-dir]
# Agents: logician | oracle | auditor | craftsman | archivist

set -euo pipefail

AGENT="${1:-}"
WORKDIR="${2:-$HOME}"
BRIDGE_DIR="/root/.aria-bridge"
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
[[ ! -f "$KERNEL_DIR/$AGENT.md" ]] && { echo "Kernel not found: $KERNEL_DIR/$AGENT.md"; exit 1; }

# Create tmux session if it doesn't exist
if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux new-session -d -s "$SESSION" -n "conductor"
  echo "Created tmux session: $SESSION"
fi

# Kill existing window for this agent if present
tmux kill-window -t "$SESSION:$AGENT" 2>/dev/null || true

# Create agent working directory with its role kernel as CLAUDE.md
AGENT_DIR="$WORKDIR/.aria-agents/$AGENT"
mkdir -p "$AGENT_DIR"
cp "$KERNEL_DIR/$AGENT.md" "$AGENT_DIR/CLAUDE.md"

# Spawn agent in new tmux window
tmux new-window -t "$SESSION" -n "$AGENT" -c "$AGENT_DIR"

# Start Claude Code in the agent window with its inbox as the first prompt
INBOX="$BRIDGE_DIR/agents/$AGENT/inbox.md"

# Build init prompt — use a temp file to avoid shell quoting/injection issues
PROMPT_FILE="$AGENT_DIR/.init-prompt.txt"
cat > "$PROMPT_FILE" <<PROMPT
You are starting a new session as The ${AGENT^} agent. Read your bridge protocol from CLAUDE.md, then read your inbox at $INBOX and execute any PENDING tasks.
PROMPT

# Launch claude CLI using the prompt file to avoid quoting/injection risks
tmux send-keys -t "$SESSION:$AGENT" "claude --print \"\$(cat '$PROMPT_FILE')\"" Enter

echo ""
echo "Spawned: $AGENT"
echo "  Session : $SESSION:$AGENT"
echo "  Dir     : $AGENT_DIR"
echo "  Inbox   : $INBOX"
echo ""
echo "Attach: tmux attach -t $SESSION"
echo "Switch: tmux select-window -t $SESSION:$AGENT"
