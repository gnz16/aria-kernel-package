#!/bin/bash
# Create new skill from template
# Usage: create-skill.sh <skill-name> <category> <description>

SKILLS_DIR="$HOME/.gemini/skills"
skill_name="$1"
category="$2"
description="$3"

if [ -z "$skill_name" ]; then
    echo "Usage: create-skill.sh <skill-name> <category> <description>"
    echo "Example: create-skill.sh my-automation 'Development Workflow' 'Automates X tasks'"
    exit 1
fi

skill_dir="$SKILLS_DIR/$skill_name"

if [ -d "$skill_dir" ]; then
    echo "Error: Skill '$skill_name' already exists"
    exit 1
fi

echo "Creating new skill: $skill_name"
echo "Category: $category"
echo ""

# Create directory structure
mkdir -p "$skill_dir"/{scripts,templates,references}

# Create SKILL.md template
cat > "$skill_dir/SKILL.md" << EOF
---
name: $skill_name
description: ${description:-Add description here. Use when...}
license: MIT
metadata:
  author: custom
  version: "1.0.0"
---

# ${skill_name^}

Brief description of what this skill does.

## When to Use

**Use for:**
- Task 1
- Task 2
- Task 3

**Triggers:**
- "Phrase that activates this skill"
- "Another trigger phrase"

## Core Capabilities

### 1. Capability One
Description of first capability

### 2. Capability Two
Description of second capability

## Usage Patterns

### Pattern 1: Basic Usage
\`\`\`
User: "Example request"

Response: What the skill does
\`\`\`

## Best Practices

### ✅ DO
- Best practice 1
- Best practice 2

### ❌ DON'T
- Anti-pattern 1
- Anti-pattern 2

## Examples

**Example 1:**
\`\`\`bash
# Command or code example
\`\`\`

## Integration

Works with:
- other-skill-1
- other-skill-2

## Notes

- Important note 1
- Important note 2

---

**Your tagline here!**
EOF

echo "✓ Created SKILL.md"

# Create README
cat > "$skill_dir/README.md" << EOF
# $skill_name

${description:-Add description}

## Installation

Skill is installed at: \`~/.gemini/skills/$skill_name\`

## Usage

Ask Gemini to use this skill:
- "Help me with..."

## Files

- \`SKILL.md\` - Main skill definition
- \`scripts/\` - Helper scripts (if needed)
- \`templates/\` - Templates (if needed)
- \`references/\` - Reference documentation (if needed)

## Development

Edit \`SKILL.md\` to customize skill behavior.
EOF

echo "✓ Created README.md"
echo ""
echo "Skill template created at: $skill_dir"
echo ""
echo "Next steps:"
echo "1. Edit SKILL.md: vim $skill_dir/SKILL.md"
echo "2. Add scripts (optional): Add to $skill_dir/scripts/"
echo "3. Install skill: install-skill.sh $skill_dir $skill_name '$category'"
echo ""
