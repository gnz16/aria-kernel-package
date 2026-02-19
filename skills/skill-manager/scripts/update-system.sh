#!/bin/bash
# Enhanced Update System - Preserves local ecosystem integrity
# Usage: update-system.sh

set -e

SKILLS_DIR="$HOME/.gemini/skills"
SKILL_MANAGER="$SKILLS_DIR/skill-manager"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

echo "========================================="
echo "  SKILL SYSTEM UPDATE"
echo "  $TIMESTAMP"
echo "========================================="
echo ""
echo "⚠️  This will ONLY update indexes and metadata"
echo "   Your SKILL.md files will NOT be modified"
echo ""

# Step 1: Regenerate Skill Index
echo "1️⃣  Regenerating skill index..."
bash "$SKILL_MANAGER/scripts/generate-index.sh" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    skill_count=$(jq -r '.total_skills' "$SKILL_MANAGER/references/SKILL_INDEX.json" 2>/dev/null || echo "unknown")
    echo "   ✅ Index updated ($skill_count skills)"
else
    echo "   ⚠️  Index update had issues"
fi

# Step 2: Update Skill Metrics
echo ""
echo "2️⃣  Updating skill metrics..."
bash "$SKILL_MANAGER/scripts/init-metrics.sh" > /dev/null 2>&1
echo "   ✅ Metrics initialized"

# Step 3: Recalculate Weights
echo ""
echo "3️⃣  Recalculating skill weights..."
bash "$SKILL_MANAGER/scripts/calculate-weights.sh" > /dev/null 2>&1
echo "   ✅ Weights recalculated"

# Step 4: Verify Integrity
echo ""
echo "4️⃣  Verifying ecosystem integrity..."

issues_found=0

# Check workflow → skill connections
if [ -d "$SKILL_MANAGER/workflows" ]; then
    for workflow in "$SKILL_MANAGER/workflows"/*.yml; do
        [ -f "$workflow" ] || continue
        workflow_name=$(basename "$workflow")
        
        # Extract skill references from workflow
        skills_in_workflow=$(grep "skill:" "$workflow" | awk '{print $2}' | sort -u)
        
        for skill in $skills_in_workflow; do
            if [ ! -d "$SKILLS_DIR/$skill" ]; then
                echo "   ⚠️  Workflow $workflow_name references missing skill: $skill"
                issues_found=$((issues_found + 1))
            fi
        done
    done
fi

# Check dependency graph validity
if [ -f "$SKILL_MANAGER/data/skill_dependencies.json" ]; then
    dep_skills=$(jq -r '.skill_dependencies | keys[]' "$SKILL_MANAGER/data/skill_dependencies.json" 2>/dev/null)
    for skill in $dep_skills; do
        if [ ! -d "$SKILLS_DIR/$skill" ]; then
            echo "   ⚠️  Dependency graph references missing skill: $skill"
            issues_found=$((issues_found + 1))
        fi
    done
fi

# Check activation rules
if [ -f "$SKILL_MANAGER/data/activation_rules.json" ]; then
    act_skills=$(jq -r '.activation_rules[].skills[]' "$SKILL_MANAGER/data/activation_rules.json" 2>/dev/null | sort -u)
    for skill in $act_skills; do
        if [ ! -d "$SKILLS_DIR/$skill" ]; then
            echo "   ⚠️  Activation rules reference missing skill: $skill"
            issues_found=$((issues_found + 1))
        fi
    done
fi

if [ $issues_found -eq 0 ]; then
    echo "   ✅ All interconnections valid"
else
    echo "   ⚠️  Found $issues_found integrity issues"
fi

# Step 5: Generate Report
echo ""
echo "5️⃣  Generating system report..."

cat > "$SKILL_MANAGER/data/last_update.txt" << EOL
Last Update: $TIMESTAMP
Total Skills: $skill_count
Integrity Issues: $issues_found
Index: Updated
Metrics: Updated
Weights: Recalculated
EOL

echo "   ✅ Report saved"

# Summary
echo ""
echo "========================================="
echo "  UPDATE COMPLETE"
echo "========================================="
echo ""
echo "📊 Summary:"
echo "   Skills: $skill_count"
echo "   Integrity: $([ $issues_found -eq 0 ] && echo '✅ Healthy' || echo "⚠️  $issues_found issues")"
echo "   Indexes: ✅ Updated"
echo "   Metrics: ✅ Updated"
echo ""
echo "💾 Your SKILL.md files were NOT modified"
echo ""

if [ $issues_found -gt 0 ]; then
    echo "⚠️  Run verify-integrity.sh for detailed analysis"
    echo ""
fi

echo "Next steps:"
echo "  - Run analyze-skills.sh for performance analytics"
echo "  - Run audit-all-skills.sh for quality scores"
echo ""
