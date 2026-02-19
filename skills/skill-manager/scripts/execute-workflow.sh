#!/bin/bash
# Workflow Executor - Run predefined skill workflows
# Usage: execute-workflow.sh <workflow-name>

WORKFLOW_DIR="$HOME/.gemini/skills/skill-manager/workflows"
WORKFLOW_FILE="$WORKFLOW_DIR/$1.yml"

if [ -z "$1" ]; then
    echo "Usage: execute-workflow.sh <workflow-name>"
    echo ""
    echo "Available workflows:"
    ls -1 "$WORKFLOW_DIR"/*.yml | xargs -n1 basename | sed 's/.yml$//'
    exit 1
fi

if [ ! -f "$WORKFLOW_FILE" ]; then
    echo "Error: Workflow '$1' not found"
    echo ""
    echo "Available workflows:"
    ls -1 "$WORKFLOW_DIR"/*.yml | xargs -n1 basename | sed 's/.yml$//'
    exit 1
fi

# Parse workflow metadata
workflow_name=$(grep "^name:" "$WORKFLOW_FILE" | cut -d'"' -f2)
workflow_desc=$(grep "^description:" "$WORKFLOW_FILE" | cut -d'"' -f2)
workflow_time=$(grep "^estimated_time:" "$WORKFLOW_FILE" | cut -d'"' -f2)
skills_count=$(grep "^skills_used:" "$WORKFLOW_FILE" | awk '{print $2}')

echo "========================================="
echo "  WORKFLOW: $workflow_name"
echo "========================================="
echo "Description: $workflow_desc"
echo "Estimated Time: $workflow_time"
echo "Skills Used: $skills_count"
echo ""
echo "========================================="
echo ""

# Extract and display steps
echo "Workflow Steps:"
echo "========================================="

step_num=1
while IFS= read -r line; do
    if [[ "$line" =~ "- step:" ]]; then
        step_num=$(echo "$line" | grep -oE '[0-9]+')
    elif [[ "$line" =~ "skill:" ]]; then
        skill=$(echo "$line" | awk '{print $2}')
    elif [[ "$line" =~ "action:" ]]; then
        action=$(echo "$line" | cut -d'"' -f2)
        echo "Step $step_num: $skill"
        echo "  → $action"
        echo ""
    fi
done < "$WORKFLOW_FILE"

echo "========================================="
echo ""

# Ask for confirmation
read -p "Execute this workflow? (y/n): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Workflow cancelled."
    exit 0
fi

echo ""
echo "Starting workflow execution..."
echo ""

# Note: Actual skill execution would be handled by Gemini
# This script provides workflow guidance
echo "📋 Workflow ready for execution"
echo "   Each step will activate the corresponding skill"
echo "   Follow the workflow sequence for best results"
echo ""

# Display success criteria
echo "========================================="
echo "Success Criteria:"
echo "========================================="
grep -A 10 "^validation:" "$WORKFLOW_FILE" | tail -n +2 | grep "^  -" | sed 's/^  - /✓ /'
echo ""

# Display deliverables
echo "========================================="
echo "Expected Deliverables:"
echo "========================================="
grep -A 10 "^deliverables:" "$WORKFLOW_FILE" | tail -n +2 | grep "^  -" | sed 's/^  - /📦 /'
echo ""
echo "========================================="
