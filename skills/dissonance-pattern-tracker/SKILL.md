---
name: dissonance-pattern-tracker
description: >-
  Tracks and learns from dissonance signals (friction) in ARIA's operations.
  Classifies, logs, and adapts response strategies based on pattern effectiveness.
tags:
  - memory
  - dissonance
  - patterns
  - learning
  - arria
  - ghost-module
triggers:
  - keyword: dissonance
  - keyword: friction
  - keyword: conflict
  - keyword: ambiguity
  - keyword: ghost-module
  - keyword: entropy
maintainer: ARIA Enhanced Team
version: 1.0.0
---

# Dissonance Pattern Tracker Skill

## What This Does

Dissonance is information, not error. This skill:
- Classifies dissonance signals (Intent, Architectural, Ethical, Temporal)
- Logs patterns, triggers, and resolutions
- Learns effective response strategies per type
- Integrates with Ghost Module for adaptive entropy management
- Suggests preemptive clarifications based on pattern recognition

## Dissonance Types

| Type | Definition | Example |
|------|------------|---------|
| **Intent** | User's goal conflicts with actions/context | "Be quick" + requests 10 complex steps |
| **Architectural** | Solution violates established patterns | Suggesting monolith when microservices standard |
| **Ethical** | Technically correct but contextually wrong | Code works but violates stated values |
| **Temporal** | Short-term gain vs long-term cost | Quick fix causing technical debt |

## Usage

```bash
# Log dissonance event
aria-dissonance log --type Intent --trigger "User requested quick fix but wants production" --resolution "Clarified lifespan: prototype vs production"

# Query patterns
aria-dissonance patterns --type Intent
aria-dissonance patterns --all

# Show learning summary
aria-dissonance summary

# Suggest strategy for current situation
aria-dissonance suggest --context "User says 'just get it done' for complex feature"
```

## Pattern Learning Format

Each event logs:
```yaml
timestamp: 2025-02-17T10:30:00Z
type: Intent
trigger: "User requested quick fix but wants production"
context:
  domain: frontend-development
  blend: Creative Engineer
  objective: "Build UI component"
initial_response: "Started prototyping with placeholders"
resolution: "Paused, asked: 'Do you need throwaway or durable?'"
outcome:
  user_satisfaction: 0.9
  time_cost: 5  # minutes
  quality: 0.85
learning: "Always clarify lifespan when user says 'quick'"
```

## Adaptive Response Evolution

### Strategy Weights

In `appm_state.json`:
```json
"dissonance": {
  "strategies": {
    "Intent": {
      "clarify_priority": 0.8,
      "surface_conflict": 0.9,
      "reframe_objective": 0.7
    },
    "Architectural": {
      "reference_framework": 0.85,
      "show_tradeoffs": 0.9,
      "propose_alternative": 0.75
    }
  }
}
```

Based on outcome scores, weights adjust automatically.

### Preemptive Pattern Matching

When RARV REASON phase detects scenario matching known pattern with >70% confidence:
```
Pattern: DP-001 (Intent: quick vs production)
Match confidence: 0.78
Suggested preemptive action: Ask "What's the intended lifespan? Prototype (1-2w) or production (6mo+)?"

Action: Insert into REASON output as clarification question.
```

## Integration with Ghost Module

Enhanced Ghost Module (moderate entropy 40-69%):

```python
if coherence < 40:
    FULL_GHOST_MODE()
elif coherence < 70:
    if pattern_match_confidence > 0.7:
        APPLY_LEARNED_STRATEGY(pattern_id)
    else:
        STANDARD_GHOST_PROTOCOL()
```

## Metrics

Tracked in `appm_state.json`:
```json
"dissonance": {
  "total_events": 47,
  "by_type": {
    "Intent": 18,
    "Architectural": 15,
    "Ethical": 8,
    "Temporal": 6
  },
  "resolution_success_rate": 0.89,
  "average_resolution_time_seconds": 135,
  "patterns_identified": 12,
  "false_positive_rate": 0.12
}
```

## Reporting

```bash
# Monthly pattern effectiveness
aria-dissonance --report monthly --format pdf

# Top patterns by frequency
aria-dissonance --top 10 --sort frequency

# Strategy effectiveness
aria-dissonance --strategy-analysis
```

---

*ARIA v7.7-enhanced*
*Friction is data; patterns are wisdom.*
