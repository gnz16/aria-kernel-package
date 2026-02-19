#!/bin/bash
# Preview SKILL.md from GitHub repository
# Usage: preview-skill.sh <user/repo> [skill-path]

repo="$1"
skill_path="${2:-SKILL.md}"

if [ -z "$repo" ]; then
    echo "Usage: preview-skill.sh <user/repo> [skill-path]"
    exit 1
fi

echo "Fetching SKILL.md from $repo..."
echo ""

# Try GitHub CLI first
if command -v gh &> /dev/null; then
    gh api "/repos/$repo/contents/$skill_path" --jq '.content' | base64 -d
else
    # Fallback: Use GitHub API
    curl -s "https://api.github.com/repos/$repo/contents/$skill_path" \
        | jq -r '.content' | base64 -d
fi
