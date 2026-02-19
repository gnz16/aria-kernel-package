#!/bin/bash
# ARIA Memory Compression Engine
# Compresses volatile memory when limits are reached

set -e

SCRIPTS_DIR="/Users/apple/.gemini/_scripts"
CONTINUITY="$SCRIPTS_DIR/CONTINUITY.md"
ARCHIVE_DIR="$SCRIPTS_DIR/ARCHIVE"
LOG_FILE="$SCRIPTS_DIR/compression.log"

mkdir -p "$ARCHIVE_DIR"

echo "=== COMPRESSION CYCLE $(date) ===" >> "$LOG_FILE"

# 1. Archive completed CONTINUITY entries
echo "Archiving CONTINUITY.md..." | tee -a "$LOG_FILE"
COMPLETED_PATTERN="\| \--- \|"
# Find lines with completed tasks (|---| separator) and archive
if grep -q "$COMPLETED_PATTERN" "$CONTINUITY"; then
    # Keep header and active sections, summarize completed
    awk '
    BEGIN { archiving=0; summary="" }
    /^## Active Subtasks/ { archiving=1; print; next }
    /^## Current Blockers/ { archiving=0 }
    /^## Dissonance Signals/ { archiving=0 }
    /^## Session Summary Archive/ { archiving=0 }
    archiving && /^\| [0-9]+ \|/ {
        summary = summary " • Task " $2 " (" $4 ")"
        next
    }
    { print }
    END {
        if (summary != "") {
            print "## Previous Session Summary"
            print summary > "/dev/stderr"
        }
    }
    ' "$CONTINUITY" > "$CONTINUITY.tmp" 2>/dev/null
    
    if [ -s "$CONTINUITY.tmp" ]; then
        # Archive old version with timestamp
        cp "$CONTINUITY" "$ARCHIVE_DIR/CONTINUITY_$(date '+%Y%m%d_%H%M%S').md"
        mv "$CONTINUITY.tmp" "$CONTINUITY"
        echo "  ✓ CONTINUITY compressed" | tee -a "$LOG_FILE"
    fi
fi

# 2. Prune STRATEGIC_LEDGER history (keep max 5 entries)
echo "Pruning STRATEGIC_LEDGER.md..." | tee -a "$LOG_FILE"
HISTORY_START=$(grep -n "^## History$" /Users/apple/.gemini/_scripts/STRATEGIC_LEDGER.md | cut -d: -f1)
if [ -n "$HISTORY_START" ]; then
    TOTAL_HISTORY=$(( $(wc -l < /Users/apple/.gemini/_scripts/STRATEGIC_LEDGER.md) - HISTORY_START ))
    if [ "$TOTAL_HISTORY" -gt 10 ]; then
        # Keep only last 5 history entries
        tail -n 15 /Users/apple/.gemini/_scripts/STRATEGIC_LEDGER.md > /Users/apple/.gemini/_scripts/STRATEGIC_LEDGER.md.tmp
        mv /Users/apple/.gemini/_scripts/STRATEGIC_LEDGER.md.tmp /Users/apple/.gemini/_scripts/STRATEGIC_LEDGER.md
        echo "  ✓ STRATEGIC_LEDGER pruned" | tee -a "$LOG_FILE"
    fi
fi

# 3. Rotate LOGIC_LOG (keep last 100 lines as summary)
echo "Rotating LOGIC_LOG.md..." | tee -a "$LOG_FILE"
LOGIC_LOG="/Users/apple/.gemini/_scripts/LOGIC_LOG.md"
if [ -f "$LOGIC_LOG" ]; then
    TOTAL_LOG_LINES=$(wc -l < "$LOGIC_LOG")
    if [ "$TOTAL_LOG_LINES" -gt 200 ]; then
        # Archive old entries
        HEAD_LINES=$(( TOTAL_LOG_LINES - 100 ))
        mkdir -p "$ARCHIVE_DIR/logs"
        head -n "$HEAD_LINES" "$LOGIC_LOG" > "$ARCHIVE_DIR/logs/LOGIC_LOG_$(date '+%Y%m%d_%H%M%S').md"
        tail -n 100 "$LOGIC_LOG" > "$LOGIC_LOG.tmp"
        mv "$LOGIC_LOG.tmp" "$LOGIC_LOG"
        echo "  ✓ LOGIC_LOG rotated (archived $HEAD_LINES lines)" | tee -a "$LOG_FILE"
    fi
fi

# 4. Update state with compression metrics
if command -v jq &> /dev/null && [ -f "$SCRIPTS_DIR/appm_state.json" ]; then
    LAST_COMPRESSION=$(date -Iseconds)
    jq --arg time "$LAST_COMPRESSION" '.compression_metrics.last_compression = $time' "$SCRIPTS_DIR/appm_state.json" > "$SCRIPTS_DIR/appm_state.json.tmp"
    mv "$SCRIPTS_DIR/appm_state.json.tmp" "$SCRIPTS_DIR/appm_state.json"
fi

echo "✓ Compression cycle complete" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
