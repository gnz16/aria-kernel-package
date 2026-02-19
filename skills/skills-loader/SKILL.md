---
name: skills-loader
description: Dynamic skills loader that provides access to the entire skills library registry. Loads and manages all indexed skills dynamically.
allowed-tools: Read, Bash
---

# Skills Loader

This skill provides dynamic access to the entire skills library through the registry system.

## Usage

This skill automatically loads skills from the registry and makes them available. When you need a specific skill, the system will:

1. Search the skills registry
2. Load the appropriate skill content  
3. Apply the skill instructions
4. Execute the task

## Available Skills Categories

- Development & Engineering (71 skills)
- Design & Creative (43 skills) 
- Security & Testing (25 skills)
- Cloud & Infrastructure (17 skills)
- AI & Agents (34 skills)
- WordPress & CMS (9 skills)
- Marketing & Growth (16 skills)
- Integrations & APIs (6 skills)
- Planning & Workflow (10 skills)
- System & Tools (5 skills)
- Documentation & Office (6 skills)
- Specialized Applications (1 skill)
- Other (8 skills)

## Loading Skills

To use a specific skill, simply mention the skill name or describe what you need. The system will automatically locate and load the appropriate skill from the registry.

Examples:
- "Use the app-builder skill to create a React application"
- "Apply the lint-and-validate skill to check this code"
- "Use the wordpress-penetration-testing skill for security testing"

## Skill Management

The skills library is maintained through:
- Registry: `/Users/apple/.gemini/skills/registry.json`
- Index: `/Users/apple/.gemini/skills/skills_index.json` 
- Manager: `/Users/apple/.gemini/skills/skills_manager.py`

To update the skills library:
```bash
python3 /Users/apple/.gemini/skills/index_skills.py
```

To manage skills:
```bash
python3 /Users/apple/.gemini/skills/skills_manager.py list
python3 /Users/apple/.gemini/skills/skills_manager.py info --skill <skill_name>
```