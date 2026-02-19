#!/bin/bash
# Calculate skill weights based on performance metrics
# Weight = base(100) + usage(×0.5) + success_rate(×40) + token_efficiency

METRICS_FILE="$HOME/.gemini/skills/skill-manager/data/skill_metrics.json"

if [ ! -f "$METRICS_FILE" ]; then
    echo "Error: Metrics file not found. Run init-metrics.sh first."
    exit 1
fi

echo "Calculating skill weights..."

# Recalculate weights using jq
jq '.skills |= (to_entries | map({
    key: .key,
    value: (.value + {
      weight: (
        100 + 
        (.value.activations * 0.5) + 
        ((.value.success_rate - 0.5) * 40) +
        (if .value.avg_tokens > 0 then (1000 / .value.avg_tokens * 10) else 0 end)
      )
    })
  }) | from_entries)' "$METRICS_FILE" > tmp.json && mv tmp.json "$METRICS_FILE"

# Update timestamp
current_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
jq --arg time "$current_time" '.last_updated = $time' "$METRICS_FILE" > tmp.json && mv tmp.json "$METRICS_FILE"

echo "✓ Weights updated successfully"

# Show top 10 weighted skills
echo ""
echo "Top 10 Skills by Weight:"
jq -r '.skills | to_entries | sort_by(.value.weight) | reverse | .[0:10] | .[] | 
  "\(.value.weight | floor)\t\(.key)\t(act: \(.value.activations), success: \(.value.success_rate * 100 | floor)%)"' \
  "$METRICS_FILE"
