#!/usr/bin/env python3
"""
Fix skill names to match directory names for OpenCode compatibility.
OpenCode requires the 'name' field in SKILL.md to exactly match the directory name.
"""

import os
import re
from pathlib import Path

SKILLS_DIR = Path.home() / ".gemini" / "skills"

def fix_skill_name(skill_dir: Path) -> bool:
    """Fix the name field in SKILL.md to match directory name."""
    skill_file = skill_dir / "SKILL.md"
    if not skill_file.exists():
        return False
    
    expected_name = skill_dir.name
    
    try:
        with open(skill_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Check if it has YAML frontmatter
        if not content.startswith('---'):
            return False
        
        # Find the end of frontmatter
        end_idx = content.find('---', 3)
        if end_idx == -1:
            return False
        
        frontmatter = content[3:end_idx]
        body = content[end_idx:]
        
        # Check current name
        name_match = re.search(r'^name:\s*(.+)$', frontmatter, re.MULTILINE)
        if not name_match:
            return False
        
        current_name = name_match.group(1).strip()
        
        # Skip if already correct
        if current_name == expected_name:
            return False
        
        # Fix the name
        new_frontmatter = re.sub(
            r'^name:\s*.+$',
            f'name: {expected_name}',
            frontmatter,
            flags=re.MULTILINE
        )
        
        new_content = '---' + new_frontmatter + body
        
        with open(skill_file, 'w', encoding='utf-8') as f:
            f.write(new_content)
        
        print(f"Fixed: {expected_name} (was: {current_name})")
        return True
        
    except Exception as e:
        print(f"Error processing {skill_dir.name}: {e}")
        return False

def main():
    print("=== Fixing Skill Names for OpenCode Compatibility ===\n")
    
    fixed_count = 0
    total_count = 0
    
    for skill_dir in sorted(SKILLS_DIR.iterdir()):
        if skill_dir.is_dir() and not skill_dir.name.startswith('.'):
            total_count += 1
            if fix_skill_name(skill_dir):
                fixed_count += 1
    
    print(f"\n=== Summary ===")
    print(f"Total skills checked: {total_count}")
    print(f"Skills fixed: {fixed_count}")
    print(f"Skills already correct: {total_count - fixed_count}")

if __name__ == "__main__":
    main()
