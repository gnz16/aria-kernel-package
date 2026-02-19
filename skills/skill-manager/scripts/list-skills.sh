#!/bin/bash

# Skill Manager - List all skills with categories
# Usage: ./list-skills.sh

SKILLS_DIR="$HOME/.gemini/skills"

echo "╔════════════════════════════════════════════════╗"
echo "║         GEMINI CLI SKILL LIBRARY               ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

# Count total skills
total=$(ls -1 "$SKILLS_DIR" | grep -v "^\." | wc -l | tr -d ' ')
echo "📦 Total Skills Installed: $total"
echo ""

# List all skills
echo "📋 All Skills (alphabetical):"
echo ""
ls -1 "$SKILLS_DIR" | grep -v "^\." | while read skill; do
    if [ -f "$SKILLS_DIR/$skill/SKILL.md" ]; then
        # Try to extract description from SKILL.md
        desc=$(grep -A 1 "^description:" "$SKILLS_DIR/$skill/SKILL.md" 2>/dev/null | tail -1 | sed 's/description: //' | tr -d '\n')
        if [ -n "$desc" ]; then
            echo "  ✓ $skill"
            echo "    └─ $desc" | cut -c 1-80
        else
            echo "  ✓ $skill"
        fi
    else
        echo "  ✓ $skill"
    fi
done

echo ""
echo "═══════════════════════════════════════════════"
echo "Use: gemini 'what skills do I have?' to see organized view"
