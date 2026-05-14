# ARIA 8.1 - Hermes Agent Harness Suggestions

Based on the review of the ARIA Kernel Package (specifically `skills/skills_manager.py`, `BRIDGE.md` and `ARIA_KERNEL.md`), here are targeted suggestions for better integration into the **Hermes AI Agent Harness**.

The goal is to transition from a static, bash/symlink-driven approach to a dynamic, programmatic, and context-aware system suitable for a modern AI framework like Hermes.

## 1. Dynamic Skill Path Configuration
**Current Issue:** `skills/skills_manager.py` hardcodes the skills path to `/Users/apple/.gemini/skills`. This severely limits portability and makes it difficult to deploy the harness across different machines or CI/CD environments.
**Suggestion:**
Refactor `skills_manager.py` to use environment variables with fallback defaults.
```python
import os
from pathlib import Path

class SkillsManager:
    def __init__(self, skills_dir: str = None):
        # 1. Check passed arg
        # 2. Check environment variable
        # 3. Fallback to default
        env_dir = os.getenv("ARIA_SKILLS_PATH")
        default_dir = Path.home() / ".gemini" / "skills"

        self.skills_dir = Path(skills_dir or env_dir or default_dir)
```
*Why:* This allows Hermes to point `ARIA_SKILLS_PATH` directly to the `skills/` folder within the cloned repository, completely removing the reliance on a specific user's home directory.

## 2. MCP (Model Context Protocol) Skill Server
**Current Architecture:** The codebase uses `scripts/aria-bridge/mcp-server/` primarily for cross-agent task assignment (Assign, Collect, Sync).
**Suggestion:**
Implement an MCP tool specifically for fetching and querying **Skills**.
Add tools like:
- `list_skills(category)`: Returns the available skills.
- `get_skill_context(skill_name)`: Reads the `SKILL.md` and returns it as plain text directly to the agent's context window.
*Why:* Instead of Hermes relying on bash scripts (`td-bridge.sh` or `opencode` symlinks) to "install" a skill, Hermes can dynamically invoke the MCP tool mid-conversation to inject the skill instructions (e.g., `react-best-practices`) directly into its context window.

## 3. Semantic Vector Search for Auto-Loading Skills
**Current Issue:** Skills are retrieved via keyword search (`search_lower not in searchable_text`). With 290+ skills, agents might not know the exact skill name to search for.
**Suggestion:**
Generate lightweight vector embeddings for all skills based on their `description` and `SKILL.md` content.
- Use a lightweight local vector DB (like `chromadb` or FAISS).
- When Hermes receives a user prompt (e.g., "build a user auth flow in Next.js"), the harness automatically embeds the prompt, searches the skill vectors, and transparently loads the top 3 relevant skills (`nextjs-best-practices`, `clerk-auth`, `database-design`) into Hermes's hidden prompt.
*Why:* This creates an autonomous context-injection pipeline. Hermes doesn't need to manually ask for a skill; the harness intelligently provides it.

## 4. Skill Dependency Resolution
**Current Issue:** Skills exist in isolation. If an agent loads `nextjs-supabase-auth`, it might also implicitly need the `react-patterns` skill.
**Suggestion:**
Update `registry.json` and `skills_manager.py` to support `dependencies`.
```json
"nextjs-supabase-auth": {
  "description": "...",
  "dependencies": ["react-best-practices", "backend-patterns"]
}
```
When `get_skill_info` or the MCP server fetches `nextjs-supabase-auth`, it recursively fetches and bundles the dependencies.
*Why:* Guarantees that Hermes has the foundational context needed to execute complex, multi-layered tasks without missing core architectural patterns.

## 5. In-Memory Context Injection vs Symlinks
**Current Issue:** `install_skill` relies on creating symlinks (`active_skill_path.symlink_to(skill_path)`).
**Suggestion:**
Hermes should act completely in-memory. Instead of symlinking files, the harness should maintain an `active_skills` array in memory. When generating the prompt for the LLM, the harness loops through `active_skills` and concatenates the `SKILL.md` files into a `<system_instructions>` block.
*Why:* Eliminates disk I/O bottlenecks and permission issues. It also allows for temporary, per-turn skill loading (e.g., loading `debugging-patterns` for one turn, then discarding it) which saves tokens.
