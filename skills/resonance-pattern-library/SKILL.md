---
name: resonance-pattern-library
description: >-
  Learns and optimizes cognitive blend selection for ARIA. Tracks which
  resonance blends (Apollo+Dionysus, etc.) work best for which problem domains,
  with effectiveness metrics and automatic recommendation engine.
tags:
  - memory
  - resonance
  - blends
  - optimization
  - arria
  - learning
triggers:
  - keyword: resonance
  - keyword: blend
  - keyword: cognitive
  - keyword: pattern
  - keyword: effectiveness
  - keyword: optimize
maintainer: ARIA Enhanced Team
version: 1.0.0
---

# Resonance Pattern Library Skill

## What This Does

ARIA's Resonance Matrix allows dynamic cognitive blending (Apollo+Athena, etc.). This skill:
- Records blend performance by problem domain
- Calculates effectiveness scores from outcomes
- Recommends optimal blends for given tasks
- Learns which combinations yield best results
- Adapts blend ratios over time

## How It Works

### Data Collection (Every RARV Cycle)

```yaml
cycle:
  domain: "security-audit"              # auto-detected or user-tagged
  blend: "Hephaestus + Athena"
  ratio: "70/30"
  duration_seconds: 450
  outcome:
    quality: 0.94                        # self-assessed 0-1
    iterations: 2                        # RARV recurse depth
    errors_caught: 7
    time_efficiency: 0.76                # vs baseline
    user_rating: 4.5 / 5.0
  constraints:
    - used_skill: "security-review"
    - constellation_mode: false
```

### Effectiveness Calculation

```
weighted_score = 
  0.30 * quality +
  0.25 * user_rating_norm +
  0.25 * time_efficiency +
  0.20 * (1 - normalized_iterations)
```

### Pattern Update (Exponential Smoothing)

```
new_score = 0.8 * historical_score + 0.2 * current_score
sample_size += 1
```

---

## Current Winning Blends (Auto-Discovered)

### Development & Engineering
- **Code Review**: The Auditor (70/30) — 94% effectiveness (128 samples)
- **Debugging**: The Craftsman (40/60) — 93% (203 samples)
- **Architecture**: Strategic Architect (60/40) — 91% (89 samples)
- **Refactoring**: The Craftsman (40/60) — 88% (76 samples)

### Creative & UX
- **UX Design**: Creative Engineer (55/45) — 91% (93 samples)
- **Ideation**: The Oracle (Dionysus 80% + Apollo 20%) — 84% (61 samples)
- **Visual Design**: The Artist (60/40) — 86% (45 samples)

### Security & Governance
- **Security Audit**: The Auditor (70/30) — 95% (52 samples)
- **Penetration Testing**: Hephaestus + Athena — 91% (44 samples)

---

## Usage

```bash
# Recommend blend for task
aria-blend recommend --task "security audit of web app"

# Show pattern library
aria-blend patterns --domain security

# Compare effectiveness
aria-blend compare --blends "Strategic Architect,The Auditor" --domain architecture

# Suggest optimal ratios
aria-blend optimize --domain "frontend" --samples 20

# Export library
aria-blend export --format json
```

## Session Attunement Integration

When user starts session, ARIA automatically:

```
READ STRATEGIC_LEDGER → find domain in resonance library
IF match with score ≥ 0.8:
  State: "For this type of task, I'll use [Blend] because it has [score] effectiveness on [N] similar cases."
ELSE:
  Use default decision matrix (from AGENTS.md)
LOG blend choice + rationale to CONTINUITY.md
```

Example:
```
User: "Review this authentication code"

ARIA: "Authentication review → security domain. The Auditor blend (Hephaestus+Athena 70/30) has 95% effectiveness on 52 security tasks. Activating now."
```

## Blend Adaptation Rules

### Boost Blend
- 3+ successful cycles in same domain
- User explicitly says "that blend worked well"
- Outcome score > 0.9 with low iterations (<3)

### Reduce Blend
- 2+ failures in same domain with same blend
- User says "that wasn't the right approach"
- Outcome score < 0.6 with high iterations (>5)

### Try New Blend
- Constellation Mode successful with different agent distribution
- Confidence in current blend < 0.7
- User requests "different perspective"

---

## Pattern Database Schema

`RESONANCE_PATTERNS.md`:
```markdown
## Pattern RP-001: Security Audit
- Domain: security-audit
- Blend: Hephaestus + Athena (70/30)
- Effectiveness: 0.95 / 1.0
- Samples: 52
- Last updated: 2025-02-18
- Success factors: 
  - Athena for ethical implications
  - Hephaestus for detail-oriented checking
  - Optimal duration: 2-4 hours
- Constraints: Requires security-review skill active
```

---

## Metrics Tracked

- **Effectiveness score** (weighted 0-1)
- **Sample size** (confidence increases with N)
- **Success rate** (binary win/loss)
- **Average iterations** (lower = cleaner execution)
- **User satisfaction** (1-5 rating)
- **Time efficiency** (vs baseline for domain)
- **Constellation usage frequency**
- **Blend ratio optimization** (fine-tune 60/40 → 65/35 etc.)

---

## Quarterly Review

Every 90 days:
1. Archive patterns unused for 6 months
2. Merge similar domains (e.g., "code-review" + "pull-request-review")
3. Re-evaluate top patterns: are they still optimal?
4. Write quarter summary to STRATEGIC_LEDGER
5. Update default blend matrix if shifts detected

---

*ARIA v7.7-enhanced*
*Resonance is adaptive intelligence.*
