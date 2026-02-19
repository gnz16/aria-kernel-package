#!/bin/bash
# Skill Usage Logger - Track when and how skills are used
# Usage: log-skill-usage.sh <skill-name> <context> <outcome>

USAGE_LOG="$HOME/.gemini/skills/skill-manager/data/skill_usage.jsonl"
SKILL_NAME="$1"
CONTEXT="${2:-manual}"
OUTCOME="${3:-unknown}"

if [ -z "$SKILL_NAME" ]; then
    echo "Usage: log-skill-usage.sh <skill-name> [context] [outcome]"
    exit 1
fi

# Create log directory if doesn't exist
mkdir -p "$(dirname "$USAGE_LOG")"

# Create JSONL entry
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
session_id="${SESSION_ID:-$(date +%s)}"

cat >> "$USAGE_LOG" << EOF
{"timestamp":"$timestamp","skill":"$SKILL_NAME","context":"$CONTEXT","outcome":"$OUTCOME","session":"$session_id"}
EOF

# Update metrics
if [ -f "$HOME/.gemini/skills/skill-manager/scripts/track-skill.sh" ]; then
    case "$OUTCOME" in
        success)
            bash "$HOME/.gemini/skills/skill-manager/scripts/track-skill.sh" "$SKILL_NAME" activation
            bash "$HOME/.gemini/skills/skill-manager/scripts/track-skill.sh" "$SKILL_NAME" completion 100
            ;;
        failure)
            bash "$HOME/.gemini/skills/skill-manager/scripts/track-skill.sh" "$SKILL_NAME" activation
            bash "$HOME/.gemini/skills/skill-manager/scripts/track-skill.sh" "$SKILL_NAME" failure
            ;;
        *)
            bash "$HOME/.gemini/skills/skill-manager/scripts/track-skill.sh" "$SKILL_NAME" activation
            ;;
    esac
fi
