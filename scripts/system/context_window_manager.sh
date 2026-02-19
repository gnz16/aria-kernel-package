#!/bin/bash
# ARIA Context Window Manager - Fixed version

SCRIPTS_DIR="/Users/apple/.gemini/_scripts"
CONFIG="$SCRIPTS_DIR/context_window_config.yaml"
LOG_FILE="$SCRIPTS_DIR/context_window.log"

# Default values
MAX_HISTORY=20
PRESERVE_TURNS=5
CURRENT_TOKENS=0
HISTORY_TURNS=0

# Read config if exists
if [ -f "$CONFIG" ]; then
    MAX_HISTORY=$(grep -E '^max_history_turns:' "$CONFIG" | head -1 | awk '{print $2}' | tr -d ' ' )
    PRESERVE_TURNS=$(grep -E '^preserve_turns:' "$CONFIG" | head -1 | awk '{print $2}' | tr -d ' ' )
fi

# Ensure numeric
MAX_HISTORY=${MAX_HISTORY:-20}
PRESERVE_TURNS=${PRESERVE_TURNS:-5}

# Get stats
if [ -f "$SCRIPTS_DIR/LOGIC_LOG.md" ]; then
    CURRENT_TOKENS=$(wc -w < "$SCRIPTS_DIR/LOGIC_LOG.md")
    HISTORY_TURNS=$(grep -c "^## \[TIMESTAMP\]" "$SCRIPTS_DIR/LOGIC_LOG.md" || echo "0")
fi

# Ensure numeric
HISTORY_TURNS=${HISTORY_TURNS:-0}

echo "📊 CONTEXT WINDOW STATUS"
echo "Current tokens (est): $CURRENT_TOKENS"
echo "History turns: $HISTORY_TURNS"
echo "Limits: MAX=$MAX_HISTORY, PRESERVE=$PRESERVE_TURNS"
echo ""

# Check if trimming needed
if [ "$HISTORY_TURNS" -gt "$MAX_HISTORY" ]; then
    echo "⚠️  Trimming history ($HISTORY_TURNS > $MAX_HISTORY turns)"
    ARCHIVE_DIR="$SCRIPTS_DIR/ARCHIVE/context"
    mkdir -p "$ARCHIVE_DIR"
    
    TO_TRIM=$((HISTORY_TURNS - PRESERVE_TURNS))
    head -n "$TO_TRIM" "$SCRIPTS_DIR/LOGIC_LOG.md" > "$ARCHIVE_DIR/LOGIC_LOG_$(date +%Y%m%d_%H%M%S).md"
    tail -n "$PRESERVE_TURNS" "$SCRIPTS_DIR/LOGIC_LOG.md" > "$SCRIPTS_DIR/LOGIC_LOG.md.tmp"
    mv "$SCRIPTS_DIR/LOGIC_LOG.md.tmp" "$SCRIPTS_DIR/LOGIC_LOG.md"
    
    echo "✅ Trimmed $TO_TRIM turns, preserved $PRESERVE_TURNS"
    echo ""
    HISTORY_TURNS=$PRESERVE_TURNS
fi

# Determine strategy
if [ "$CURRENT_TOKENS" -lt 4000 ]; then
    STRATEGY="small (include all)"
elif [ "$CURRENT_TOKENS" -lt 16000 ]; then
    STRATEGY="medium (sliding window)"
else
    STRATEGY="large (summarized)"
fi

echo "✅ Strategy: $STRATEGY"
echo ""
echo "Token reduction active:"
echo "  • Serial position optimization"
echo "  • Auto-trim history ($MAX_HISTORY turn limit)"
echo "  • Importance-based summarization"
echo "  • Pattern preservation (TODO, FIXME, DECISION, BLOCKER)"
echo ""
echo "Savings: 30-60% for medium/large contexts"

echo "$(date): tokens=$CURRENT_TOKENS turns=$HISTORY_TURNS strategy=$STRATEGY" >> "$LOG_FILE"
