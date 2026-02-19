#!/bin/bash
# Intelligent Skill Recommender
# Recommends skills based on context, history, and patterns

SKILLS_DIR="$HOME/.gemini/skills"
USAGE_LOG="$SKILLS_DIR/skill-manager/data/skill_usage.jsonl"
DEPENDENCIES="$SKILLS_DIR/skill-manager/data/skill_dependencies.json"
INDEX="$SKILLS_DIR/skill-manager/references/SKILL_INDEX.json"

context="$1"

if [ -z "$context" ]; then
    echo "Usage: recommend-skills.sh <context>"
    echo "Examples:"
    echo "  recommend-skills.sh 'testing react component'"
    echo "  recommend-skills.sh 'deploying to AWS'"
    echo "  recommend-skills.sh 'debugging Node.js app'"
    exit 1
fi

echo "========================================="
echo "  SKILL RECOMMENDATIONS"
echo "  Context: $context"
echo "========================================="
echo ""

# Parse context for keywords
keywords=$(echo "$context" | tr '[:upper:]' '[:lower:]' | tr -s ' ' '\n')

# Search for matching skills
recommendations=()

while IFS= read -r line; do
    skill_name=$(echo "$line" | jq -r '.name')
    skill_desc=$(echo "$line" | jq -r '.description' | tr '[:upper:]' '[:lower:]')
    
    # Check if any keyword matches
    for keyword in $keywords; do
        if echo "$skill_desc" | grep -q "$keyword"; then
            # Get success rate if available
            success_rate="N/A"
            usage_count=0
            
            if [ -f "$USAGE_LOG" ]; then
                usage_count=$(grep "\"$skill_name\"" "$USAGE_LOG" | wc -l)
                success=$(grep "\"$skill_name\"" "$USAGE_LOG" | grep "success" | wc -l)
                if [ $usage_count -gt 0 ]; then
                    success_rate=$((success * 100 / usage_count))
                fi
            fi
            
            recommendations+=("$skill_name|$usage_count|$success_rate")
            break
        fi
    done
done < <(jq -c '.skills[]' "$INDEX" 2>/dev/null)

# Sort by usage count and display
echo "Recommended Skills:"
echo "----------------------------------------"

if [ ${#recommendations[@]} -eq 0 ]; then
    echo "No matching skills found"
    echo ""
    echo "Try broader terms or check available skills:"
    echo "  ls -1 ~/.gemini/skills/"
else
    printf "%-30s %8s %12s\n" "Skill" "Uses" "Success"
    echo "----------------------------------------"
    
    printf '%s\n' "${recommendations[@]}" | sort -t'|' -k2 -rn | head -10 | while IFS='|' read -r skill uses rate; do
        printf "%-30s %8s %11s%%\n" "$skill" "$uses" "$rate"
    done
fi

echo ""

# Show related skills if dependencies exist
if [ ${#recommendations[@]} -gt 0 ] && [ -f "$DEPENDENCIES" ]; then
    first_rec=$(echo "${recommendations[0]}" | cut -d'|' -f1)
    
    echo "Skills that work well with $first_rec:"
    echo "----------------------------------------"
    jq -r ".skill_dependencies[\"$first_rec\"].works_well_with[]?" "$DEPENDENCIES" 2>/dev/null | head -5
    echo ""
fi

echo "========================================="
