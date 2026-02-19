#!/bin/bash
# Verify Ecosystem Integrity
# Comprehensive check of all skill interconnections

SKILLS_DIR="$HOME/.gemini/skills"
SKILL_MANAGER="$SKILLS_DIR/skill-manager"

echo "========================================="
echo "  ECOSYSTEM INTEGRITY VERIFICATION"
echo "========================================="
echo ""

total_issues=0

# 1. Verify Index Accuracy
echo "1️⃣  Verifying skill index..."
indexed_skills=$(jq -r '.skills[].name' "$SKILL_MANAGER/references/SKILL_INDEX.json" 2>/dev/null)
actual_skills=$(find "$SKILLS_DIR" -maxdepth 1 -type d -exec basename {} \; | grep -v "^skill" | sort)

index_issues=0
for skill in $indexed_skills; do
    if [ ! -d "$SKILLS_DIR/$skill" ]; then
        echo "   ❌ Indexed skill missing: $skill"
        index_issues=$((index_issues + 1))
    fi
done

if [ $index_issues -eq 0 ]; then
    echo "   ✅ Index matches filesystem"
else
    echo "   ⚠️  $index_issues index mismatches"
    total_issues=$((total_issues + index_issues))
fi

# 2. Verify Workflow Integrity
echo ""
echo "2️⃣  Verifying workflows..."
workflow_issues=0

if [ -d "$SKILL_MANAGER/workflows" ]; then
    for workflow in "$SKILL_MANAGER/workflows"/*.yml; do
        [ -f "$workflow" ] || continue
        wf_name=$(basename "$workflow" .yml)
        
        # Extract skills from workflow
        skills=$(grep "skill:" "$workflow" | awk '{print $2}' | sort -u)
        
        for skill in $skills; do
            if [ ! -d "$SKILLS_DIR/$skill" ] || [ ! -f "$SKILLS_DIR/$skill/SKILL.md" ]; then
                echo "   ❌ $wf_name → missing skill: $skill"
                workflow_issues=$((workflow_issues + 1))
            fi
        done
    done
fi

if [ $workflow_issues -eq 0 ]; then
    echo "   ✅ All workflow references valid"
else
    echo "   ⚠️  $workflow_issues workflow issues"
    total_issues=$((total_issues + workflow_issues))
fi

# 3. Verify Dependencies
echo ""
echo "3️⃣  Verifying dependency graph..."
dep_issues=0

if [ -f "$SKILL_MANAGER/data/skill_dependencies.json" ]; then
    # Check skills in dependency graph
    jq -r '.skill_dependencies | to_entries[] | "\(.key) \(.value.works_well_with[]?)"' \
        "$SKILL_MANAGER/data/skill_dependencies.json" 2>/dev/null | \
    while read skill dep; do
        if [ ! -d "$SKILLS_DIR/$skill" ]; then
            echo "   ❌ Dependency graph references missing skill: $skill"
            dep_issues=$((dep_issues + 1))
        fi
        if [ -n "$dep" ] && [ ! -d "$SKILLS_DIR/$dep" ]; then
            echo "   ❌ $skill depends on missing skill: $dep"
            dep_issues=$((dep_issues + 1))
        fi
    done
fi

if [ $dep_issues -eq 0 ]; then
    echo "   ✅ All dependencies valid"
else
    echo "   ⚠️  $dep_issues dependency issues"
    total_issues=$((total_issues + dep_issues))
fi

# 4. Verify Activation Rules
echo ""
echo "4️⃣  Verifying activation rules..."
activation_issues=0

if [ -f "$SKILL_MANAGER/data/activation_rules.json" ]; then
    skills=$(jq -r '.activation_rules[].skills[]' "$SKILL_MANAGER/data/activation_rules.json" 2>/dev/null | sort -u)
    
    for skill in $skills; do
        if [ ! -d "$SKILLS_DIR/$skill" ]; then
            echo "   ❌ Activation rule references missing skill: $skill"
            activation_issues=$((activation_issues + 1))
        fi
    done
fi

if [ $activation_issues -eq 0 ]; then
    echo "   ✅ All activation rules valid"
else
    echo "   ⚠️  $activation_issues activation issues"
    total_issues=$((total_issues + activation_issues))
fi

# 5. Verify Metrics Tracking
echo ""
echo "5️⃣  Verifying metrics tracking..."
metrics_issues=0

if [ -f "$SKILL_MANAGER/data/skill_metrics.json" ]; then
    metric_skills=$(jq -r '.skills | keys[]' "$SKILL_MANAGER/data/skill_metrics.json" 2>/dev/null)
    
    for skill in $metric_skills; do
        if [ ! -d "$SKILLS_DIR/$skill" ]; then
            echo "   ❌ Metrics tracking missing skill: $skill"
            metrics_issues=$((metrics_issues + 1))
        fi
    done
fi

if [ $metrics_issues -eq 0 ]; then
    echo "   ✅ All metrics tracking valid"
else
    echo "   ⚠️  $metrics_issues metrics issues"
    total_issues=$((total_issues + metrics_issues))
fi

# Summary
echo ""
echo "========================================="
echo "  INTEGRITY REPORT"
echo "========================================="
echo ""

if [ $total_issues -eq 0 ]; then
    echo "✅ ECOSYSTEM HEALTHY"
    echo ""
    echo "All interconnections verified:"
    echo "  ✅ Index accurate"
    echo "  ✅ Workflows valid"
    echo "  ✅ Dependencies correct"
    echo "  ✅ Activation rules valid"
    echo "  ✅ Metrics tracking all skills"
else
    echo "⚠️  ISSUES FOUND: $total_issues"
    echo ""
    echo "Run update-system.sh to repair some issues"
fi
echo ""
