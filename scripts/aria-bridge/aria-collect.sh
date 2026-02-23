#!/usr/bin/env bash
# aria-collect.sh — Collect results from all agent outboxes
# Auto-feeds completed results to the Archivist for context persistence.
# Usage: bash aria-collect.sh [agent]   (omit agent to collect all)

BRIDGE_DIR="$(cd "$(dirname "$0")" && pwd)"
COLLECT_TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Auto-detect which agents exist
ALL_AGENTS=""
for agent in gemini claude opencode logician oracle auditor craftsman archivist; do
  [[ -d "$BRIDGE_DIR/agents/$agent" ]] && ALL_AGENTS="$ALL_AGENTS $agent"
done

AGENTS="${1:-$ALL_AGENTS}"
ARCHIVIST_INBOX="$BRIDGE_DIR/agents/archivist/inbox.md"

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║         ARIA Bridge — Results Collection             ║"
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
    # Feed to Archivist for persistence (if archivist exists and isn't self)
    if [[ "$agent" != "archivist" ]] && [[ -d "$BRIDGE_DIR/agents/archivist" ]]; then
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
echo "── Sync shared context after reviewing ────────────────"
echo "  bash $(dirname "$0")/aria-sync.sh \"<summary>\""
echo ""
