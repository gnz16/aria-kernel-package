#!/bin/bash

# Skills System Setup for OpenCode
# This script sets up the skills system to work with opencode

echo "=== Skills System Setup for OpenCode ==="

SKILLS_DIR="/Users/apple/.gemini/skills"
OPENCODE_DIR="/Users/apple/.opencode"

echo "1. Verifying skills directory..."
if [ ! -d "$SKILLS_DIR" ]; then
    echo "❌ Skills directory not found: $SKILLS_DIR"
    exit 1
fi
echo "✓ Skills directory found"

echo "2. Creating opencode configuration..."
mkdir -p "$OPENCODE_DIR"

echo "3. Setting up skills symlink..."
if [ -L "$OPENCODE_DIR/skills" ]; then
    echo "✓ Skills symlink exists"
else
    ln -sf "$SKILLS_DIR" "$OPENCODE_DIR/skills"
    echo "✓ Created skills symlink"
fi

echo "4. Running skills indexer..."
cd "$SKILLS_DIR"
python3 index_skills.py
if [ $? -eq 0 ]; then
    echo "✓ Skills indexed successfully"
else
    echo "❌ Skills indexing failed"
    exit 1
fi

echo "5. Testing skills bridge..."
python3 "$OPENCODE_DIR/skills_bridge.py" list | head -5
if [ $? -eq 0 ]; then
    echo "✓ Skills bridge working"
else
    echo "❌ Skills bridge failed"
    exit 1
fi

echo "6. Creating skills environment file..."
cat > "$OPENCODE_DIR/skills_env.sh" << 'EOF'
#!/bin/bash
# Skills environment variables for opencode
export SKILLS_DIR="/Users/apple/.gemini/skills"
export SKILLS_REGISTRY="$SKILLS_DIR/registry.json"
export SKILLS_INDEX="$SKILLS_DIR/skills_index.json"
export SKILLS_BRIDGE="/Users/apple/.opencode/skills_bridge.py"
EOF
chmod +x "$OPENCODE_DIR/skills_env.sh"

echo "7. Creating skill detection helper..."
cat > "$OPENCODE_DIR/detect_skills.py" << 'EOF'
#!/usr/bin/env python3
"""
Skill detection helper for opencode
Returns available skills in format expected by opencode
"""

import json
import sys
from pathlib import Path

def get_available_skills():
    """Get list of available skills"""
    skills_file = Path.home() / ".opencode" / "skills" / "skills_index.json"
    
    if not skills_file.exists():
        return []
    
    try:
        with open(skills_file, 'r') as f:
            data = json.load(f)
        return data.get('skills', [])
    except:
        return []

def get_skill_content(skill_name):
    """Get skill content"""
    skills_dir = Path.home() / ".opencode" / "skills"
    registry_file = skills_dir / "registry.json"
    
    if not registry_file.exists():
        return None
    
    try:
        with open(registry_file, 'r') as f:
            registry = json.load(f)
        
        skills = registry.get('skills', {})
        if skill_name not in skills:
            return None
            
        skill_path = skills_dir / skills[skill_name].get('skill_path', '') / 'SKILL.md'
        
        if skill_path.exists():
            with open(skill_path, 'r', encoding='utf-8') as f:
                return f.read()
    except:
        pass
    
    return None

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--list":
        skills = get_available_skills()
        for skill in skills:
            print(skill)
    else:
        skills = get_available_skills()
        print(f"Available skills: {len(skills)}")
        for skill in sorted(skills)[:10]:
            print(f"  - {skill}")
        if len(skills) > 10:
            print(f"  ... and {len(skills) - 10} more")
EOF
chmod +x "$OPENCODE_DIR/detect_skills.py"

echo "8. Testing skill detection..."
python3 "$OPENCODE_DIR/detect_skills.py"
if [ $? -eq 0 ]; then
    echo "✓ Skill detection working"
else
    echo "❌ Skill detection failed"
    exit 1
fi

echo ""
echo "=== Setup Complete ==="
echo "Skills system is ready for use with opencode!"
echo ""
echo "Summary:"
echo "- Total skills indexed: $(python3 -c "import json; print(len(json.load(open('/Users/apple/.gemini/skills/skills_index.json')).get('skills', [])))")"
echo "- Registry: $SKILLS_DIR/registry.json"
echo "- Index: $SKILLS_DIR/skills_index.json"
echo "- Bridge: $OPENCODE_DIR/skills_bridge.py"
echo "- Detection: $OPENCODE_DIR/detect_skills.py"
echo ""
echo "To test skills detection:"
echo "  python3 $OPENCODE_DIR/detect_skills.py --list"