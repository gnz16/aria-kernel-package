#!/bin/bash
# Analyze Skill Usage Patterns
# Provides insights into which skills are used, when, and effectiveness

USAGE_LOG="$HOME/.gemini/skills/skill-manager/data/skill_usage.jsonl"

if [ ! -f "$USAGE_LOG" ]; then
    echo "No usage data found"
    echo "Skills will be logged automatically as they're used"
    exit 0
fi

echo "========================================="
echo "  SKILL USAGE ANALYTICS"
echo "========================================="
echo ""

# Total usage count
total_uses=$(wc -l < "$USAGE_LOG")
echo "📊 Total Skill Activations: $total_uses"
echo ""

# Most used skills
echo "Top 10 Most Used Skills:"
echo "----------------------------------------"
jq -r '.skill' "$USAGE_LOG" | sort | uniq -c | sort -rn | head -10 | \
    awk '{printf "%3d  %s\n", $1, $2}'
echo ""

# Usage by context
echo "Usage by Context:"
echo "----------------------------------------"
jq -r '.context' "$USAGE_LOG" | sort | uniq -c | sort -rn | \
    awk '{printf "%3d  %s\n", $1, $2}'
echo ""

# Success rate
echo "Outcomes:"
echo "----------------------------------------"
jq -r '.outcome' "$USAGE_LOG" | sort | uniq -c | sort -rn | \
    awk '{printf "%3d  %s\n", $1, $2}'
echo ""

# Recent activity (last 10)
echo "Recent Activity (Last 10):"
echo "----------------------------------------"
tail -10 "$USAGE_LOG" | jq -r '[.timestamp, .skill, .context, .outcome] | @tsv' | \
    column -t -s $'\t'
echo ""

# Usage over time
echo "Usage by Hour of Day:"
echo "----------------------------------------"
jq -r '.timestamp | split("T")[1] | split(":")[0]' "$USAGE_LOG" | \
    sort | uniq -c | sort -rn | head -10 | \
    awk '{printf "%02d:00  ", $2; for(i=0;i<$1;i++) printf "▓"; printf "\n"}'
echo ""

echo "========================================="
