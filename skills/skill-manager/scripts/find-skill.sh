#!/bin/bash

# Skill Manager - Find skills by keyword
# Usage: ./find-skill.sh "keyword"

SKILLS_DIR="$HOME/.gemini/skills"
KEYWORD="$1"

if [ -z "$KEYWORD" ]; then
    echo "Usage: $0 <keyword>"
    echo "Example: $0 react"
    exit 1
fi

echo "🔍 Searching for skills matching: '$KEYWORD'"
echo ""

found=0

ls -1 "$SKILLS_DIR" | grep -v "^\." | while read skill; do
    # Search in skill name
    if echo "$skill" | grep -i "$KEYWORD" > /dev/null; then
        found=$((found + 1))
        echo "✓ $skill (name match)"
        if [ -f "$SKILLS_DIR/$skill/SKILL.md" ]; then
            desc=$(grep "^description:" "$SKILLS_DIR/$skill/SKILL.md" | sed 's/description: //')
            if [ -n "$desc" ]; then
                echo "  └─ $desc"
            fi
        fi
        echo ""
    # Search in description
    elif [ -f "$SKILLS_DIR/$skill/SKILL.md" ]; then
        if grep -i "$KEYWORD" "$SKILLS_DIR/$skill/SKILL.md" > /dev/null; then
            found=$((found + 1))
            echo "✓ $skill (content match)"
            desc=$(grep "^description:" "$SKILLS_DIR/$skill/SKILL.md" | sed 's/description: //')
            if [ -n "$desc" ]; then
                echo "  └─ $desc"
            fi
            echo ""
        fi
    fi
done

if [ $found -eq 0 ]; then
    echo "No skills found matching '$KEYWORD'"
fi
