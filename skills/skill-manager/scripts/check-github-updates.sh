#!/bin/bash
# Check GitHub for Skill Updates
# NON-DESTRUCTIVE - only shows what's available

KNOWN_REPOS=(
    "anthropics/skills"
    "vercel-labs/agent-skills"
    "obra/superpowers"
    "Automattic/agent-skills"
)

echo "========================================="
echo "  CHECK GITHUB FOR SKILL UPDATES"
echo "========================================="
echo ""
echo "⚠️  This is READ-ONLY"
echo "   No files will be modified"
echo ""

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI not installed"
    echo "   Install: brew install gh"
    exit 1
fi

echo "Checking known skill repositories..."
echo ""

for repo in "${KNOWN_REPOS[@]}"; do
    echo "📦 $repo"
    
    # Get last commit date
    last_commit=$(gh api "/repos/$repo/commits" --jq '.[0].commit.committer.date' 2>/dev/null)
    
    if [ -n "$last_commit" ]; then
        echo "   Last updated: $last_commit"
        echo "   View: https://github.com/$repo"
    else
        echo "   ⚠️  Could not fetch updates"
    fi
    echo ""
done

echo "========================================="
echo ""
echo "To install updates manually:"
echo "  1. Visit repository on GitHub"
echo "  2. Review changes"
echo "  3. Use: github-skill-scraper install <repo> <skill-name>"
echo ""
echo "💡 Never use 'git pull' in ~/.gemini/skills/"
echo "   It may overwrite your customizations"
echo ""
