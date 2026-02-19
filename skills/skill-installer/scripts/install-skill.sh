#!/bin/bash
# Safe Skill Installer - Install new skills without breaking ecosystem
# Usage: install-skill.sh <source-path> <skill-name> [category]

set -e  # Exit on error

SKILLS_DIR="$HOME/.gemini/skills"
SKILL_MANAGER="$SKILLS_DIR/skill-manager"
BACKUP_DIR="$SKILL_MANAGER/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

source_path="$1"
skill_name="$2"
category="${3:-Other}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================="
echo "  SKILL INSTALLER - Safe Integration"
echo "========================================="
echo ""

# Validation
if [ -z "$source_path" ] || [ -z "$skill_name" ]; then
    echo "${RED}Error: Missing arguments${NC}"
    echo "Usage: install-skill.sh <source-path> <skill-name> [category]"
    exit 1
fi

if [ ! -d "$source_path" ]; then
    echo "${RED}Error: Source path does not exist: $source_path${NC}"
    exit 1
fi

if [ ! -f "$source_path/SKILL.md" ]; then
    echo "${RED}Error: SKILL.md not found in $source_path${NC}"
    echo "All skills must have a SKILL.md file"
    exit 1
fi

# Check for conflicts
if [ -d "$SKILLS_DIR/$skill_name" ]; then
    echo "${RED}Error: Skill '$skill_name' already exists${NC}"
    echo "Choose a different name or remove existing skill first"
    exit 1
fi

echo "${YELLOW}Validating skill structure...${NC}"

# Validate SKILL.md has required frontmatter
if ! grep -q "^name:" "$source_path/SKILL.md"; then
    echo "${RED}Error: SKILL.md missing 'name:' in frontmatter${NC}"
    exit 1
fi

if ! grep -q "^description:" "$source_path/SKILL.md"; then
    echo "${RED}Error: SKILL.md missing 'description:' in frontmatter${NC}"
    exit 1
fi

echo "${GREEN}✓ Skill structure valid${NC}"
echo ""

# Create backup directory
mkdir -p "$BACKUP_DIR"

echo "${YELLOW}Creating backups...${NC}"

# Backup indexes
if [ -f "$SKILL_MANAGER/references/SKILL_INDEX.json" ]; then
    cp "$SKILL_MANAGER/references/SKILL_INDEX.json" \
       "$BACKUP_DIR/SKILL_INDEX_${TIMESTAMP}.json"
    echo "${GREEN}✓ Backed up SKILL_INDEX.json${NC}"
fi

if [ -f "$SKILL_MANAGER/data/skill_metrics.json" ]; then
    cp "$SKILL_MANAGER/data/skill_metrics.json" \
       "$BACKUP_DIR/skill_metrics_${TIMESTAMP}.json"
    echo "${GREEN}✓ Backed up skill_metrics.json${NC}"
fi

echo ""
echo "${YELLOW}Installing skill...${NC}"

# Copy skill to skills directory
cp -r "$source_path" "$SKILLS_DIR/$skill_name"
echo "${GREEN}✓ Copied skill files to $SKILLS_DIR/$skill_name${NC}"

echo ""
echo "${YELLOW}Updating indexes...${NC}"

# Regenerate skill index
if [ -f "$SKILL_MANAGER/scripts/generate-index.sh" ]; then
    bash "$SKILL_MANAGER/scripts/generate-index.sh" > /dev/null 2>&1
    echo "${GREEN}✓ Updated SKILL_INDEX.json${NC}"
else
    echo "${YELLOW}⚠ generate-index.sh not found, skipping index update${NC}"
fi

# Initialize metrics
if [ -f "$SKILL_MANAGER/scripts/init-metrics.sh" ]; then
    bash "$SKILL_MANAGER/scripts/init-metrics.sh" > /dev/null 2>&1
    echo "${GREEN}✓ Initialized skill_metrics.json${NC}"
else
    echo "${YELLOW}⚠ init-metrics.sh not found, skipping metrics init${NC}"
fi

echo ""
echo "========================================="
echo "${GREEN}  SKILL INSTALLED SUCCESSFULLY!${NC}"
echo "========================================="
echo ""
echo "Skill: $skill_name"
echo "Category: $category"
echo "Location: $SKILLS_DIR/$skill_name"
echo ""

# Verify installation
total_skills=$(jq '.total_skills' "$SKILL_MANAGER/references/SKILL_INDEX.json" 2>/dev/null || echo "unknown")
echo "Total skills: $total_skills"
echo ""

echo "Next steps:"
echo "1. Test skill: Ask Gemini to use $skill_name"
echo "2. Add dependencies (optional):"
echo "   Edit $SKILL_MANAGER/data/skill_dependencies.json"
echo "3. Configure auto-activation (optional):"
echo "   Edit $SKILL_MANAGER/data/activation_rules.json"
echo "4. Add to workflows (optional):"
echo "   Edit workflow YAML files in $SKILL_MANAGER/workflows/"
echo ""
echo "Backups saved to: $BACKUP_DIR"
echo ""
