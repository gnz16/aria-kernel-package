#!/bin/bash
# Install skill from GitHub repository
# Usage: install-from-github.sh <user/repo> [skill-name]

repo="$1"
skill_name="$2"
temp_dir="/tmp/skill-install-$$"

if [ -z "$repo" ]; then
    echo "Usage: install-from-github.sh <user/repo> [skill-name]"
    exit 1
fi

echo "Cloning repository: $repo"

# Clone repository
git clone "https://github.com/$repo.git" "$temp_dir" 2>&1 | grep -v "^Cloning"

if [ ! -d "$temp_dir" ]; then
    echo "Error: Failed to clone repository"
    exit 1
fi

echo ""

# Install skill(s)
if [ -n "$skill_name" ]; then
    # Install specific skill
    if [ -f "$temp_dir/$skill_name/SKILL.md" ]; then
        echo "Installing skill: $skill_name"
        ~/.gemini/skills/skill-installer/scripts/install-skill.sh \
            "$temp_dir/$skill_name" "$skill_name" "GitHub"
    elif [ -f "$temp_dir/SKILL.md" ]; then
        echo "Installing skill: $skill_name"
        ~/.gemini/skills/skill-installer/scripts/install-skill.sh \
            "$temp_dir" "$skill_name" "GitHub"
    else
        echo "Error: Skill '$skill_name' not found in repository"
        rm -rf "$temp_dir"
        exit 1
    fi
else
    # Find and install all skills
    skill_count=0
    find "$temp_dir" -name "SKILL.md" -type f | while read skill_md; do
        skill_dir=$(dirname "$skill_md")
        name=$(basename "$skill_dir")
        
        # Skip if it's the root SKILL.md
        if [ "$skill_dir" = "$temp_dir" ]; then
            name=$(basename "$repo")
        fi
        
        echo "Installing skill: $name"
        ~/.gemini/skills/skill-installer/scripts/install-skill.sh \
            "$skill_dir" "$name" "GitHub"
        skill_count=$((skill_count + 1))
    done
    
    if [ $skill_count -eq 0 ]; then
        echo "No skills found in repository"
    fi
fi

# Cleanup
rm -rf "$temp_dir"
echo ""
echo "✓ Installation complete"
