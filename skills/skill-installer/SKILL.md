---
name: skill-installer
description: Safely install and integrate new skills into the skill ecosystem. Automatically updates indexes, metrics, dependencies, and activation rules without breaking existing functionality. Use when adding new skills from repositories or creating custom skills.
license: MIT
metadata:
  author: custom
  version: "1.0.0"
---

# Skill Installer

**Safely add new skills without breaking your 54-skill ecosystem.**

## When to Use

**Use for:**
- Installing skills from GitHub repositories
- Adding custom skills
- Integrating downloaded skills
- Updating skill metadata

**Triggers:**
- "Install the X skill"
- "Add skill from repository"
- "Integrate this new skill"
- "Set up a custom skill"

## What It Does

**Safe Integration Process:**
1. ✅ Validate skill structure (SKILL.md required)
2. ✅ Copy skill to `~/.gemini/skills/`
3. ✅ Update SKILL_INDEX.json
4. ✅ Initialize skill_metrics.json entry
5. ✅ Add to skill_dependencies.json (if applicable)
6. ✅ Update activation_rules.json (if applicable)
7. ✅ Verify no conflicts
8. ✅ Test skill activation

**Result:** New skill fully integrated, all systems updated

## Installation Methods

### Method 1: From GitHub Repository
```bash
skill-installer install-from-repo <github-url> [skill-name]
```

**Example:**
```bash
skill-installer install-from-repo \
  https://github.com/user/custom-skill custom-skill
```

### Method 2: From Local Directory
```bash
skill-installer install-local <path-to-skill> [skill-name]
```

**Example:**
```bash
skill-installer install-local ./my-custom-skill custom-skill
```

### Method 3: Create New Skill
```bash
skill-installer create-new <skill-name> <category>
```

**Example:**
```bash
skill-installer create-new my-workflow "Development Workflow"
```

## Validation Checks

**Before installation:**
- [ ] SKILL.md exists with valid YAML frontmatter
- [ ] Skill name doesn't conflict with existing skills
- [ ] Required metadata present (name, description)
- [ ] Directory structure valid

**After installation:**
- [ ] Skill appears in SKILL_INDEX.json
- [ ] Metrics initialized in skill_metrics.json
- [ ] All indexes regenerated
- [ ] Skill activatable

## Integration Updates

**Files Updated Automatically:**

1. **SKILL_INDEX.json**
   - Adds new skill entry with metadata
   - Updates total_skills count
   - Categorizes skill appropriately

2. **skill_metrics.json**
   - Initializes tracking for new skill
   - Sets base weight (100)
   - Zero activations to start

3. **skill_dependencies.json** (optional)
   - Add if skill has dependencies
   - Specify works_well_with, requires, enhances

4. **activation_rules.json** (optional)
   - Add if skill should auto-activate
   - Define project type triggers

## Installation Script

```bash
#!/bin/bash
# install-skill.sh <source> <skill-name> [category]

source=$1
skill_name=$2
category=${3:-"Other"}

# Validate
if [ ! -f "$source/SKILL.md" ]; then
  echo "Error: SKILL.md not found"
  exit 1
fi

# Check conflicts
if [ -d "$HOME/.gemini/skills/$skill_name" ]; then
  echo "Error: Skill '$skill_name' already exists"
  exit 1
fi

# Copy skill
cp -r "$source" "$HOME/.gemini/skills/$skill_name"

# Update indexes
~/.gemini/skills/skill-manager/scripts/generate-index.sh
~/.gemini/skills/skill-manager/scripts/init-metrics.sh

echo "✓ Skill '$skill_name' installed successfully"
```

## Safety Features

### 1. Backup Before Install
```bash
# Automatic backup of indexes
backup_dir="$HOME/.gemini/skills/skill-manager/backups"
mkdir -p "$backup_dir"
cp SKILL_INDEX.json "$backup_dir/SKILL_INDEX.$(date +%s).json"
```

### 2. Rollback on Failure
```bash
if [ $? -ne 0 ]; then
  echo "Installation failed, rolling back..."
  restore_from_backup
  exit 1
fi
```

### 3. Validation Tests
```bash
# Test skill activation
test_skill_activation "$skill_name" || rollback
```

### 4. Conflict Detection
```bash
# Check for name conflicts
check_skill_conflicts "$skill_name"

# Check for file conflicts
check_file_conflicts "$source"
```

## Post-Installation

**After successful install:**
```
✓ Skill installed: my-new-skill
✓ SKILL_INDEX.json updated (54 → 55 skills)
✓ Metrics initialized
✓ Indexes regenerated

Next steps:
1. Test skill: "Use my-new-skill for..."
2. Add dependencies: edit skill_dependencies.json
3. Configure auto-activation: edit activation_rules.json
4. Add to workflow: edit workflow YAML files
```

## Best Practices

### ✅ DO
- Validate SKILL.md structure before install
- Back up indexes before changes
- Test skill after installation
- Add to appropriate category
- Document dependencies

### ❌ DON'T
- Install without SKILL.md
- Skip validation checks
- Modify core skill files directly
- Install conflicting skill names
- Forget to regenerate indexes

## Skill Template

**Minimum SKILL.md:**
```yaml
---
name: my-skill
description: What this skill does. Use when...
---

# My Skill

## When to Use
- Trigger phrases

## Core Capabilities
1. Feature 1
2. Feature 2

## Usage Patterns
Example usage
```

## Integration Checklist

When adding a new skill:
- [ ] Skill has valid SKILL.md
- [ ] Name doesn't conflict
- [ ] Category assigned
- [ ] SKILL_INDEX.json updated
- [ ] skill_metrics.json initialized
- [ ] Dependencies added (if applicable)
- [ ] Activation rules added (if applicable)
- [ ] Skill tested and working
- [ ] Documentation updated

## Troubleshooting

**Skill not appearing in index:**
```bash
~/.gemini/skills/skill-manager/scripts/generate-index.sh
```

**Conflicts after install:**
```bash
# Remove skill
rm -rf ~/.gemini/skills/problem-skill

# Regenerate indexes
generate-index.sh
init-metrics.sh
```

**Validation failed:**
```bash
# Check SKILL.md
cat ~/.gemini/skills/skill-name/SKILL.md | head

# Verify structure
ls -la ~/.gemini/skills/skill-name/
```

## Examples

### Install from GitHub
```bash
# Clone and install
git clone https://github.com/user/awesome-skill /tmp/awesome-skill
skill-installer install-local /tmp/awesome-skill awesome-skill
```

### Create Custom Skill
```bash
# Generate template
skill-installer create-new my-automation "Development Workflow"

# Edit SKILL.md
vim ~/.gemini/skills/my-automation/SKILL.md

# Finalize installation
skill-installer finalize my-automation
```

### Batch Install
```bash
# Install multiple skills
for skill in skill1 skill2 skill3; do
  skill-installer install-from-repo "https://github.com/org/$skill" "$skill"
done
```

## Verification Commands

```bash
# Check skill count
jq '.total_skills' ~/.gemini/skills/skill-manager/references/SKILL_INDEX.json

# List all skills
ls -1 ~/.gemini/skills/

# Verify new skill in index
jq '.skills[] | select(.name == "my-skill")' SKILL_INDEX.json

# Check metrics initialized
jq '.skills["my-skill"]' skill_metrics.json
```

## Notes

- **Always back up** before installing new skills
- **Test immediately** after installation
- **Update workflows** if skill should be included
- **Document dependencies** for better recommendations
- **Set activation rules** for auto-activation

---

**Safe skill integration = Zero downtime, zero conflicts!** 🛡️
