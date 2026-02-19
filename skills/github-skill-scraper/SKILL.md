---
name: github-skill-scraper
description: Search GitHub for skills, preview SKILL.md files, and install them automatically. Use when discovering new skills, browsing skill repositories, or expanding your skill library.
license: MIT
metadata:
  author: custom
  version: "1.0.0"
---

# GitHub Skill Scraper

**Discover and install skills from GitHub in seconds.**

## When to Use

**Use for:**
- Finding new skills on GitHub
- Browsing skill repositories
- Previewing skill documentation
- Installing skills automatically
- Searching for specific skill types

**Triggers:**
- "Search GitHub for testing skills"
- "Find React skills on GitHub"
- "Install skills from repository"
- "Browse available skills"

## Core Capabilities

### 1. Search GitHub for Skills
Search repositories containing SKILL.md files:
```bash
github-skill-scraper search "react best practices"
github-skill-scraper search "aws lambda"
github-skill-scraper search "testing"
```

### 2. Preview Skill Content
View SKILL.md before installing:
```bash
github-skill-scraper preview user/repo
github-skill-scraper preview user/repo skill-name
```

### 3. Install from GitHub
One-command installation:
```bash
github-skill-scraper install user/repo
github-skill-scraper install user/repo skill-name
```

### 4. Browse Popular Skill Repos
Curated list of known skill sources:
```bash
github-skill-scraper browse
```

## Usage Patterns

### Pattern 1: Search and Install
```bash
# Search for React skills
github-skill-scraper search "react"

# Preview a skill
github-skill-scraper preview vercel-labs/agent-skills react-best-practices

# Install if good
github-skill-scraper install vercel-labs/agent-skills react-best-practices
```

### Pattern 2: Clone Entire Repository
```bash
# Install all skills from a repo
github-skill-scraper clone user/repo
```

### Pattern 3: Browse Curated Sources
```bash
# List known skill repositories
github-skill-scraper browse

# Install from curated source
github-skill-scraper install-from vercel-labs
```

## Known Skill Sources

**Curated repositories:**
1. **anthropics/skills** - Official Anthropic skills
2. **vercel-labs/agent-skills** - React/Next.js skills
3. **obra/superpowers** - Development workflow
4. **everything-claude-code** - Coding patterns
5. **Automattic/agent-skills** - WordPress skills
6. **itsmostafa/aws-agent-skills** - AWS services
7. **SpillwaveSolutions/developing-with-docker-agentic-skill** - Docker

## Scripts

### search-github.sh
```bash
#!/bin/bash
# Search GitHub for skills
query="$1"
gh search repos "SKILL.md $query" --limit 20
```

### preview-skill.sh
```bash
#!/bin/bash
# Preview SKILL.md from GitHub
repo="$1"
skill_path="${2:-SKILL.md}"
gh api "/repos/$repo/contents/$skill_path" \
  --jq '.content' | base64 -d
```

### install-from-github.sh
```bash
#!/bin/bash
# Clone and install skill from GitHub
repo="$1"
skill_name="$2"
temp_dir="/tmp/skill-install-$$"

# Clone repository
git clone "https://github.com/$repo.git" "$temp_dir"

# Install skill
if [ -n "$skill_name" ]; then
  ~/.gemini/skills/skill-installer/scripts/install-skill.sh \
    "$temp_dir/$skill_name" "$skill_name" "Downloaded"
else
  # Find and install all skills
  find "$temp_dir" -name "SKILL.md" -type f | while read skill_md; do
    skill_dir=$(dirname "$skill_md")
    name=$(basename "$skill_dir")
    ~/.gemini/skills/skill-installer/scripts/install-skill.sh \
      "$skill_dir" "$name" "Downloaded"
  done
fi

# Cleanup
rm -rf "$temp_dir"
```

## Best Practices

### ✅ DO
- Preview skills before installing
- Check skill quality (examples, documentation)
- Verify skill source is trustworthy
- Read descriptions carefully

### ❌ DON'T
- Install without previewing
- Trust unknown sources blindly
- Install duplicate skills
- Skip validation

## Integration

**Works with:**
- **skill-installer** - Safe installation
- **skill-manager** - Organize installed skills
- **verification-before-completion** - Validate quality

## Examples

### Example 1: Find AWS Skills
```bash
github-skill-scraper search "aws lambda"
# Returns repositories with AWS Lambda skills
```

### Example 2: Install from Known Source
```bash
# Preview
github-skill-scraper preview anthropics/skills test-driven-development

# Install
github-skill-scraper install anthropics/skills test-driven-development
```

### Example 3: Clone Entire Skill Set
```bash
# Install all skills from Vercel
github-skill-scraper clone vercel-labs/agent-skills
```

## Quick Commands

```bash
# Search
gscraper search "testing"

# Preview
gscraper preview user/repo skill-name

# Install
gscraper install user/repo skill-name

# Browse
gscraper browse

# Help
gscraper --help
```

## Security

**Safety features:**
- Previews content before install
- Uses skill-installer validation
- Backs up indexes automatically
- Allows rollback on failure

## Notes

- Requires GitHub CLI (`gh`) or falls back to `git`
- Skills installed to `~/.gemini/skills/`
- Auto-updates skill indexes
- Validates SKILL.md structure

---

**Discover. Preview. Install. Expand your skill library!** 🔍
