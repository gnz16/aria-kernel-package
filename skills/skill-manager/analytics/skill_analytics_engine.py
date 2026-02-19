#!/usr/bin/env python3
"""
📊 SKILL ANALYTICS ENGINE v2.0 - Real-time Performance Monitoring
================================================================================

Revolutionary analytics for skill usage, performance, and health.
Tracks execution time, success rates, resource usage, and provides
optimization recommendations.
"""

import json
import time
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional
from collections import defaultdict, Counter
import statistics
import os


class SkillAnalyticsEngine:
    """Advanced analytics for skill system performance and health"""
    
    def __init__(self, skills_root: str = None):
        if skills_root is None:
            skills_root = os.path.expanduser("~/.gemini/skills")
        
        self.skills_root = Path(skills_root)
        self.skill_manager = self.skills_root / "skill-manager"
        self.analytics_db = self.skill_manager / "data" / "analytics.json"
        self.performance_db = self.skill_manager / "data" / "performance.json"
        self.health_db = self.skill_manager / "data" / "health.json"
        
        # Ensure data directories exist
        self.analytics_db.parent.mkdir(parents=True, exist_ok=True)
        
        self.analytics = self._load_analytics()
        self.performance = self._load_performance()
        self.health = self._load_health()
    
    # ============================================================================
    # DATA LOADING & INITIALIZATION
    # ============================================================================
    
    def _load_analytics(self) -> Dict:
        """Load analytics database"""
        if self.analytics_db.exists():
            with open(self.analytics_db) as f:
                return json.load(f)
        
        return {
            "skills": defaultdict(lambda: {
                "executions": 0,
                "total_time": 0,
                "success_count": 0,
                "error_count": 0,
                "execution_times": [],
                "last_used": None,
            }),
            "meta": {
                "created": datetime.now().isoformat(),
                "updated": datetime.now().isoformat(),
            }
        }
    
    def _load_performance(self) -> Dict:
        """Load performance metrics"""
        if self.performance_db.exists():
            with open(self.performance_db) as f:
                return json.load(f)
        
        return {
            "hourly": defaultdict(list),
            "daily": defaultdict(list),
            "resource_usage": defaultdict(lambda: {"cpu": [], "memory": []}),
        }
    
    def _load_health(self) -> Dict:
        """Load health metrics"""
        if self.health_db.exists():
            with open(self.health_db) as f:
                return json.load(f)
        
        return {
            "status": "healthy",
            "last_check": None,
            "alerts": [],
            "warnings": [],
            "outdated_skills": [],
        }
    
    # ============================================================================
    # EXECUTION TRACKING
    # ============================================================================
    
    def record_execution(self, skill_name: str, duration: float, success: bool, 
                        error_msg: Optional[str] = None, resources: Optional[Dict] = None):
        """Record skill execution metrics"""
        
        if skill_name not in self.analytics["skills"]:
            self.analytics["skills"][skill_name] = {
                "executions": 0,
                "total_time": 0,
                "success_count": 0,
                "error_count": 0,
                "execution_times": [],
                "last_used": None,
                "errors": [],
            }
        
        skill_data = self.analytics["skills"][skill_name]
        
        # Update counts
        skill_data["executions"] += 1
        skill_data["total_time"] += duration
        skill_data["execution_times"].append(duration)
        skill_data["last_used"] = datetime.now().isoformat()
        
        if success:
            skill_data["success_count"] += 1
        else:
            skill_data["error_count"] += 1
            if error_msg:
                if "errors" not in skill_data:
                    skill_data["errors"] = []
                skill_data["errors"].append({
                    "timestamp": datetime.now().isoformat(),
                    "message": error_msg,
                })
        
        # Keep only last 100 execution times
        if len(skill_data["execution_times"]) > 100:
            skill_data["execution_times"] = skill_data["execution_times"][-100:]
        
        # Track resource usage
        if resources:
            self._record_resource_usage(skill_name, resources)
        
        # Update analytics meta
        self.analytics["meta"]["updated"] = datetime.now().isoformat()
        
        # Save to disk
        self._save_analytics()
    
    def _record_resource_usage(self, skill_name: str, resources: Dict):
        """Record resource usage metrics"""
        hour = datetime.now().strftime("%Y-%m-%d-%H")
        day = datetime.now().strftime("%Y-%m-%d")
        
        if hour not in self.performance["hourly"]:
            self.performance["hourly"][hour] = []
        
        self.performance["hourly"][hour].append({
            "skill": skill_name,
            "cpu": resources.get("cpu", 0),
            "memory": resources.get("memory", 0),
            "timestamp": datetime.now().isoformat(),
        })
        
        if day not in self.performance["daily"]:
            self.performance["daily"][day] = []
        
        self.performance["daily"][day].append({
            "skill": skill_name,
            "cpu": resources.get("cpu", 0),
            "memory": resources.get("memory", 0),
        })
    
    # ============================================================================
    # PERFORMANCE METRICS
    # ============================================================================
    
    def get_skill_metrics(self, skill_name: str) -> Dict:
        """Get comprehensive metrics for a skill"""
        
        if skill_name not in self.analytics["skills"]:
            return {"error": "Skill not found in analytics"}
        
        data = self.analytics["skills"][skill_name]
        exec_times = data["execution_times"]
        
        if not exec_times:
            return {"error": "No execution data"}
        
        # Calculate statistics
        avg_time = statistics.mean(exec_times)
        median_time = statistics.median(exec_times)
        
        return {
            "skill": skill_name,
            "executions": data["executions"],
            "success_rate": round((data["success_count"] / data["executions"] * 100), 2) if data["executions"] > 0 else 0,
            "error_rate": round((data["error_count"] / data["executions"] * 100), 2) if data["executions"] > 0 else 0,
            "execution_time": {
                "average": round(avg_time, 2),
                "median": round(median_time, 2),
                "min": round(min(exec_times), 2),
                "max": round(max(exec_times), 2),
                "std_dev": round(statistics.stdev(exec_times), 2) if len(exec_times) > 1 else 0,
            },
            "total_time": round(data["total_time"], 2),
            "last_used": data["last_used"],
            "trend": self._calculate_trend(exec_times),
            "performance_grade": self._grade_performance(data),
        }
    
    def get_top_performers(self, limit: int = 10) -> List[Dict]:
        """Get top performing skills"""
        metrics = []
        
        for skill_name in self.analytics["skills"]:
            try:
                skill_metrics = self.get_skill_metrics(skill_name)
                if "error" not in skill_metrics:
                    metrics.append(skill_metrics)
            except:
                pass
        
        # Score based on execution count and success rate
        metrics.sort(
            key=lambda x: x["executions"] * (x["success_rate"] / 100),
            reverse=True
        )
        
        return metrics[:limit]
    
    def get_problem_skills(self, limit: int = 10) -> List[Dict]:
        """Identify skills with performance issues"""
        problem_skills = []
        
        for skill_name in self.analytics["skills"]:
            try:
                skill_metrics = self.get_skill_metrics(skill_name)
                if "error" not in skill_metrics:
                    # Issues: low success rate, high variability, slow execution
                    issues = []
                    
                    if skill_metrics["success_rate"] < 80:
                        issues.append(f"Low success rate: {skill_metrics['success_rate']}%")
                    
                    if skill_metrics["execution_time"]["std_dev"] > skill_metrics["execution_time"]["average"] * 0.5:
                        issues.append("High execution time variability")
                    
                    if skill_metrics["execution_time"]["average"] > 5.0:
                        issues.append("Slow execution time")
                    
                    if issues:
                        problem_skills.append({
                            "skill": skill_name,
                            "issues": issues,
                            "metrics": skill_metrics,
                        })
            except:
                pass
        
        return problem_skills[:limit]
    
    # ============================================================================
    # TREND ANALYSIS
    # ============================================================================
    
    def _calculate_trend(self, execution_times: List[float]) -> str:
        """Analyze trend in execution times"""
        if len(execution_times) < 5:
            return "insufficient_data"
        
        # Compare first half vs second half
        mid = len(execution_times) // 2
        first_half_avg = statistics.mean(execution_times[:mid])
        second_half_avg = statistics.mean(execution_times[mid:])
        
        change_percent = ((second_half_avg - first_half_avg) / first_half_avg) * 100
        
        if change_percent < -10:
            return "improving"
        elif change_percent > 10:
            return "degrading"
        else:
            return "stable"
    
    def _grade_performance(self, data: Dict) -> str:
        """Grade skill performance"""
        if data["executions"] == 0:
            return "N/A"
        
        success_rate = (data["success_count"] / data["executions"]) * 100
        
        if success_rate >= 95:
            return "A"
        elif success_rate >= 85:
            return "B"
        elif success_rate >= 75:
            return "C"
        elif success_rate >= 60:
            return "D"
        else:
            return "F"
    
    # ============================================================================
    # HEALTH MONITORING
    # ============================================================================
    
    def check_system_health(self) -> Dict:
        """Comprehensive system health check"""
        health_report = {
            "timestamp": datetime.now().isoformat(),
            "status": "healthy",
            "alerts": [],
            "warnings": [],
            "stats": {
                "total_skills": len(self.analytics["skills"]),
                "total_executions": sum(s["executions"] for s in self.analytics["skills"].values()),
                "avg_success_rate": 0,
            }
        }
        
        # Calculate average success rate
        total_execs = health_report["stats"]["total_executions"]
        if total_execs > 0:
            total_successes = sum(s["success_count"] for s in self.analytics["skills"].values())
            health_report["stats"]["avg_success_rate"] = round((total_successes / total_execs * 100), 2)
        
        # Check for issues
        problem_skills = self.get_problem_skills()
        
        if problem_skills:
            health_report["warnings"].extend([
                f"Skill '{p['skill']}' has issues: {', '.join(p['issues'])}"
                for p in problem_skills[:5]
            ])
            
            if health_report["stats"]["avg_success_rate"] < 70:
                health_report["status"] = "warning"
        
        # Check for unused skills
        unused = [
            name for name, data in self.analytics["skills"].items()
            if data["executions"] == 0
        ]
        
        if len(unused) > 0:
            health_report["warnings"].append(f"{len(unused)} skills have never been executed")
        
        # Check for skills with high error rates
        for skill_name in self.analytics["skills"]:
            try:
                metrics = self.get_skill_metrics(skill_name)
                if metrics["error_rate"] > 30:
                    health_report["alerts"].append(
                        f"Skill '{skill_name}' has {metrics['error_rate']}% error rate"
                    )
                    health_report["status"] = "critical"
            except:
                pass
        
        self.health = health_report
        self._save_health()
        
        return health_report
    
    # ============================================================================
    # OPTIMIZATION RECOMMENDATIONS
    # ============================================================================
    
    def get_optimization_recommendations(self) -> List[Dict]:
        """Provide actionable optimization recommendations"""
        recommendations = []
        
        # 1. Recommend caching for slow skills
        slow_skills = [
            (name, data)
            for name, data in self.analytics["skills"].items()
            if data["execution_times"] and 
               statistics.mean(data["execution_times"]) > 2.0 and
               data["executions"] > 5
        ]
        
        for name, data in sorted(slow_skills, key=lambda x: statistics.mean(x[1]["execution_times"]), reverse=True)[:3]:
            avg_time = statistics.mean(data["execution_times"])
            recommendations.append({
                "type": "performance",
                "priority": "high",
                "skill": name,
                "issue": f"Skill takes {avg_time:.1f}s on average",
                "recommendation": f"Consider caching results for {name}",
                "potential_savings": f"Could save {avg_time * data['executions']:.0f} seconds total",
            })
        
        # 2. Recommend fixes for high-error skills
        for skill_name in self.analytics["skills"]:
            data = self.analytics["skills"][skill_name]
            if data["executions"] > 0 and data["error_count"] / data["executions"] > 0.2:
                recommendations.append({
                    "type": "reliability",
                    "priority": "critical",
                    "skill": skill_name,
                    "issue": f"Error rate is {(data['error_count'] / data['executions'] * 100):.1f}%",
                    "recommendation": f"Debug {skill_name} - review recent error logs",
                    "errors": data.get("errors", [])[-3:],  # Last 3 errors
                })
        
        # 3. Recommend batching for frequently used skills
        frequent_skills = [
            (name, data)
            for name, data in self.analytics["skills"].items()
            if data["executions"] > 20
        ]
        
        for name, data in sorted(frequent_skills, key=lambda x: x[1]["executions"], reverse=True)[:2]:
            recommendations.append({
                "type": "efficiency",
                "priority": "medium",
                "skill": name,
                "issue": f"Used {data['executions']} times",
                "recommendation": f"Consider batching {name} operations",
                "current_avg_time": round(statistics.mean(data["execution_times"]), 2),
            })
        
        return sorted(recommendations, key=lambda x: {"critical": 0, "high": 1, "medium": 2}[x["priority"]])
    
    # ============================================================================
    # REPORTING
    # ============================================================================
    
    def generate_performance_report(self) -> str:
        """Generate human-readable performance report"""
        lines = []
        lines.append("=" * 80)
        lines.append("📊 SKILL SYSTEM PERFORMANCE REPORT")
        lines.append("=" * 80)
        
        # Health summary
        health = self.check_system_health()
        lines.append(f"\n📈 SYSTEM STATUS: {health['status'].upper()}")
        lines.append(f"   Timestamp: {health['timestamp']}")
        
        # Stats
        lines.append(f"\n📋 STATISTICS:")
        lines.append(f"   Total Skills Tracked: {health['stats']['total_skills']}")
        lines.append(f"   Total Executions: {health['stats']['total_executions']}")
        lines.append(f"   Overall Success Rate: {health['stats']['avg_success_rate']}%")
        
        # Top performers
        lines.append(f"\n⭐ TOP PERFORMERS:")
        for i, skill in enumerate(self.get_top_performers(5), 1):
            lines.append(f"   {i}. {skill['skill']} - {skill['performance_grade']} grade")
            lines.append(f"      └─ {skill['executions']} executions, {skill['success_rate']}% success")
        
        # Problem skills
        problems = self.get_problem_skills(3)
        if problems:
            lines.append(f"\n⚠️  PROBLEM SKILLS:")
            for skill_info in problems:
                lines.append(f"   • {skill_info['skill']}")
                for issue in skill_info["issues"]:
                    lines.append(f"     └─ {issue}")
        
        # Recommendations
        recs = self.get_optimization_recommendations()
        if recs:
            lines.append(f"\n💡 OPTIMIZATION RECOMMENDATIONS:")
            for rec in recs[:5]:
                lines.append(f"   [{rec['priority'].upper()}] {rec['skill']}: {rec['recommendation']}")
        
        # Alerts
        if health["alerts"]:
            lines.append(f"\n🚨 ALERTS:")
            for alert in health["alerts"]:
                lines.append(f"   • {alert}")
        
        lines.append("\n" + "=" * 80)
        
        return "\n".join(lines)
    
    # ============================================================================
    # PERSISTENCE
    # ============================================================================
    
    def _save_analytics(self):
        """Save analytics to disk"""
        with open(self.analytics_db, "w") as f:
            json.dump(self.analytics, f, indent=2, default=str)
    
    def _save_performance(self):
        """Save performance data to disk"""
        with open(self.performance_db, "w") as f:
            json.dump(self.performance, f, indent=2, default=str)
    
    def _save_health(self):
        """Save health data to disk"""
        with open(self.health_db, "w") as f:
            json.dump(self.health, f, indent=2, default=str)
    
    def save_all(self):
        """Save all data"""
        self._save_analytics()
        self._save_performance()
        self._save_health()


# ============================================================================
# DEMO & CLI
# ============================================================================

if __name__ == "__main__":
    engine = SkillAnalyticsEngine()
    
    # Record some sample executions
    engine.record_execution("ui-testing", 2.5, True)
    engine.record_execution("ui-testing", 2.3, True)
    engine.record_execution("ui-testing", 3.1, True)
    
    engine.record_execution("docker-automation", 0.8, True)
    engine.record_execution("docker-automation", 0.9, True)
    
    engine.record_execution("react-best-practices", 1.5, False, "Module not found")
    
    # Save data
    engine.save_all()
    
    # Generate report
    print(engine.generate_performance_report())
