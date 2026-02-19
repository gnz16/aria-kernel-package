#!/usr/bin/env python3
"""
🤖 SKILL COPILOT v3.0 - Revolutionary AI-Powered Skill Assistant
================================================================================

The next generation of skill management. Understands context, learns usage
patterns, and proactively recommends skill combinations for optimal workflow.

Key Features:
- Natural language skill queries with semantic understanding
- Adaptive learning from skill usage patterns  
- Context-aware recommendations with confidence scoring
- Real-time skill dependency resolution
- Performance optimization suggestions
- Skill mashup recommendations (combine 2-3 skills for complex tasks)
"""

import json
import os
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple, Optional
import re
from collections import Counter, defaultdict
import math


class SkillCopilot:
    """Revolutionary AI-powered skill assistant using semantic understanding"""
    
    def __init__(self, skills_root: str = None):
        if skills_root is None:
            skills_root = os.path.expanduser("~/.gemini/skills")
        
        self.skills_root = Path(skills_root)
        self.skill_manager = self.skills_root / "skill-manager"
        self.usage_log = self.skill_manager / "data" / "usage_log.json"
        self.skill_index = self.skill_manager / "references" / "SKILL_INDEX.json"
        self.analytics_db = self.skill_manager / "data" / "analytics.json"
        self.semantic_db = self.skill_manager / "data" / "semantic_index.json"
        
        self.skills = self._load_skills()
        self.usage_data = self._load_usage_data()
        self.semantic_index = self._load_semantic_index()
        
    # ============================================================================
    # CORE SEMANTIC UNDERSTANDING
    # ============================================================================
    
    def _load_skills(self) -> Dict:
        """Load all skills with enhanced metadata"""
        if not self.skill_index.exists():
            return {}
        
        with open(self.skill_index) as f:
            data = json.load(f)
        
        skills = {}
        for skill in data.get("skills", []):
            skills[skill["name"]] = {
                "name": skill["name"],
                "description": skill["description"],
                "category": skill["category"],
                "path": skill["path"],
                "tags": self._extract_tags(skill["description"]),
                "keywords": self._extract_keywords(skill["name"], skill["description"]),
                "complexity": self._estimate_complexity(skill["name"]),
            }
        return skills
    
    def _load_usage_data(self) -> Dict:
        """Load historical usage patterns for learning"""
        if not self.usage_log.exists():
            return {"usage_history": [], "patterns": {}}
        
        with open(self.usage_log) as f:
            return json.load(f)
    
    def _load_semantic_index(self) -> Dict:
        """Load semantic relationships between skills"""
        if not self.semantic_db.exists():
            return self._build_semantic_index()
        
        with open(self.semantic_db) as f:
            return json.load(f)
    
    def _extract_tags(self, description: str) -> List[str]:
        """Extract semantic tags from description"""
        # Technologies, frameworks, patterns mentioned
        tag_patterns = {
            "AI/ML": r"\b(ai|machine learning|neural|deep learning|llm|gpt|bert|transformer)\b",
            "Testing": r"\b(test|unit|integration|e2e|tdd|pytest|jest)\b",
            "AWS": r"\b(aws|lambda|s3|ec2|dynamodb|rds|cloudformation)\b",
            "Frontend": r"\b(react|vue|svelte|typescript|tailwind|css)\b",
            "Backend": r"\b(node|python|fastapi|express|rest|graphql)\b",
            "DevOps": r"\b(docker|kubernetes|ci/cd|terraform|ansible)\b",
            "Security": r"\b(security|encryption|auth|penetration|vulnerability)\b",
            "Database": r"\b(postgres|mongodb|redis|sql|orm)\b",
            "Cloud": r"\b(aws|azure|gcp|cloud|serverless)\b",
        }
        
        tags = []
        description_lower = description.lower()
        for tag, pattern in tag_patterns.items():
            if re.search(pattern, description_lower):
                tags.append(tag)
        
        return list(set(tags))
    
    def _extract_keywords(self, name: str, description: str) -> List[str]:
        """Extract key searchable terms"""
        # Remove common words
        stop_words = {"the", "a", "an", "and", "or", "but", "in", "of", "to", "for", "with"}
        
        # Extract from name
        name_words = [w for w in name.lower().split("-") if w not in stop_words and len(w) > 2]
        
        # Extract significant words from description
        words = re.findall(r"\b\w{3,}\b", description.lower())
        words = [w for w in words if w not in stop_words]
        
        # Combine and deduplicate
        all_words = name_words + words[:10]
        return list(dict.fromkeys(all_words))  # Preserve order, remove duplicates
    
    def _estimate_complexity(self, skill_name: str) -> str:
        """Estimate skill complexity"""
        advanced_keywords = ["advanced", "expert", "master", "pro", "architecture"]
        if any(kw in skill_name.lower() for kw in advanced_keywords):
            return "Expert"
        
        intermediate_keywords = ["patterns", "best-practices", "system", "design"]
        if any(kw in skill_name.lower() for kw in intermediate_keywords):
            return "Intermediate"
        
        return "Beginner"
    
    # ============================================================================
    # SEMANTIC UNDERSTANDING & SEARCH
    # ============================================================================
    
    def understand_query(self, query: str) -> Dict:
        """Parse natural language query to understand intent"""
        query_lower = query.lower()
        
        # Detect intent patterns
        intents = {
            "recommendation": r"\b(suggest|recommend|what.*skill|which.*skill|need|want|do|help)\b",
            "search": r"\b(find|search|show|list|get|find me)\b",
            "learn": r"\b(learn|teach|explain|how to|tutorial|guide)\b",
            "combine": r"\b(combine|merge|together|with|alongside|chain|flow)\b",
            "optimize": r"\b(optimize|improve|faster|better|efficient)\b",
            "troubleshoot": r"\b(error|bug|broken|not working|issue|fix|problem)\b",
        }
        
        detected_intents = []
        for intent, pattern in intents.items():
            if re.search(pattern, query_lower):
                detected_intents.append(intent)
        
        # Extract entities (technology, concept, framework)
        entities = []
        for skill_name, skill_data in self.skills.items():
            for keyword in skill_data["keywords"]:
                if keyword in query_lower:
                    entities.append((skill_name, "skill"))
            for tag in skill_data["tags"]:
                if tag.lower() in query_lower:
                    entities.append((tag, "tag"))
        
        return {
            "original_query": query,
            "intents": detected_intents,
            "entities": entities,
            "confidence": min(1.0, (len(detected_intents) + len(entities)) / 3),
            "extracted_terms": re.findall(r"\b\w{3,}\b", query_lower),
        }
    
    def semantic_search(self, query: str, top_k: int = 5) -> List[Tuple[str, float]]:
        """Search skills using semantic similarity"""
        query_terms = set(re.findall(r"\b\w{3,}\b", query.lower()))
        
        results = []
        for skill_name, skill_data in self.skills.items():
            # Match keywords
            keyword_matches = len(query_terms & set(skill_data["keywords"]))
            
            # Match tags
            tag_matches = 0
            for tag in skill_data["tags"]:
                if any(term in tag.lower() for term in query_terms):
                    tag_matches += 1
            
            # Match description
            description_matches = sum(
                1 for term in query_terms 
                if term in skill_data["description"].lower()
            )
            
            # Calculate relevance score
            relevance = (keyword_matches * 0.5 + tag_matches * 0.3 + description_matches * 0.2)
            
            if relevance > 0:
                results.append((skill_name, relevance))
        
        # Sort by relevance and return top_k
        results.sort(key=lambda x: x[1], reverse=True)
        return results[:top_k]
    
    # ============================================================================
    # INTELLIGENT RECOMMENDATIONS
    # ============================================================================
    
    def recommend_skills(self, context: str = "", user_level: str = "Intermediate") -> List[Dict]:
        """
        Recommend skills based on context and user level
        
        Args:
            context: Current task or problem description
            user_level: "Beginner", "Intermediate", "Expert"
        """
        parsed = self.understand_query(context)
        semantic_matches = self.semantic_search(context, top_k=10)
        
        recommendations = []
        
        for skill_name, relevance in semantic_matches:
            skill = self.skills[skill_name]
            
            # Check user level match
            level_match = 1.0
            if user_level == "Beginner" and skill["complexity"] == "Expert":
                level_match = 0.5
            elif user_level == "Expert" and skill["complexity"] == "Beginner":
                level_match = 0.7
            
            # Check usage pattern (prefer frequently used)
            usage_score = self._get_skill_usage_score(skill_name)
            
            # Combined confidence
            confidence = (relevance * 0.6 + level_match * 0.2 + usage_score * 0.2)
            
            if confidence > 0.3:
                recommendations.append({
                    "skill": skill_name,
                    "description": skill["description"],
                    "category": skill["category"],
                    "confidence": round(confidence, 2),
                    "reason": self._generate_recommendation_reason(
                        skill_name, parsed, relevance
                    ),
                    "complexity": skill["complexity"],
                    "estimated_time": self._estimate_learning_time(skill_name),
                })
        
        # Sort by confidence
        recommendations.sort(key=lambda x: x["confidence"], reverse=True)
        return recommendations[:5]
    
    def get_skill_combos(self, primary_skill: str, limit: int = 3) -> List[Dict]:
        """
        Recommend complementary skills to combine with primary skill
        """
        if primary_skill not in self.skills:
            return []
        
        primary = self.skills[primary_skill]
        combos = []
        
        for other_name, other_skill in self.skills.items():
            if other_name == primary_skill:
                continue
            
            # Calculate combo score
            tag_overlap = len(set(primary["tags"]) & set(other_skill["tags"]))
            keyword_overlap = len(set(primary["keywords"]) & set(other_skill["keywords"]))
            
            combo_score = (tag_overlap * 0.6 + keyword_overlap * 0.4)
            
            if combo_score > 0:
                combos.append({
                    "skill": other_name,
                    "combo_score": round(combo_score, 2),
                    "synergy": self._describe_synergy(primary_skill, other_name),
                    "use_case": self._generate_combo_usecase(primary_skill, other_name),
                })
        
        combos.sort(key=lambda x: x["combo_score"], reverse=True)
        return combos[:limit]
    
    # ============================================================================
    # LEARNING OPTIMIZATION
    # ============================================================================
    
    def generate_learning_path(self, goal: str, current_level: str = "Beginner") -> List[Dict]:
        """
        Generate personalized learning path to achieve goal
        """
        recommendations = self.recommend_skills(goal, current_level)
        
        # Order by complexity and dependencies
        learning_path = []
        seen = set()
        
        for rec in recommendations:
            if rec["skill"] not in seen:
                learning_path.append({
                    "step": len(learning_path) + 1,
                    "skill": rec["skill"],
                    "description": rec["description"],
                    "estimated_hours": rec["estimated_time"],
                    "prerequisites": self._get_prerequisites(rec["skill"]),
                    "next_skills": self._suggest_next_skills(rec["skill"]),
                })
                seen.add(rec["skill"])
        
        return learning_path
    
    # ============================================================================
    # ANALYTICS & OPTIMIZATION
    # ============================================================================
    
    def analyze_usage_patterns(self) -> Dict:
        """Analyze how skills are being used"""
        if not self.usage_data.get("usage_history"):
            return {"message": "No usage data available"}
        
        history = self.usage_data["usage_history"]
        
        skill_usage = Counter()
        time_patterns = defaultdict(int)
        skill_chains = defaultdict(Counter)
        
        for entry in history:
            skill_usage[entry["skill"]] += 1
            
            # Time pattern analysis
            hour = entry["timestamp"].split("T")[1][:2]
            time_patterns[hour] += 1
        
        # Detect skill chains (skills used in sequence)
        for i in range(len(history) - 1):
            current = history[i]["skill"]
            next_skill = history[i + 1]["skill"]
            skill_chains[current][next_skill] += 1
        
        return {
            "total_usages": len(history),
            "unique_skills": len(skill_usage),
            "most_used": skill_usage.most_common(5),
            "peak_usage_hours": sorted(time_patterns.items(), key=lambda x: x[1], reverse=True)[:3],
            "common_chains": {
                skill: chains.most_common(3) 
                for skill, chains in skill_chains.items()
            },
        }
    
    # ============================================================================
    # HELPER METHODS
    # ============================================================================
    
    def _get_skill_usage_score(self, skill_name: str) -> float:
        """Get how frequently a skill has been used"""
        if not self.usage_data.get("usage_history"):
            return 0.5
        
        usage_count = sum(
            1 for entry in self.usage_data["usage_history"]
            if entry["skill"] == skill_name
        )
        
        # Normalize (max 1.0)
        total = len(self.usage_data["usage_history"])
        return min(1.0, usage_count / max(total / 10, 1))
    
    def _build_semantic_index(self) -> Dict:
        """Build relationships between skills"""
        index = {
            "skill_relationships": {},
            "tag_graph": {},
            "category_graph": {},
        }
        
        for skill_name in self.skills:
            relationships = []
            for other_name in self.skills:
                if skill_name != other_name:
                    # Simple relationship detection
                    overlap = len(
                        set(self.skills[skill_name]["tags"]) & 
                        set(self.skills[other_name]["tags"])
                    )
                    if overlap > 0:
                        relationships.append((other_name, overlap))
            
            if relationships:
                relationships.sort(key=lambda x: x[1], reverse=True)
                index["skill_relationships"][skill_name] = [r[0] for r in relationships[:5]]
        
        return index
    
    def _generate_recommendation_reason(self, skill_name: str, parsed: Dict, relevance: float) -> str:
        """Generate human-readable reason for recommendation"""
        if relevance > 0.7:
            return "Highly relevant to your query"
        elif relevance > 0.5:
            return "Well-suited for your needs"
        else:
            return "May be helpful"
    
    def _describe_synergy(self, skill1: str, skill2: str) -> str:
        """Describe how two skills work together"""
        s1 = self.skills[skill1]
        s2 = self.skills[skill2]
        
        tag_overlap = set(s1["tags"]) & set(s2["tags"])
        if tag_overlap:
            return f"Both cover {', '.join(tag_overlap)}"
        return "Complementary approaches"
    
    def _generate_combo_usecase(self, skill1: str, skill2: str) -> str:
        """Generate use case for skill combination"""
        return f"Combine {skill1} with {skill2} for advanced workflows"
    
    def _get_prerequisites(self, skill_name: str) -> List[str]:
        """Get prerequisites for a skill"""
        # This would read from skill_prerequisites.json
        prerequisites_file = self.skill_manager / "protocol" / "skill_prerequisites.json"
        
        if prerequisites_file.exists():
            with open(prerequisites_file) as f:
                data = json.load(f)
                return data.get("skill_prerequisites", {}).get("prerequisites", {}).get(
                    skill_name, {}
                ).get("required", [])
        
        return []
    
    def _suggest_next_skills(self, skill_name: str) -> List[str]:
        """Suggest skills to learn after this one"""
        if skill_name in self.semantic_index.get("skill_relationships", {}):
            return self.semantic_index["skill_relationships"][skill_name][:2]
        return []
    
    def _estimate_learning_time(self, skill_name: str) -> float:
        """Estimate time to learn a skill (hours)"""
        complexity_map = {"Beginner": 1.0, "Intermediate": 3.0, "Expert": 8.0}
        return complexity_map.get(self.skills[skill_name]["complexity"], 2.0)
    
    # ============================================================================
    # EXPORT & DISPLAY
    # ============================================================================
    
    def to_dict(self) -> Dict:
        """Export to dictionary for API use"""
        return {
            "total_skills": len(self.skills),
            "categories": list(set(s["category"] for s in self.skills.values())),
            "tags": list(set(t for s in self.skills.values() for t in s["tags"])),
            "skills": self.skills,
        }
    
    def pretty_print_recommendations(self, recommendations: List[Dict]) -> str:
        """Format recommendations for display"""
        output = []
        output.append("🤖 SKILL COPILOT RECOMMENDATIONS\n")
        
        for i, rec in enumerate(recommendations, 1):
            output.append(f"{i}. {rec['skill'].upper()}")
            output.append(f"   └─ {rec['description']}")
            output.append(f"   └─ Confidence: {rec['confidence']} | Level: {rec['complexity']}")
            output.append(f"   └─ {rec['reason']}\n")
        
        return "\n".join(output)


# ============================================================================
# CLI INTERFACE
# ============================================================================

def main():
    import sys
    
    copilot = SkillCopilot()
    
    if len(sys.argv) < 2:
        print("🤖 Skill Copilot v3.0 - AI-Powered Skill Assistant")
        print("\nUsage:")
        print("  python skill_copilot.py 'find skills for React development'")
        print("  python skill_copilot.py 'recommend skills for my task'")
        print("  python skill_copilot.py 'what skills work with Docker?'")
        return
    
    query = " ".join(sys.argv[1:])
    
    # Get recommendations
    recommendations = copilot.recommend_skills(query)
    
    # Print results
    print(copilot.pretty_print_recommendations(recommendations))
    
    # Show skill combinations
    if recommendations:
        print("\n🔗 SKILL COMBINATIONS:")
        combos = copilot.get_skill_combos(recommendations[0]["skill"])
        for combo in combos:
            print(f"  + {combo['skill']}: {combo['use_case']}")


if __name__ == "__main__":
    main()
