#!/usr/bin/env python3
"""
🔗 SKILL DEPENDENCY GRAPH ENGINE v2.0 - Real-time Network Analysis
================================================================================

Visualizes and analyzes skill relationships, prerequisites, and execution chains.
Detects circular dependencies, missing prerequisites, and suggests optimal
execution sequences.
"""

import json
from typing import Dict, List, Set, Tuple, Optional
from collections import defaultdict, deque
from pathlib import Path
import os


class SkillDependencyGraph:
    """Advanced skill dependency analysis and visualization"""
    
    def __init__(self, skills_root: str = None):
        if skills_root is None:
            skills_root = os.path.expanduser("~/.gemini/skills")
        
        self.skills_root = Path(skills_root)
        self.skill_manager = self.skills_root / "skill-manager"
        self.protocols_dir = self.skill_manager / "protocol"
        
        # Load dependency data
        self.prerequisites = self._load_prerequisites()
        self.skill_chains = self._load_skill_chains()
        self.power_combos = self._load_power_combos()
        
        # Build graph
        self.graph = self._build_dependency_graph()
    
    # ============================================================================
    # DATA LOADING
    # ============================================================================
    
    def _load_prerequisites(self) -> Dict:
        """Load skill prerequisites"""
        prereq_file = self.protocols_dir / "skill_prerequisites.json"
        
        if not prereq_file.exists():
            return {"skill_prerequisites": {"prerequisites": {}}}
        
        with open(prereq_file) as f:
            return json.load(f)
    
    def _load_skill_chains(self) -> Dict:
        """Load skill execution chains"""
        chains_file = self.protocols_dir / "skill_chains.json"
        
        if not chains_file.exists():
            return {"skill_chains": {"chains": {}}}
        
        with open(chains_file) as f:
            return json.load(f)
    
    def _load_power_combos(self) -> Dict:
        """Load power skill combinations"""
        combos_file = self.protocols_dir / "power_combos.json"
        
        if not combos_file.exists():
            return {"power_combos": {"combos": []}}
        
        with open(combos_file) as f:
            return json.load(f)
    
    # ============================================================================
    # GRAPH CONSTRUCTION
    # ============================================================================
    
    def _build_dependency_graph(self) -> Dict:
        """Build complete dependency graph"""
        graph = defaultdict(lambda: {
            "prerequisites": [],
            "dependents": [],
            "chains": [],
            "conflicts": [],
        })
        
        # Add prerequisites
        for skill, data in self.prerequisites.get("skill_prerequisites", {}).get("prerequisites", {}).items():
            graph[skill]["prerequisites"] = data.get("required", [])
            
            # Reverse relationship
            for prereq in data.get("required", []):
                graph[prereq]["dependents"].append(skill)
        
        # Add execution chains
        for skill, chains in self.skill_chains.get("skill_chains", {}).get("chains", {}).items():
            graph[skill]["chains"] = chains
        
        return dict(graph)
    
    # ============================================================================
    # DEPENDENCY ANALYSIS
    # ============================================================================
    
    def get_prerequisites(self, skill_name: str) -> Dict:
        """Get all prerequisites for a skill"""
        if skill_name not in self.graph:
            return {"error": "Skill not found"}
        
        return {
            "skill": skill_name,
            "direct_prerequisites": self.graph[skill_name]["prerequisites"],
            "transitive_prerequisites": self._get_transitive_prerequisites(skill_name),
            "missing_prerequisites": self._check_missing_prerequisites(skill_name),
        }
    
    def _get_transitive_prerequisites(self, skill_name: str) -> List[str]:
        """Get all prerequisites recursively (transitive closure)"""
        visited = set()
        queue = deque(self.graph[skill_name]["prerequisites"])
        
        while queue:
            current = queue.popleft()
            if current not in visited:
                visited.add(current)
                if current in self.graph:
                    queue.extend(self.graph[current]["prerequisites"])
        
        return sorted(list(visited))
    
    def _check_missing_prerequisites(self, skill_name: str) -> List[str]:
        """Check which prerequisites are not installed"""
        missing = []
        
        for prereq in self.graph[skill_name]["prerequisites"]:
            skill_dir = self.skills_root / prereq
            if not skill_dir.exists():
                missing.append(prereq)
        
        return missing
    
    def get_dependents(self, skill_name: str) -> List[str]:
        """Get all skills that depend on this skill"""
        if skill_name not in self.graph:
            return []
        
        return self.graph[skill_name]["dependents"]
    
    # ============================================================================
    # CYCLE DETECTION
    # ============================================================================
    
    def detect_circular_dependencies(self) -> List[List[str]]:
        """Detect circular dependency patterns"""
        cycles = []
        visited = set()
        rec_stack = set()
        
        def dfs(node: str, path: List[str]):
            visited.add(node)
            rec_stack.add(node)
            path.append(node)
            
            for prereq in self.graph.get(node, {}).get("prerequisites", []):
                if prereq not in visited:
                    dfs(prereq, path.copy())
                elif prereq in rec_stack:
                    # Found cycle
                    cycle_start = path.index(prereq)
                    cycle = path[cycle_start:] + [prereq]
                    cycles.append(cycle)
            
            rec_stack.remove(node)
        
        for skill in self.graph:
            if skill not in visited:
                dfs(skill, [])
        
        return cycles
    
    # ============================================================================
    # EXECUTION PLANNING
    # ============================================================================
    
    def get_execution_order(self, skills: List[str]) -> Dict:
        """Calculate optimal execution order for multiple skills"""
        # Topological sort
        executed = set()
        order = []
        
        def can_execute(skill: str) -> bool:
            """Check if all prerequisites are met"""
            for prereq in self.graph.get(skill, {}).get("prerequisites", []):
                if prereq not in executed:
                    return False
            return True
        
        remaining = set(skills)
        
        while remaining:
            executable = [s for s in remaining if can_execute(s)]
            
            if not executable:
                # Circular dependency or missing prerequisites
                return {
                    "error": "Cannot determine execution order",
                    "reason": "Circular dependency or missing prerequisites",
                    "problematic_skills": list(remaining),
                }
            
            # Execute all immediately executable skills
            order.extend(sorted(executable))
            executed.update(executable)
            remaining -= set(executable)
        
        return {
            "execution_order": order,
            "parallelizable_groups": self._identify_parallelizable_groups(order),
            "total_prerequisites": sum(
                len(self.graph.get(s, {}).get("prerequisites", []))
                for s in skills
            ),
        }
    
    def _identify_parallelizable_groups(self, execution_order: List[str]) -> List[List[str]]:
        """Identify groups of skills that can execute in parallel"""
        groups = []
        current_group = []
        
        for skill in execution_order:
            # Add to group if no prerequisites within group
            can_add = all(
                prereq not in current_group
                for prereq in self.graph.get(skill, {}).get("prerequisites", [])
            )
            
            if can_add:
                current_group.append(skill)
            else:
                if current_group:
                    groups.append(current_group)
                current_group = [skill]
        
        if current_group:
            groups.append(current_group)
        
        return groups
    
    # ============================================================================
    # SKILL CHAINS & WORKFLOWS
    # ============================================================================
    
    def get_skill_chains(self, skill_name: str) -> List[Dict]:
        """Get suggested execution chains for a skill"""
        if skill_name not in self.graph:
            return []
        
        chains = self.graph[skill_name].get("chains", [])
        return chains
    
    def suggest_workflow(self, objective: str, starting_skill: str) -> List[str]:
        """Suggest a workflow sequence based on objective"""
        workflow = [starting_skill]
        current = starting_skill
        visited = {starting_skill}
        
        # Follow chains for up to 5 steps
        for _ in range(5):
            chains = self.graph.get(current, {}).get("chains", [])
            
            if not chains:
                break
            
            # Pick the next skill with highest confidence
            next_skill = None
            max_confidence = 0
            
            for chain in chains:
                if chain.get("confidence", 0) > max_confidence:
                    next_skill = chain.get("next")
                    max_confidence = chain.get("confidence", 0)
            
            if next_skill and next_skill not in visited:
                workflow.append(next_skill)
                visited.add(next_skill)
                current = next_skill
            else:
                break
        
        return workflow
    
    # ============================================================================
    # POWER COMBOS
    # ============================================================================
    
    def get_power_combos(self) -> List[Dict]:
        """Get recommended power skill combinations"""
        return self.power_combos.get("power_combos", {}).get("combos", [])
    
    def find_combos_for_skill(self, skill_name: str) -> List[Dict]:
        """Find power combos that include this skill"""
        combos = []
        
        for combo in self.power_combos.get("power_combos", {}).get("combos", []):
            if skill_name in combo.get("skills", []):
                combos.append(combo)
        
        return combos
    
    # ============================================================================
    # GRAPH VISUALIZATION
    # ============================================================================
    
    def generate_dot_graph(self, skills: Optional[List[str]] = None) -> str:
        """Generate DOT format graph for visualization"""
        lines = ["digraph skill_dependencies {"]
        lines.append('  rankdir=LR;')
        lines.append('  node [shape=box, style=rounded];')
        
        nodes = skills if skills else list(self.graph.keys())
        
        # Add nodes
        for skill in nodes:
            if skill in self.graph:
                lines.append(f'  "{skill}";')
        
        # Add edges
        for skill in nodes:
            if skill in self.graph:
                for prereq in self.graph[skill].get("prerequisites", []):
                    if prereq in nodes or prereq in self.graph:
                        lines.append(f'  "{prereq}" -> "{skill}";')
        
        lines.append("}")
        return "\n".join(lines)
    
    def generate_ascii_graph(self, root_skill: str, depth: int = 2) -> str:
        """Generate ASCII visualization of skill dependencies"""
        lines = []
        visited = set()
        
        def add_tree(skill: str, prefix: str = "", is_last: bool = True, current_depth: int = 0):
            if current_depth > depth or skill in visited:
                return
            
            visited.add(skill)
            
            # Add current node
            connector = "└── " if is_last else "├── "
            lines.append(f"{prefix}{connector}{skill}")
            
            # Recursively add prerequisites
            prerequisites = self.graph.get(skill, {}).get("prerequisites", [])
            if prerequisites and current_depth < depth:
                new_prefix = prefix + ("    " if is_last else "│   ")
                for i, prereq in enumerate(prerequisites):
                    is_last_prereq = (i == len(prerequisites) - 1)
                    add_tree(prereq, new_prefix, is_last_prereq, current_depth + 1)
        
        lines.append(f"{root_skill}")
        add_tree(root_skill)
        
        return "\n".join(lines)
    
    # ============================================================================
    # ANALYSIS & REPORTING
    # ============================================================================
    
    def generate_dependency_report(self) -> str:
        """Generate comprehensive dependency analysis report"""
        lines = []
        lines.append("=" * 80)
        lines.append("🔗 SKILL DEPENDENCY ANALYSIS REPORT")
        lines.append("=" * 80)
        
        # Graph stats
        lines.append(f"\n📊 GRAPH STATISTICS:")
        lines.append(f"   Total Skills: {len(self.graph)}")
        
        total_edges = sum(
            len(data.get("prerequisites", []))
            for data in self.graph.values()
        )
        lines.append(f"   Total Dependencies: {total_edges}")
        
        # Circular dependencies
        cycles = self.detect_circular_dependencies()
        if cycles:
            lines.append(f"\n🔄 CIRCULAR DEPENDENCIES DETECTED ({len(cycles)}):")
            for i, cycle in enumerate(cycles, 1):
                lines.append(f"   {i}. {' → '.join(cycle)}")
        else:
            lines.append(f"\n✅ No circular dependencies detected")
        
        # Most dependent skills
        lines.append(f"\n🌟 MOST DEPENDED-ON SKILLS:")
        dependent_counts = [
            (skill, len(data.get("dependents", [])))
            for skill, data in self.graph.items()
        ]
        dependent_counts.sort(key=lambda x: x[1], reverse=True)
        
        for i, (skill, count) in enumerate(dependent_counts[:5], 1):
            if count > 0:
                lines.append(f"   {i}. {skill}: used by {count} skills")
        
        # Most complex skills
        lines.append(f"\n🏗️  MOST COMPLEX SKILLS (by prerequisites):")
        complexity = [
            (skill, len(data.get("prerequisites", [])))
            for skill, data in self.graph.items()
        ]
        complexity.sort(key=lambda x: x[1], reverse=True)
        
        for i, (skill, prereq_count) in enumerate(complexity[:5], 1):
            if prereq_count > 0:
                prereqs = self.graph[skill].get("prerequisites", [])
                lines.append(f"   {i}. {skill}: requires {', '.join(prereqs)}")
        
        # Power combos
        combos = self.get_power_combos()
        if combos:
            lines.append(f"\n⚡ POWER SKILL COMBINATIONS ({len(combos)}):")
            for i, combo in enumerate(combos[:5], 1):
                skills = ", ".join(combo.get("skills", []))
                power = combo.get("power_level", "normal")
                lines.append(f"   {i}. {skills} [{power}]")
        
        lines.append("\n" + "=" * 80)
        
        return "\n".join(lines)
    
    def export_graph_data(self) -> Dict:
        """Export graph as JSON"""
        return {
            "nodes": list(self.graph.keys()),
            "edges": [
                {"from": prereq, "to": skill}
                for skill, data in self.graph.items()
                for prereq in data.get("prerequisites", [])
            ],
            "graph": self.graph,
            "cycles": self.detect_circular_dependencies(),
            "power_combos": self.get_power_combos(),
        }


# ============================================================================
# CLI & DEMO
# ============================================================================

if __name__ == "__main__":
    import sys
    
    graph = SkillDependencyGraph()
    
    if len(sys.argv) > 1:
        skill = sys.argv[1]
        
        # Show prerequisites
        print(f"\n📋 Prerequisites for {skill}:")
        prereqs = graph.get_prerequisites(skill)
        if "error" not in prereqs:
            print(f"   Direct: {prereqs['direct_prerequisites']}")
            print(f"   All: {prereqs['transitive_prerequisites']}")
        
        # Show ASCII tree
        print(f"\n🌳 Dependency Tree:")
        print(graph.generate_ascii_graph(skill))
    
    # Show report
    print(graph.generate_dependency_report())
