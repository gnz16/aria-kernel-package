#!/bin/bash
# Master refresh script for the skill system

echo "Starting System Refresh..."

# 1. Update Skills
bash "$HOME/.gemini/skills/skill-maintenance/scripts/update-skills.sh"

# 4. Audit Skills
echo "Auditing Skills..."
REPORT_FILE="$HOME/.gemini/skills/skill-manager/data/reports/AUDIT_REPORT_$(date +%Y%m%d_%H%M%S).txt"
bash "$HOME/.gemini/skills/skill-manager/scripts/audit-all-skills.sh" > "$REPORT_FILE"
echo "Audit report saved to: $REPORT_FILE"

# 2. Regenerate Index
echo "Regenerating Skill Index..."
bash "$HOME/.gemini/skills/skill-manager/scripts/generate-index.sh"

# 3. Initialize/Update Metrics
echo "Updating Metrics..."
bash "$HOME/.gemini/skills/skill-manager/scripts/init-metrics.sh"

echo "System Refresh Complete. All skills updated and tracked."
