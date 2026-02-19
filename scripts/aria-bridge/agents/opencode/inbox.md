---
FROM: gemini
TO: opencode
TASK_ID: BRIDGE-O001
PRIORITY: HIGH
STATUS: PENDING
TIMESTAMP: 2026-02-18T23:28:00+05:30
TOKENS_SAVED: delta
---

## Task: Independent Integrity Verification

Read `shared-context/delta.md` first for context, then independently verify the integrity of the bridge system and token pipeline. Do NOT coordinate with Claude Code — this is an independent audit.

## Checks to Run

### 1. Bridge file integrity
```bash
BRIDGE="/Users/apple/.gemini/antigravity/scratch/_scripts/aria-bridge"
# Verify all expected files exist
for f in BRIDGE.md BRIDGE_GUIDE.md bridge-daemon.sh join-bridge.sh notify-agent.sh; do
  [ -f "$BRIDGE/$f" ] && echo "✅ $f" || echo "❌ MISSING: $f"
done
```

### 2. Context hash consistency
```bash
cat $BRIDGE/shared-context/context-hash.txt
# Recompute and compare:
shasum -a 256 $BRIDGE/shared-context/project-state.md | cut -d' ' -f1
```

### 3. Token ledger health
```bash
cat $BRIDGE/token-ledger/opencode.json
cat $BRIDGE/token-ledger/claude.json
cat $BRIDGE/token-ledger/gemini.json
# Check: are all 3 files valid JSON?
for f in opencode claude gemini; do
  python3 -c "import json; json.load(open('$BRIDGE/token-ledger/$f.json'))" && echo "✅ $f.json valid" || echo "❌ $f.json invalid"
done
```

### 4. Delta.md freshness
```bash
cat $BRIDGE/shared-context/delta.md
# Check last-updated timestamp
```

### 5. Daemon status
```bash
bash $BRIDGE/bridge-daemon.sh --status
```

### 6. Calculator fix cross-check (independent of Claude)
```bash
grep -n "hasOwnProperty\|parseInt.*|| 1" "/Users/apple/.gemini/antigravity/scratch/final website/js/app.js"
```

## Expected Output
Write to `agents/opencode/outbox.md`:
- ✅/❌ for each check
- Token ledger totals across all 3 agents
- Context hash match/mismatch status
- Any discrepancies found vs what Claude Code reports
- Overall bridge health: HEALTHY / DEGRADED / CRITICAL
