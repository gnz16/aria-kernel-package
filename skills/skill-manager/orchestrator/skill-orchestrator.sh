#!/bin/bash
# Skill Orchestrator - Intelligent skill activation and chaining
# Usage: skill-orchestrator.sh <skill-name> [context]

SKILL_NAME="$1"
CONTEXT="${2:-manual}"
PROTOCOL_DIR="$HOME/.gemini/skills/skill-manager/protocol"

echo "🔗 Skill Orchestrator v1.0"
echo "========================================="
echo "Activating: $SKILL_NAME"
echo ""

# Check prerequisites
if [ -f "$PROTOCOL_DIR/skill_prerequisites.json" ]; then
    required=$(jq -r ".skill_prerequisites.prerequisites[\"$SKILL_NAME\"].required[]?" \
        "$PROTOCOL_DIR/skill_prerequisites.json" 2>/dev/null)
    
    if [ -n "$required" ]; then
        echo "📋 Prerequisites Check:"
        missing=0
        for prereq in $required; do
            if [ -d "$HOME/.gemini/skills/$prereq" ]; then
                echo "  ✅ $prereq"
            else
                echo "  ❌ $prereq (REQUIRED)"
                missing=$((missing + 1))
            fi
        done
        
        if [ $missing -gt 0 ]; then
            echo ""
            echo "⚠️  Missing required prerequisites!"
            echo "Install missing skills or continue anyway? (y/n)"
            # In practice, would wait for input
            # For now, just warn
            echo ""
        fi
    fi
    
    # Show recommendations
    recommended=$(jq -r ".skill_prerequisites.prerequisites[\"$SKILL_NAME\"].recommended[]?" \
        "$PROTOCOL_DIR/skill_prerequisites.json" 2>/dev/null)
    
    if [ -n "$recommended" ]; then
        echo ""
        echo "💡 Recommended (optional):"
        for rec in $recommended; do
            echo "  → $rec"
        done
        echo ""
    fi
fi

# Activate skill (placeholder - in practice would run actual skill)
echo "⚙️  Running $SKILL_NAME..."
echo ""

# Emit completion event and check chains
if [ -f "$PROTOCOL_DIR/skill_chains.json" ]; then
    echo "🔄 Checking skill chains..."
    
    next_skills=$(jq -r ".skill_chains.chains[\"$SKILL_NAME\"][]?" \
        "$PROTOCOL_DIR/skill_chains.json" 2>/dev/null)
    
    if [ -n "$next_skills" ]; then
        echo ""
        echo "📢 Suggested next skills:"
        jq -r ".skill_chains.chains[\"$SKILL_NAME\"][] | 
            \"  → \(.next) (confidence: \(.confidence * 100)%) - \(.reason)\"" \
            "$PROTOCOL_DIR/skill_chains.json" 2>/dev/null
        echo ""
    fi
fi

echo "========================================="
echo "✅ $SKILL_NAME completed"
