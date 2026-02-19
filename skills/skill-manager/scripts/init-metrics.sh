#!/bin/bash
# Initialize skill metrics from SKILL_INDEX.json

SKILLS_DIR="$HOME/.gemini/skills"
INDEX_FILE="$SKILLS_DIR/skill-manager/references/SKILL_INDEX.json"
METRICS_FILE="$SKILLS_DIR/skill-manager/data/skill_metrics.json"

echo "Initializing skill performance metrics..."

# Check if index exists
if [ ! -f "$INDEX_FILE" ]; then
    echo "Error: SKILL_INDEX.json not found. Run generate-index.sh first."
    exit 1
fi

# Create metrics structure
cat > "$METRICS_FILE" << 'EOF'
{
  "version": "1.0.0",
  "last_updated": "",
  "total_skills": 0,
  "skills": {}
}
EOF

# Read index and create metric entries for each skill
skill_count=0

while IFS= read -r skill_name; do
    # Skip empty lines
    [ -z "$skill_name" ] && continue
    
    # Add metric entry using jq
    jq --arg name "$skill_name" \
       '.skills[$name] = {
         "activations": 0,
         "completions": 0,
         "failures": 0,
         "success_rate": 0,
         "total_tokens": 0,
         "avg_tokens": 0,
         "weight": 100,
         "last_used": null
       }' "$METRICS_FILE" > tmp.json && mv tmp.json "$METRICS_FILE"
    
    skill_count=$((skill_count + 1))
done < <(jq -r '.skills[].name' "$INDEX_FILE")

# Update metadata
current_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
jq --arg time "$current_time" \
   --arg count "$skill_count" \
   '.last_updated = $time | .total_skills = ($count | tonumber)' \
   "$METRICS_FILE" > tmp.json && mv tmp.json "$METRICS_FILE"

echo "✓ Initialized metrics for $skill_count skills"
echo "✓ Metrics file: $METRICS_FILE"
