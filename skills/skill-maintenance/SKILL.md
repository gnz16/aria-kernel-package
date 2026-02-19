---
name: skill-maintenance
description: Automates the health, update, and index generation of the skill ecosystem. Use when you need to update all skills, refresh indexes, or verify system integrity.
---

# Skill Maintenance

## When to Use

**Use for:**
- Updating all installed skills from their repositories
- Regenerating skill indexes and metrics
- Verifying the integrity of the skill system
- Fixing "missing skill" errors

**Triggers:**
- "Update all skills"
- "Refresh skill system"
- "Sync skills"
- "Fix skill index"

## Cores Capabilities

### 1. Update All Skills
Updates every git-based skill in the `~/.gemini/skills` directory.
```bash
~/.gemini/skills/skill-maintenance/scripts/update-skills.sh
```

### 2. Refresh System
Updates skills AND regenerates all indexes (The "Master" command).
```bash
~/.gemini/skills/skill-maintenance/scripts/refresh-system.sh
```

## Scripts

### update-skills.sh
Iterates through `~/.gemini/skills/*`, checks if they are git repositories, and runs `git pull`.

### refresh-system.sh
1. Runs `update-skills.sh`
2. Runs `skill-manager/scripts/generate-index.sh`
3. Runs `skill-manager/scripts/init-metrics.sh`
4. Runs `audit_skills.py` (if available)

## Automation

This skill serves as the "System Automator" requested to keep skill trackers and health management in sync.
