#!/usr/bin/env bash
# aria-sync.sh — Update shared-context after agents complete tasks
# Recomputes project-state hash and writes delta.md
# Usage: bash aria-sync.sh "<summary of what changed>"

BRIDGE_DIR="/root/.aria-bridge"
SUMMARY="${1:-Manual sync}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
STATE_FILE="$BRIDGE_DIR/shared-context/project-state.md"
DELTA_FILE="$BRIDGE_DIR/shared-context/delta.md"
HASH_FILE="$BRIDGE_DIR/shared-context/context-hash.txt"

# Update Last Updated in project-state.md
if [[ -f "$STATE_FILE" ]]; then
  sed -i "s/^\*\*Last Updated\*\*:.*/\*\*Last Updated\*\*: $TIMESTAMP/" "$STATE_FILE"
  sed -i "s/^\*\*Updated By\*\*:.*/\*\*Updated By\*\*: conductor/" "$STATE_FILE"
fi

# Compute new hash
NEW_HASH=$(sha256sum "$STATE_FILE" | cut -d' ' -f1)

# Write delta.md
cat > "$DELTA_FILE" << EOF
# Delta — Changes Since Last Full Read
**Generated**: $TIMESTAMP
**Hash**: $NEW_HASH

## Summary
$SUMMARY

## Agent Instructions
- If your hash in context-hash.txt matches $NEW_HASH → you're current, read this delta only
- If your hash differs → read full project-state.md then update your hash entry
EOF

# Mark all agents stale (they need to re-read)
cat > "$HASH_FILE" << EOF
logician:stale
oracle:stale
auditor:stale
craftsman:stale
archivist:stale
current:$NEW_HASH
EOF

echo "Sync complete:"
echo "  Hash    : $NEW_HASH"
echo "  Delta   : $DELTA_FILE"
echo "  Summary : $SUMMARY"
echo ""
echo "All agents marked stale — they will read full project-state.md on next task."
