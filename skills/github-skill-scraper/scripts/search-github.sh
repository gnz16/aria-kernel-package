#!/bin/bash
# Search GitHub for skills
# Usage: search-github.sh <query>

query="$1"

if [ -z "$query" ]; then
    echo "Usage: search-github.sh <query>"
    exit 1
fi

echo "Searching GitHub for skills matching: '$query'"
echo ""

# Try GitHub CLI first
if command -v gh &> /dev/null; then
    gh search repos "SKILL.md $query" --limit 20 --json fullName,description,url \
        --jq '.[] | "📦 \(.fullName)\n   \(.description)\n   🔗 \(.url)\n"'
else
    # Fallback: Use GitHub API directly
    curl -s "https://api.github.com/search/repositories?q=SKILL.md+${query}&per_page=20" \
        | jq -r '.items[] | "📦 \(.full_name)\n   \(.description)\n   🔗 \(.html_url)\n"'
fi
