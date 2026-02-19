#!/bin/bash
# Update all git-based skills
SKILLS_DIR="$HOME/.gemini/skills"

echo "Updating all skills in $SKILLS_DIR..."

for skill in "$SKILLS_DIR"/*; do
    if [ -d "$skill/.git" ]; then
        echo "Updating $(basename "$skill")..."
        (cd "$skill" && git pull)
    fi
done

echo "Skills update complete."
