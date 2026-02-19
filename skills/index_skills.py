#!/usr/bin/env python3
"""
Skills Indexer and Registry System
Automatically indexes all skills and creates registration files for opencode detection
"""

import os
import json
import re
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from datetime import datetime

class SkillsRegistry:
    def __init__(self, skills_dir: str = "/Users/apple/.gemini/skills"):
        self.skills_dir = Path(skills_dir)
        self.registry_file = self.skills_dir / "registry.json"
        self.index_file = self.skills_dir / "skills_index.json"
        self.skills = {}
        
    def parse_frontmatter(self, content: str) -> Dict:
        """Parse YAML frontmatter manually"""
        if not content.startswith('---'):
            return {}
            
        try:
            yaml_end = content.find('---', 3)
            if yaml_end <= 0:
                return {}
                
            yaml_content = content[3:yaml_end].strip()
            metadata = {}
            
            # Simple YAML parser for basic key-value pairs
            for line in yaml_content.split('\n'):
                line = line.strip()
                if ':' in line and not line.startswith('#'):
                    key, value = line.split(':', 1)
                    key = key.strip()
                    value = value.strip()
                    
                    # Remove quotes if present
                    if value.startswith('"') and value.endswith('"'):
                        value = value[1:-1]
                    elif value.startswith("'") and value.endswith("'"):
                        value = value[1:-1]
                        
                    metadata[key] = value
                    
            return metadata
            
        except Exception as e:
            print(f"Error parsing frontmatter: {e}")
            return {}
    
    def load_skill_metadata(self, skill_dir: Path) -> Optional[Dict]:
        """Load skill metadata from SKILL.md file"""
        skill_file = skill_dir / "SKILL.md"
        
        if not skill_file.exists():
            return None
            
        try:
            with open(skill_file, 'r', encoding='utf-8') as f:
                content = f.read()
                
            # Extract frontmatter
            metadata = self.parse_frontmatter(content)
            
            # Extract description from content if not in frontmatter
            if 'description' not in metadata:
                # Look for first paragraph after frontmatter
                content_body = content
                if content.startswith('---'):
                    yaml_end = content.find('---', 3)
                    if yaml_end > 0:
                        content_body = content[yaml_end + 3:].strip()
                        
                lines = content_body.split('\n')
                for line in lines:
                    line = line.strip()
                    if line and not line.startswith('#') and not line.startswith('>'):
                        metadata['description'] = line[:200] + ('...' if len(line) > 200 else '')
                        break
                        
            metadata['skill_path'] = str(skill_dir.relative_to(self.skills_dir))
            metadata['skill_name'] = skill_dir.name
            metadata['file_size'] = skill_file.stat().st_size
            metadata['last_modified'] = skill_file.stat().st_mtime
            
            # Check for additional files
            additional_files = []
            for file_path in skill_dir.rglob('*'):
                if file_path.is_file() and file_path.name != 'SKILL.md':
                    additional_files.append(str(file_path.relative_to(skill_dir)))
            metadata['additional_files'] = additional_files
            
            return metadata
                    
        except Exception as e:
            print(f"Error reading {skill_file}: {e}")
            
        return None
        
    def scan_skills(self) -> Dict[str, Dict]:
        """Scan all skill directories and load metadata"""
        print(f"Scanning skills directory: {self.skills_dir}")
        
        skills_found = {}
        
        for item in self.skills_dir.iterdir():
            if item.is_dir() and not item.name.startswith('.'):
                skill_name = item.name
                metadata = self.load_skill_metadata(item)
                
                if metadata:
                    skills_found[skill_name] = metadata
                    print(f"✓ Loaded skill: {skill_name}")
                else:
                    print(f"✗ No valid SKILL.md found in: {skill_name}")
                    
        return skills_found
        
    def create_categorization(self, skills: Dict[str, Dict]) -> Dict[str, List[str]]:
        """Categorize skills based on descriptions and names"""
        categories = {
            'Development & Engineering': [],
            'Design & Creative': [],
            'Security & Testing': [],
            'Cloud & Infrastructure': [],
            'Documentation & Office': [],
            'AI & Agents': [],
            'WordPress & CMS': [],
            'Marketing & Growth': [],
            'Integrations & APIs': [],
            'Planning & Workflow': [],
            'System & Tools': [],
            'Specialized Applications': [],
            'Other': []
        }
        
        keywords = {
            'Development & Engineering': ['development', 'coding', 'programming', 'javascript', 'typescript', 'python', 'react', 'node', 'api', 'backend', 'frontend', 'testing', 'debug', 'code'],
            'Design & Creative': ['design', 'ui', 'ux', 'creative', 'art', 'visual', 'interface', 'theme', 'color', 'typography', 'portfolio'],
            'Security & Testing': ['security', 'pentest', 'testing', 'vulnerability', 'attack', 'exploit', 'burp', 'metasploit', 'hack', 'audit'],
            'Cloud & Infrastructure': ['aws', 'cloud', 'docker', 'kubernetes', 'deployment', 'infrastructure', 'server', 'devops'],
            'Documentation & Office': ['docx', 'xlsx', 'pptx', 'pdf', 'document', 'office', 'word', 'excel', 'powerpoint'],
            'AI & Agents': ['ai', 'agent', 'llm', 'prompt', 'autonomous', 'langchain', 'crewai', 'rag'],
            'WordPress & CMS': ['wordpress', 'wp', 'plugin', 'theme', 'gutenberg', 'cms'],
            'Marketing & Growth': ['marketing', 'seo', 'cro', 'conversion', 'growth', 'analytics', 'ads', 'content'],
            'Integrations & APIs': ['integration', 'api', 'stripe', 'twilio', 'slack', 'discord', 'shopify', 'firebase'],
            'Planning & Workflow': ['planning', 'workflow', 'automation', 'task', 'project', 'management'],
            'System & Tools': ['bash', 'linux', 'system', 'tools', 'utility', 'cli', 'script'],
            'Specialized Applications': ['game', 'browser', 'extension', 'mobile', 'desktop', 'ocr']
        }
        
        for skill_name, metadata in skills.items():
            description = metadata.get('description', '').lower()
            name = skill_name.lower()
            
            # Find best category based on keyword matches
            best_category = 'Other'
            best_score = 0
            
            for category, kw_list in keywords.items():
                score = sum(1 for kw in kw_list if kw in description or kw in name)
                if score > best_score:
                    best_score = score
                    best_category = category
                    
            categories[best_category].append(skill_name)
            
        return categories
        
    def generate_registry(self) -> Dict:
        """Generate comprehensive skills registry"""
        skills = self.scan_skills()
        categories = self.create_categorization(skills)
        
        registry = {
            'version': '1.0.0',
            'generated_at': datetime.now().isoformat(),
            'total_skills': len(skills),
            'skills_dir': str(self.skills_dir),
            'categories': categories,
            'skills': skills,
            'statistics': {
                'categories_count': len(categories),
                'skills_with_additional_files': sum(1 for s in skills.values() if s.get('additional_files')),
                'total_additional_files': sum(len(s.get('additional_files', [])) for s in skills.values())
            }
        }
        
        return registry
        
    def save_registry(self, registry: Dict):
        """Save registry to JSON file"""
        # Save main registry
        with open(self.registry_file, 'w', encoding='utf-8') as f:
            json.dump(registry, f, indent=2, ensure_ascii=False)
            
        # Create simplified index for quick loading
        index = {
            'skills': list(registry['skills'].keys()),
            'categories': registry['categories'],
            'total': registry['total_skills'],
            'updated': registry['generated_at']
        }
        
        with open(self.index_file, 'w', encoding='utf-8') as f:
            json.dump(index, f, indent=2)
            
        print(f"Registry saved to: {self.registry_file}")
        print(f"Index saved to: {self.index_file}")
        
    def validate_skills(self) -> List[Tuple[str, str]]:
        """Validate skills and return list of issues"""
        issues = []
        
        for skill_name, metadata in self.skills.items():
            # Check required fields
            if 'name' not in metadata:
                issues.append((skill_name, "Missing 'name' in metadata"))
                
            if 'description' not in metadata:
                issues.append((skill_name, "Missing 'description' in metadata"))
                
            # Check for allowed-tools
            if 'allowed-tools' not in metadata:
                issues.append((skill_name, "Missing 'allowed-tools' in metadata"))
                
        return issues
        
    def install_for_opencode(self):
        """Create symbolic links and configuration for opencode"""
        # Create opencode config directory if it doesn't exist
        opencode_config = Path.home() / '.opencode'
        opencode_config.mkdir(exist_ok=True)
        
        # Create symlink to skills directory
        skills_link = opencode_config / 'skills'
        if not skills_link.exists():
            skills_link.symlink_to(self.skills_dir)
            print(f"Created symlink: {skills_link} -> {self.skills_dir}")
            
        # Create opencode skills config
        config = {
            'skills_directory': str(self.skills_dir),
            'registry_file': str(self.registry_file),
            'index_file': str(self.index_file),
            'auto_reload': True,
            'version': '1.0.0'
        }
        
        config_file = opencode_config / 'skills_config.json'
        with open(config_file, 'w', encoding='utf-8') as f:
            json.dump(config, f, indent=2)
            
        print(f"OpenCode config created: {config_file}")

def main():
    """Main execution function"""
    registry = SkillsRegistry()
    
    print("=== Skills Registry and Indexing System ===")
    print()
    
    # Generate registry
    print("Generating skills registry...")
    reg_data = registry.generate_registry()
    
    # Save registry
    registry.save_registry(reg_data)
    
    # Validate skills
    print("\nValidating skills...")
    issues = registry.validate_skills()
    if issues:
        print(f"Found {len(issues)} validation issues:")
        for skill, issue in issues[:5]:  # Show first 5
            print(f"  - {skill}: {issue}")
        if len(issues) > 5:
            print(f"  ... and {len(issues) - 5} more")
    else:
        print("✓ All skills validated successfully")
        
    # Install for opencode
    print("\nInstalling for OpenCode...")
    registry.install_for_opencode()
    
    # Show summary
    print(f"\n=== Summary ===")
    print(f"Total skills indexed: {reg_data['total_skills']}")
    print(f"Categories: {len(reg_data['categories'])}")
    print(f"Registry file: {registry.registry_file}")
    print(f"Index file: {registry.index_file}")
    
    print("\n=== Skills by Category ===")
    for category, skill_list in reg_data['categories'].items():
        if skill_list:
            print(f"{category}: {len(skill_list)} skills")
            
    print(f"\n✓ Skills indexing complete!")

if __name__ == "__main__":
    main()