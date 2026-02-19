#!/bin/bash
# ARIA Bridge v2.0 — Agent Startup Script
# Usage: bash join-bridge.sh --agent [gemini|claude|opencode]

BRIDGE_DIR="/Users/apple/.gemini/antigravity/scratch/_scripts/aria-bridge"
AGENT="${2:-gemini}"  # default to gemini

# Parse --agent flag
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --agent) AGENT="$2"; shift ;;
    esac
    shift
done

# Validate agent
if [[ "$AGENT" != "gemini" && "$AGENT" != "claude" && "$AGENT" != "opencode" ]]; then
    echo "❌ Unknown agent: $AGENT. Use: gemini | claude | opencode"
    exit 1
fi

INBOX="$BRIDGE_DIR/agents/$AGENT/inbox.md"
OUTBOX="$BRIDGE_DIR/agents/$AGENT/outbox.md"
HASH_FILE="$BRIDGE_DIR/shared-context/context-hash.txt"
STATE_FILE="$BRIDGE_DIR/shared-context/project-state.md"
DELTA_FILE="$BRIDGE_DIR/shared-context/delta.md"

echo "🌉 ARIA Agent Bridge v2.0"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Agent:  $AGENT"
echo "Inbox:  $INBOX"
echo "Outbox: $OUTBOX"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── Token Deduplication Check ──────────────────────
CURRENT_HASH=$(md5 -q "$STATE_FILE" 2>/dev/null || md5sum "$STATE_FILE" 2>/dev/null | awk '{print $1}')
LAST_HASH=$(grep "^$AGENT:" "$HASH_FILE" 2>/dev/null | cut -d: -f2 | tr -d ' ')

if [[ "$CURRENT_HASH" == "$LAST_HASH" && -n "$LAST_HASH" ]]; then
    echo "⚡ TOKEN DEDUP: project-state.md unchanged — reading delta only"
    echo ""
    echo "📋 Context Delta (new changes only):"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat "$DELTA_FILE"
    READ_MODE="delta"
else
    echo "📋 Full Project Context (first read or state changed):"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat "$STATE_FILE"
    READ_MODE="full"
    # Update hash for this agent
    if grep -q "^$AGENT:" "$HASH_FILE" 2>/dev/null; then
        sed -i '' "s/^$AGENT:.*/$AGENT: $CURRENT_HASH/" "$HASH_FILE"
    else
        echo "$AGENT: $CURRENT_HASH" >> "$HASH_FILE"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📬 Your Inbox (tasks assigned to $AGENT):"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat "$INBOX"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Bridge active | Agent: $AGENT | Context mode: $READ_MODE"
echo "📝 Write results to: $OUTBOX"
echo ""

# Log token mode to ledger
LEDGER="$BRIDGE_DIR/token-ledger/$AGENT.json"
if [[ -f "$LEDGER" ]]; then
    python3 - <<EOF
import json, datetime
with open("$LEDGER") as f:
    data = json.load(f)
data["sessions"].append({
    "timestamp": datetime.datetime.now().isoformat(),
    "read_mode": "$READ_MODE",
    "tokens_saved": data.get("tokens_per_full_read", 400) if "$READ_MODE" == "delta" else 0
})
data["total_sessions"] = len(data["sessions"])
data["total_tokens_saved"] = sum(s.get("tokens_saved", 0) for s in data["sessions"])
with open("$LEDGER", "w") as f:
    json.dump(data, f, indent=2)
EOF
fi
