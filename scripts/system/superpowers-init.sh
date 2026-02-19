#!/bin/bash

# Superpowers Initialization Script for Antigravity

SKILLS_ROOT="/Users/apple/.gemini/skills"
SUPERPOWERS_SKILLS=("brainstorming" "writing-plans" "test-driven-development" "systematic-debugging" "subagent-driven-development")

echo "--- Superpowers Integration Matrix ---"

for skill in "${SUPERPOWERS_SKILLS[@]}"; do
    if [ -d "$SKILLS_ROOT/$skill" ]; then
        echo "[✓] Skill found: $skill"
    else
        echo "[✗] Skill MISSING: $skill"
    fi
done

echo "---------------------------------------"
echo "Workflows installed in .agent/workflows/"
ls /Users/apple/.gemini/antigravity/.agent/workflows/superpowers-*

echo "Superpowers are ready to use."
