#!/bin/bash
# Generate skill performance analytics report

METRICS_FILE="$HOME/.gemini/skills/skill-manager/data/skill_metrics.json"

if [ ! -f "$METRICS_FILE" ]; then
    echo "Error: Metrics file not found. Run init-metrics.sh first."
    exit 1
fi

echo "========================================="
echo "  SKILL PERFORMANCE ANALYTICS REPORT"
echo "========================================="
echo ""

# Overall stats
total_skills=$(jq '.total_skills' "$METRICS_FILE")
total_activations=$(jq '[.skills[].activations] | add' "$METRICS_FILE")
total_completions=$(jq '[.skills[].completions] | add' "$METRICS_FILE")
avg_success_rate=$(jq '[.skills[] | select(.activations > 0) | .success_rate] | add / length * 100' "$METRICS_FILE" 2>/dev/null || echo "0")
last_updated=$(jq -r '.last_updated' "$METRICS_FILE")

echo "Overall Statistics:"
echo "  Total Skills: $total_skills"
echo "  Total Activations: $total_activations"
echo "  Total Completions: $total_completions"
echo "  Average Success Rate: ${avg_success_rate}%"
echo "  Last Updated: $last_updated"
echo ""

# Top 10 most used
echo "========================================="
echo "Top 10 Most Used Skills:"
echo "========================================="
jq -r '.skills | to_entries | sort_by(.value.activations) | reverse | .[0:10] | .[] | 
  "\(.value.activations)\t\(.key)"' "$METRICS_FILE" | 
  awk 'BEGIN {print "Count\tSkill"} {print}'
echo ""

# Top 10 highest success rate (with at least 3 activations)
echo "========================================="
echo "Top 10 Highest Success Rate:"
echo "========================================="
jq -r '.skills | to_entries | 
  map(select(.value.activations >= 3)) | 
  sort_by(.value.success_rate) | reverse | .[0:10] | .[] | 
  "\(.value.success_rate * 100 | floor)%\t\(.key)\t(\(.value.activations) uses)"' "$METRICS_FILE" |
  awk 'BEGIN {print "Rate\tSkill\tUsage"} {print}'
echo ""

# Top 10 most token-efficient (with at least 3 activations)
echo "========================================="
echo "Top 10 Most Token-Efficient:"
echo "========================================="
jq -r '.skills | to_entries | 
  map(select(.value.avg_tokens > 0 and .value.activations >= 3)) | 
  sort_by(.value.avg_tokens) | .[0:10] | .[] | 
  "\(.value.avg_tokens | floor)\t\(.key)\t(\(.value.activations) uses)"' "$METRICS_FILE" |
  awk 'BEGIN {print "Tokens\tSkill\tUsage"} {print}'
echo ""

# Underutilized skills (< 3 activations)
echo "========================================="
echo "Underutilized Skills (< 3 uses):"
echo "========================================="
underutilized=$(jq -r '.skills | to_entries | 
  map(select(.value.activations < 3)) | 
  sort_by(.value.activations) | .[] | 
  "\(.value.activations)\t\(.key)"' "$METRICS_FILE" | wc -l)
  
if [ "$underutilized" -gt 0 ]; then
    jq -r '.skills | to_entries | 
      map(select(.value.activations < 3)) | 
      sort_by(.value.activations) | .[0:10] | .[] | 
      "\(.value.activations)\t\(.key)"' "$METRICS_FILE" |
      awk 'BEGIN {print "Uses\tSkill"} {print}'
    echo "  (Showing first 10 of $underutilized total)"
else
    echo "  All skills have been used!"
fi
echo ""

# Recently used
echo "========================================="
echo "Recently Used Skills (Last 10):"
echo "========================================="
jq -r '.skills | to_entries | 
  map(select(.value.last_used != null)) | 
  sort_by(.value.last_used) | reverse | .[0:10] | .[] | 
  "\(.value.last_used)\t\(.key)"' "$METRICS_FILE" |
  awk 'BEGIN {print "Last Used\tSkill"} {print}'
echo ""

echo "========================================="
echo "Report generated: $(date)"
echo "========================================="
