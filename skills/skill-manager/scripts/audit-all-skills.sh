#!/bin/bash
# Audit all skills and generate quality report

SKILLS_DIR="$HOME/.gemini/skills"
AUDIT_SCRIPT="$SKILLS_DIR/skill-manager/scripts/audit-skill.sh"

echo "========================================="
echo "  SKILL QUALITY AUDIT REPORT"
echo "========================================="
echo ""

total_score=0
skill_count=0
excellent=0
good=0
needs_improvement=0
requires_upgrade=0

declare -A scores

# Audit each skill
for skill_dir in "$SKILLS_DIR"/*/; do
    skill_name=$(basename "$skill_dir")
    
    # Skip non-skill directories
    [ "$skill_name" = "core" ] && continue
    [ "$skill_name" = "examples" ] && continue
    [ "$skill_name" = "themes" ] && continue
    [ "$skill_name" = "ooxml" ] && continue
    [ "$skill_name" = "canvas-fonts" ] && continue
    
    if [ ! -f "$skill_dir/SKILL.md" ]; then
        continue
    fi
    
    score=$(bash "$AUDIT_SCRIPT" "$skill_name")
    scores["$skill_name"]=$score
    total_score=$((total_score + score))
    skill_count=$((skill_count + 1))
    
    # Categorize
    if [ $score -ge 90 ]; then
        excellent=$((excellent + 1))
    elif [ $score -ge 70 ]; then
        good=$((good + 1))
    elif [ $score -ge 50 ]; then
        needs_improvement=$((needs_improvement + 1))
    else
        requires_upgrade=$((requires_upgrade + 1))
    fi
done

avg_score=$((total_score / skill_count))

echo "Overall Statistics:"
echo "  Total Skills Audited: $skill_count"
echo "  Average Quality Score: $avg_score/100"
echo ""
echo "Quality Distribution:"
echo "  Excellent (90-100):      $excellent skills"
echo "  Good (70-89):            $good skills"
echo "  Needs Improvement (50-69): $needs_improvement skills"
echo "  Requires Upgrade (0-49):   $requires_upgrade skills"
echo ""

# Top 10 highest quality
echo "========================================="
echo "Top 10 Highest Quality Skills:"
echo "========================================="
for skill in "${!scores[@]}"; do
    echo "${scores[$skill]} $skill"
done | sort -rn | head -10 | awk '{print $1 "\t" $2}'
echo ""

# Bottom 10 (needs work)
echo "========================================="
echo "Top 10 Skills Needing Upgrades:"
echo "========================================="
for skill in "${!scores[@]}"; do
    echo "${scores[$skill]} $skill"
done | sort -n | head -10 | awk '{print $1 "\t" $2}'
echo ""

# Skills needing immediate attention (< 50)
echo "========================================="
echo "Priority Upgrades (Score < 50):"
echo "========================================="
for skill in "${!scores[@]}"; do
    score=${scores[$skill]}
    if [ $score -lt 50 ]; then
        echo "  $score - $skill"
    fi
done | sort -n
echo ""

echo "========================================="
echo "Audit complete: $(date)"
echo "========================================="
