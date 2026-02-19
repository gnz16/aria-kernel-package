#!/usr/bin/env python3
"""
Skills Management System
Provides utilities to manage, install, and maintain the skills library
"""

import os
import json
import shutil
import subprocess
from pathlib import Path
from typing import Dict, List, Optional
from datetime import datetime

class SkillsManager:
    def __init__(self, skills_dir: str = "/Users/apple/.gemini/skills"):
        self.skills_dir = Path(skills_dir)
        self.registry_file = self.skills_dir / "registry.json"
        self.index_file = self.skills_dir / "skills_index.json"
        self.opencode_config = Path.home() / ".opencode"
        
    def load_registry(self) -> Dict:
        """Load the skills registry"""
        if self.registry_file.exists():
            with open(self.registry_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        return {}
        
    def load_index(self) -> Dict:
        """Load the skills index"""
        if self.index_file.exists():
            with open(self.index_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        return {}
        
    def list_skills(self, category: Optional[str] = None, search: Optional[str] = None) -> List[Dict]:
        """List skills with optional category and search filters"""
        registry = self.load_registry()
        skills = []
        
        for skill_name, skill_data in registry.get('skills', {}).items():
            # Filter by category
            if category:
                skill_categories = []
                for cat, skill_list in registry.get('categories', {}).items():
                    if skill_name in skill_list:
                        skill_categories.append(cat)
                if category not in skill_categories:
                    continue
                    
            # Filter by search term
            if search:
                search_lower = search.lower()
                searchable_text = f"{skill_name} {skill_data.get('description', '')} {skill_data.get('name', '')}".lower()
                if search_lower not in searchable_text:
                    continue
                    
            # Get skill category
            skill_category = "Other"
            for cat, skill_list in registry.get('categories', {}).items():
                if skill_name in skill_list:
                    skill_category = cat
                    break
                    
            skills.append({
                'name': skill_name,
                'description': skill_data.get('description', 'No description'),
                'category': skill_category,
                'path': skill_data.get('skill_path', ''),
                'tools': skill_data.get('allowed-tools', ''),
                'files': len(skill_data.get('additional_files', []))
            })
            
        return sorted(skills, key=lambda x: x['name'])
        
    def install_skill(self, skill_name: str) -> bool:
        """Install a specific skill for opencode use"""
        registry = self.load_registry()
        skills = registry.get('skills', {})
        
        if skill_name not in skills:
            print(f"Skill '{skill_name}' not found in registry")
            return False
            
        skill_data = skills[skill_name]
        skill_path = self.skills_dir / skill_data['skill_path']
        
        # Ensure opencode config directory exists
        self.opencode_config.mkdir(exist_ok=True)
        
        # Create active skills directory
        active_skills_dir = self.opencode_config / 'active_skills'
        active_skills_dir.mkdir(exist_ok=True)
        
        # Create symlink or copy
        active_skill_path = active_skills_dir / skill_name
        if active_skill_path.exists():
            active_skill_path.unlink()
            
        try:
            active_skill_path.symlink_to(skill_path)
            print(f"✓ Installed skill: {skill_name}")
            return True
        except Exception as e:
            print(f"✗ Failed to install {skill_name}: {e}")
            return False
            
    def uninstall_skill(self, skill_name: str) -> bool:
        """Uninstall a specific skill"""
        active_skill_path = self.opencode_config / 'active_skills' / skill_name
        
        if active_skill_path.exists():
            try:
                active_skill_path.unlink()
                print(f"✓ Uninstalled skill: {skill_name}")
                return True
            except Exception as e:
                print(f"✗ Failed to uninstall {skill_name}: {e}")
                return False
        else:
            print(f"Skill '{skill_name}' not installed")
            return False
            
    def install_category(self, category: str) -> int:
        """Install all skills in a category"""
        registry = self.load_registry()
        categories = registry.get('categories', {})
        
        if category not in categories:
            print(f"Category '{category}' not found")
            return 0
            
        skill_list = categories[category]
        installed_count = 0
        
        print(f"Installing {len(skill_list)} skills from category: {category}")
        
        for skill_name in skill_list:
            if self.install_skill(skill_name):
                installed_count += 1
                
        print(f"✓ Installed {installed_count}/{len(skill_list)} skills")
        return installed_count
        
    def update_index(self) -> bool:
        """Update the skills index by running the indexer"""
        indexer_script = self.skills_dir / "index_skills.py"
        
        if not indexer_script.exists():
            print("Indexer script not found")
            return False
            
        try:
            result = subprocess.run(['python3', str(indexer_script)], 
                                  capture_output=True, text=True, cwd=str(self.skills_dir))
            if result.returncode == 0:
                print("✓ Skills index updated successfully")
                return True
            else:
                print(f"✗ Indexer failed: {result.stderr}")
                return False
        except Exception as e:
            print(f"✗ Failed to run indexer: {e}")
            return False
            
    def get_skill_info(self, skill_name: str) -> Optional[Dict]:
        """Get detailed information about a specific skill"""
        registry = self.load_registry()
        skills = registry.get('skills', {})
        
        if skill_name not in skills:
            return None
            
        skill_data = skills[skill_name]
        
        # Get skill category
        skill_category = "Other"
        for cat, skill_list in registry.get('categories', {}).items():
            if skill_name in skill_list:
                skill_category = cat
                break
                
        # Read the full skill file
        skill_file = self.skills_dir / skill_data['skill_path'] / 'SKILL.md'
        full_content = ""
        
        if skill_file.exists():
            with open(skill_file, 'r', encoding='utf-8') as f:
                full_content = f.read()
                
        return {
            'name': skill_name,
            'description': skill_data.get('description', 'No description'),
            'category': skill_category,
            'path': skill_data.get('skill_path', ''),
            'tools': skill_data.get('allowed-tools', ''),
            'files': skill_data.get('additional_files', []),
            'file_size': skill_data.get('file_size', 0),
            'last_modified': skill_data.get('last_modified', 0),
            'full_content': full_content
        }
        
    def create_skill_backup(self, backup_path: Optional[str] = None) -> str:
        """Create a backup of the skills directory"""
        if not backup_path:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            backup_path = f"/Users/apple/.gemini/skills_backup_{timestamp}"
            
        backup_dir = Path(backup_path)
        
        try:
            shutil.copytree(self.skills_dir, backup_dir)
            print(f"✓ Skills backed up to: {backup_dir}")
            return str(backup_dir)
        except Exception as e:
            print(f"✗ Backup failed: {e}")
            return ""

def main():
    """Command-line interface for skills management"""
    import sys
    import argparse
    
    parser = argparse.ArgumentParser(description='Skills Management System')
    parser.add_argument('command', choices=['list', 'install', 'uninstall', 'update', 'info', 'backup'])
    parser.add_argument('--skill', help='Skill name')
    parser.add_argument('--category', help='Category name')
    parser.add_argument('--search', help='Search term')
    parser.add_argument('--all', action='store_true', help='Install all skills in category')
    
    args = parser.parse_args()
    
    manager = SkillsManager()
    
    if args.command == 'list':
        skills = manager.list_skills(category=args.category, search=args.search)
        
        if not skills:
            print("No skills found")
            return
            
        print(f"\n=== Found {len(skills)} skills ===\n")
        
        for skill in skills:
            print(f"📦 {skill['name']}")
            print(f"   Category: {skill['category']}")
            print(f"   Description: {skill['description']}")
            print(f"   Tools: {skill['tools']}")
            print(f"   Files: {skill['files']}")
            print()
            
    elif args.command == 'install':
        if args.category:
            manager.install_category(args.category)
        elif args.skill:
            manager.install_skill(args.skill)
        else:
            print("Please specify --skill or --category")
            
    elif args.command == 'uninstall':
        if args.skill:
            manager.uninstall_skill(args.skill)
        else:
            print("Please specify --skill")
            
    elif args.command == 'update':
        manager.update_index()
        
    elif args.command == 'info':
        if args.skill:
            info = manager.get_skill_info(args.skill)
            if info:
                print(f"\n=== Skill: {info['name']} ===\n")
                print(f"Category: {info['category']}")
                print(f"Description: {info['description']}")
                print(f"Allowed Tools: {info['tools']}")
                print(f"Additional Files: {len(info['files'])}")
                print(f"Path: {info['path']}")
                print(f"\n--- Full Content ---\n")
                print(info['full_content'])
            else:
                print(f"Skill '{args.skill}' not found")
        else:
            print("Please specify --skill")
            
    elif args.command == 'backup':
        manager.create_skill_backup()

if __name__ == "__main__":
    main()