#!/bin/bash
# Quality Audit Script - Score skill quality (0-100)
# Usage: audit-skill.sh <skill-name>

skill_name="$1"
skill_dir="$HOME/.gemini/skills/$skill_name"
skill_md="$skill_dir/SKILL.md"

if [ ! -f "$skill_md" ]; then
    echo "0"
    exit 0
fi

score=0

# STRUCTURE (30 points)

# Valid frontmatter (10 points)
if grep -q "^---" "$skill_md" && grep -q "^name:" "$skill_md" && grep -q "^description:" "$skill_md"; then
    score=$((score + 10))
fi

# Required sections (10 points)
sections=0
grep -q "## When to Use" "$skill_md" && sections=$((sections + 1))
grep -q "## Core Capabilities\|## What It Does\|## Features" "$skill_md" && sections=$((sections + 1))
grep -q "## Usage\|## Usage Patterns" "$skill_md" && sections=$((sections + 1))
[ $sections -ge 2 ] && score=$((score + 10))

# Follows template (10 points)
if grep -q "## Best Practices\|## Notes" "$skill_md"; then
    score=$((score + 10))
fi

# CONTENT (40 points)

# Has examples (15 points)
if grep -q "## Examples\|## Example\|### Example" "$skill_md" || grep -q "\`\`\`" "$skill_md"; then
    score=$((score + 15))
fi

# Has best practices (10 points)
if grep -q "## Best Practices\|### ✅ DO\|### ❌ DON'T" "$skill_md"; then
    score=$((score + 10))
fi

# Has integration notes (10 points)
if grep -q "## Integration\|works with:\|Works with:" "$skill_md"; then
    score=$((score + 10))
fi

# Token efficient (5 points) - Description < 200 chars
desc_length=$(grep "^description:" "$skill_md" | wc -c)
[ $desc_length -lt 200 ] && score=$((score + 5))

# METADATA (30 points)

# Has version (10 points)
if grep -q "version:" "$skill_md"; then
    score=$((score + 10))
fi

# Has license (5 points)
if grep -q "license:" "$skill_md"; then
    score=$((score + 5))
fi

# Has dependencies in graph (10 points)
if [ -f "$HOME/.gemini/skills/skill-manager/data/skill_dependencies.json" ]; then
    if jq -e ".skill_dependencies[\"$skill_name\"]" "$HOME/.gemini/skills/skill-manager/data/skill_dependencies.json" >/dev/null 2>&1; then
        score=$((score + 10))
    fi
fi

# Has activation rules (5 points)
if [ -f "$HOME/.gemini/skills/skill-manager/data/activation_rules.json" ]; then
    if jq -e ".activation_rules | to_entries[] | select(.value.skills[] == \"$skill_name\")" "$HOME/.gemini/skills/skill-manager/data/activation_rules.json" >/dev/null 2>&1; then
        score=$((score + 5))
    fi
fi

echo $score
