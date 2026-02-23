#!/usr/bin/env bash
# aria-collect.sh — Collect and display results from all agent outboxes
# Also appends DONE outputs to the Archivist inbox for context persistence.
# Usage: bash aria-collect.sh [agent]   (omit agent to collect all)

BRIDGE_DIR="/root/.aria-bridge"
AGENTS="${1:-logician oracle auditor craftsman archivist}"
ARCHIVIST_INBOX="$BRIDGE_DIR/agents/archivist/inbox.md"
COLLECT_TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║         ARIA Constellation — Results                 ║"
echo "╚══════════════════════════════════════════════════════╝"

for agent in $AGENTS; do
  OUTBOX="$BRIDGE_DIR/agents/$agent/outbox.md"
  echo ""
  echo "── $agent ──────────────────────────────────────────────"

  if [[ ! -f "$OUTBOX" ]]; then
    echo "  No outbox found."
    continue
  fi

  RESULT_STATUS=$(grep -m1 "^STATUS:" "$OUTBOX" 2>/dev/null | awk '{print $2}' || echo "EMPTY")

  if [[ "$RESULT_STATUS" == "DONE" ]]; then
    cat "$OUTBOX"
    # Archivist pipeline: append DONE outputs to archivist inbox for context persistence
    if [[ "$agent" != "archivist" ]]; then
      {
        echo ""
        echo "---"
        echo "## Collected Output: $agent @ $COLLECT_TIMESTAMP"
        echo ""
        cat "$OUTBOX"
      } >> "$ARCHIVIST_INBOX"
    fi
  elif [[ "$RESULT_STATUS" == "EMPTY" || -z "$RESULT_STATUS" ]]; then
    echo "  No results yet."
  else
    echo "  Status: $RESULT_STATUS"
    cat "$OUTBOX"
  fi
done

echo ""
echo "── Update shared context after reviewing results ──────"
echo "  bash $BRIDGE_DIR/aria-sync.sh"
echo ""
