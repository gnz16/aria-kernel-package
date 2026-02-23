#!/usr/bin/env bash
# rotate-log.sh — Append a timestamped session entry to the ARIA evolution log
# Usage: bash hooks/rotate-log.sh [entry-title] [notes]

set -euo pipefail

BRIDGE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
EVOLUTION_LOG="$BRIDGE_DIR/evolution-log.md"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DATE_LABEL=$(date -u +"%Y-%m-%d")

ENTRY_TITLE="${1:-Session Checkpoint}"
ENTRY_NOTES="${2:-Auto-logged by rotate-log.sh}"

# Initialize log if missing
if [[ ! -f "$EVOLUTION_LOG" ]]; then
  echo "# ARIA Evolution Log" > "$EVOLUTION_LOG"
  echo "" >> "$EVOLUTION_LOG"
  echo "*Automated session tracking and health audit history.*" >> "$EVOLUTION_LOG"
fi

# Determine next entry number
LAST_ENTRY_NUM=$(grep -oE "^## Entry ([0-9]+)" "$EVOLUTION_LOG" 2>/dev/null \
  | awk '{print $3}' | sort -n | tail -1 || echo "0")
NEXT_ENTRY_NUM=$(printf "%03d" $(( LAST_ENTRY_NUM + 1 )))

ENTRY_BLOCK="
---

## Entry $NEXT_ENTRY_NUM — $DATE_LABEL $ENTRY_TITLE

**Operator**: rotate-log.sh (automated)
**Timestamp**: $TIMESTAMP
**Platform**: $(uname -s) $(uname -m)
**Trigger**: Hook invocation

### Notes
$ENTRY_NOTES
"

echo "$ENTRY_BLOCK" >> "$EVOLUTION_LOG"

echo "  Evolution log updated: Entry $NEXT_ENTRY_NUM appended to $EVOLUTION_LOG"
