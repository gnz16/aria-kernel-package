#!/bin/bash
# ARIA Memory Health Monitor
# Checks memory tier health and enforces limits

set -e

SCRIPTS_DIR="/Users/apple/.gemini/_scripts"
CONTINUITY="$SCRIPTS_DIR/CONTINUITY.md"
STRATEGIC="$SCRIPTS_DIR/STRATEGIC_LEDGER.md"
LOG_FILE="$SCRIPTS_DIR/memory_health.log"
STATE_FILE="$SCRIPTS_DIR/appm_state.json"

# Thresholds (aligned with documented limits)
CONT_WARN=80        # warn at 80 lines
CONT_CRITICAL=100   # critical at 100 lines (compression rule kicks in)
STRAT_WARN=40       # warn at 40 lines
STRAT_CRITICAL=50   # critical at 50 lines
GROWTH_WARN=15
GROWTH_CRITICAL=20

# Get line counts
CONT_COUNT=$(wc -l < "$CONTINUITY" 2>/dev/null || echo "0")
STRAT_COUNT=$(wc -l < "$STRATEGIC" 2>/dev/null || echo "0")

# Calculate growth rate (lines per hour from LOGIC_LOG)
HOURS_ACTIVE=24  # Default, could be calculated from LOGIC_LOG timestamps
if [ -f "$SCRIPTS_DIR/LOGIC_LOG.md" ]; then
    TOTAL_LINES=$(wc -l < "$SCRIPTS_DIR/LOGIC_LOG.md")
    GROWTH_RATE=$((TOTAL_LINES / HOURS_ACTIVE))
else
    GROWTH_RATE=0
fi

# Calculate health score (0-100)
HEALTH_SCORE=0

if [ "$CONT_COUNT" -le "$CONT_WARN" ]; then
    HEALTH_SCORE=$((HEALTH_SCORE + 25))
elif [ "$CONT_COUNT" -le "$CONT_CRITICAL" ]; then
    HEALTH_SCORE=$((HEALTH_SCORE + 10))
fi

if [ "$STRAT_COUNT" -le "$STRAT_WARN" ]; then
    HEALTH_SCORE=$((HEALTH_SCORE + 25))
elif [ "$STRAT_COUNT" -le "$STRAT_CRITICAL" ]; then
    HEALTH_SCORE=$((HEALTH_SCORE + 10))
fi

if [ "$GROWTH_RATE" -lt "$GROWTH_WARN" ]; then
    HEALTH_SCORE=$((HEALTH_SCORE + 25))
elif [ "$GROWTH_RATE" -lt "$GROWTH_CRITICAL" ]; then
    HEALTH_SCORE=$((HEALTH_SCORE + 15))
fi

# Compression ratio (mock for now, would need actual pre/post sizes)
COMPRESSION_RATIO=0.41  # Example healthy ratio
if (( $(echo "$COMPRESSION_RATIO >= 0.3 && $COMPRESSION_RATIO <= 0.5" | bc -l) )); then
    HEALTH_SCORE=$((HEALTH_SCORE + 25))
fi

# Cap at 100
if [ "$HEALTH_SCORE" -gt 100 ]; then
    HEALTH_SCORE=100
fi

# Generate status bar
BAR_LENGTH=10
FILLED_LENGTH=$((HEALTH_SCORE * BAR_LENGTH / 100))
BAR=""
for ((i=0; i<BAR_LENGTH; i++)); do
    if [ "$i" -lt "$FILLED_LENGTH" ]; then
        BAR="${BAR}█"
    else
        BAR="${BAR}░"
    fi
done

# Output dashboard
echo "📊 MEMORY HEALTH [${BAR}] ${HEALTH_SCORE}/100"
echo ""
echo "Volatile (Tier 1):"
echo "  • CONTINUITY.md: ${CONT_COUNT}/100 lines ($(echo "scale=1; $CONT_COUNT * 100 / 100" | bc)%"
if [ "$CONT_COUNT" -le "$CONT_WARN" ]; then
    echo "    ✓ Healthy"
elif [ "$CONT_COUNT" -le "$CONT_CRITICAL" ]; then
    echo "    ⚠ Warning - approaching limit"
else
    echo "    ❌ Critical - compression needed"
fi
echo "  • Growth rate: ${GROWTH_RATE} lines/hr $(if [ "$GROWTH_RATE" -lt "$GROWTH_WARN" ]; then echo "✓"; elif [ "$GROWTH_RATE" -lt "$GROWTH_CRITICAL" ]; then echo "⚠"; else echo "❌"; fi)"
echo ""
echo "Strategic (Tier 2):"
echo "  • STRATEGIC_LEDGER.md: ${STRAT_COUNT}/50 lines ($(echo "scale=1; $STRAT_COUNT * 100 / 50" | bc)%"
if [ "$STRAT_COUNT" -le "$STRAT_WARN" ]; then
    echo "    ✓ Healthy"
elif [ "$STRAT_COUNT" -le "$STRAT_CRITICAL" ]; then
    echo "    ⚠ Warning - approaching limit"
else
    echo "    ❌ Critical - pruning needed"
fi

echo ""
echo "Alerts: $(if [ "$HEALTH_SCORE" -ge 80 ]; then echo "0 active ✓"; elif [ "$HEALTH_SCORE" -ge 70 ]; then echo "1 warning"; else echo "$(( (80 - HEALTH_SCORE) / 10 )) active ⚠"; fi)"

# Log this check
echo "$(date '+%Y-%m-%d %H:%M:%S') - Health: ${HEALTH_SCORE}/100, CONT: ${CONT_COUNT}, STRAT: ${STRAT_COUNT}" >> "$LOG_FILE"

# Auto-compression if critical
if [ "$CONT_COUNT" -ge "$CONT_CRITICAL" ] || [ "$STRAT_COUNT" -ge "$STRAT_CRITICAL" ]; then
    echo ""
    echo "⚠️  CRITICAL: Memory limits exceeded. Run compression:"
    echo "   ~/.gemini/_scripts/compression_engine.sh"
    echo ""
    exit 1
fi

exit 0
