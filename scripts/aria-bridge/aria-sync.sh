#!/usr/bin/env bash
# aria-sync.sh — Update shared-context after agents complete tasks
# Recomputes project-state hash and writes delta.md
# Usage: bash aria-sync.sh "<summary of what changed>"

BRIDGE_DIR="$(cd "$(dirname "$0")" && pwd)"
SUMMARY="${1:-Manual sync}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
STATE_FILE="$BRIDGE_DIR/shared-context/project-state.md"
DELTA_FILE="$BRIDGE_DIR/shared-context/delta.md"
HASH_FILE="$BRIDGE_DIR/shared-context/context-hash.txt"

# Cross-platform hash
HASH_CMD="sha256sum"
[[ "$(uname)" == "Darwin" ]] && HASH_CMD="shasum -a 256"

# Cross-platform sed -i
do_sed_i() {
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}

# Update timestamp in project-state.md
if [[ -f "$STATE_FILE" ]]; then
  do_sed_i "s/^\*\*Last Updated\*\*:.*/**Last Updated**: $TIMESTAMP/" "$STATE_FILE"
fi

# Compute new hash
NEW_HASH="none"
[[ -f "$STATE_FILE" ]] && NEW_HASH=$($HASH_CMD "$STATE_FILE" | cut -d' ' -f1)

# Write delta.md
cat > "$DELTA_FILE" << EOF
# Delta — Changes Since Last Full Read
**Generated**: $TIMESTAMP
**Hash**: $NEW_HASH

## Summary
$SUMMARY

## Agent Instructions
- If your hash in context-hash.txt matches \`$NEW_HASH\` → you're current, read this delta only
- If your hash differs → read full project-state.md then update your hash entry
EOF

# Mark all known agents stale
{
  echo "# Context Hash — Per-Agent Deduplication"
  echo "# Generated: $TIMESTAMP"
  echo "current:$NEW_HASH"
  for agent in gemini claude opencode logician oracle auditor craftsman archivist; do
    [[ -d "$BRIDGE_DIR/agents/$agent" ]] && echo "$agent:stale"
  done
} > "$HASH_FILE"

echo "Sync complete:"
echo "  Hash    : $NEW_HASH"
echo "  Delta   : $DELTA_FILE"
echo "  Summary : $SUMMARY"
echo ""
echo "All agents marked stale — they will read full project-state.md on next task."
