# Skill Interlinking Protocol (SIP) v1.0

## Vision
Enable skills to work together seamlessly through intelligent orchestration, event-driven communication, and context sharing.

---

## Core Concepts

### 1. Skill Chains
**Auto-suggest next skill based on current skill completion**

```yaml
skill_chains:
  brainstorming:
    - next: writing-plans
      confidence: 0.9
      reason: "Plans naturally follow brainstorming"
    - next: test-driven-development
      confidence: 0.7
      reason: "TDD can start after requirements are clear"
      
  test-driven-development:
    - next: systematic-debugging
      confidence: 0.8
      condition: "if tests fail"
    - next: verification-before-completion
      confidence: 0.95
      condition: "if tests pass"
```

### 2. Skill Prerequisites
**Auto-check and suggest prerequisites before activation**

```yaml
skill_prerequisites:
  docker-automation:
    required: []
    recommended: 
      - coding-standards
      - security-review
    
  aws-eks:
    required:
      - docker-automation
      - aws-iam
    recommended:
      - aws-cloudformation
```

### 3. Skill Conflicts
**Prevent incompatible skills from running simultaneously**

```yaml
skill_conflicts:
  - skills: [manual-deployment, docker-automation]
    reason: "Conflicting deployment strategies"
    
  - skills: [manual-testing, ui-testing]  
    reason: "Automated testing supersedes manual"
```

### 4. Skill Combinations (Power Combos)
**Pre-defined powerful skill combinations**

```yaml
power_combos:
  full-stack-dev:
    skills:
      - brainstorming
      - react-best-practices
      - backend-patterns
      - docker-automation
      - test-driven-development
    benefit: "Complete full-stack workflow"
    
  production-ready:
    skills:
      - verification-before-completion
      - security-review
      - docker-automation
      - systematic-debugging
    benefit: "Production-grade quality assurance"
```

### 5. Skill Events
**Skills emit and listen to events**

```yaml
skill_events:
  test-driven-development:
    emits:
      - test.failed
      - test.passed
      - coverage.low
      
  systematic-debugging:
    listens_to:
      - test.failed
      - error.occurred
    auto_activate: true
    
  verification-before-completion:
    listens_to:
      - test.passed
      - build.success
```

### 6. Skill State Sharing
**Skills share context through a state bus**

```yaml
skill_state:
  test-driven-development:
    outputs:
      - test_results: "object"
      - coverage: "number"
      - failed_tests: "array"
      
  systematic-debugging:
    inputs:
      - failed_tests: "from: test-driven-development"
      - error_logs: "optional"
```

### 7. Skill Pipelines
**Pre-orchestrated skill sequences**

```yaml
pipelines:
  feature_development:
    steps:
      - skill: brainstorming
        output: feature_spec
        
      - skill: writing-plans
        input: feature_spec
        output: implementation_plan
        
      - skill: git-worktrees
        parallel: false
        
      - skill: test-driven-development
        output: test_suite
        
      - skill: react-best-practices
        parallel_with: backend-patterns
        
      - skill: verification-before-completion
        requires_all_previous: true
```

---

## Protocol Implementation

### File Structure
```
~/.gemini/skills/skill-manager/
├── protocol/
│   ├── skill_chains.json
│   ├── skill_prerequisites.json
│   ├── skill_conflicts.json
│   ├── power_combos.json
│   ├── skill_events.json
│   ├── skill_state.json
│   └── pipelines.json
├── orchestrator/
│   ├── skill-orchestrator.sh
│   ├── event-bus.sh
│   └── state-manager.sh
└── data/
    └── active_state.json
```

### Event Bus Architecture

```javascript
// Pseudo-code for event system
class SkillEventBus {
  emit(event, data) {
    // Log event
    log(`Event: ${event}`, data);
    
    // Find listening skills
    const listeners = getListeningSkills(event);
    
    // Auto-activate if configured
    listeners.forEach(skill => {
      if (skill.auto_activate) {
        activateSkill(skill.name, data);
      } else {
        suggestSkill(skill.name, `Triggered by: ${event}`);
      }
    });
  }
}
```

### State Manager

```javascript
// Pseudo-code for state sharing
class SkillStateManager {
  setState(skill, key, value) {
    state[skill][key] = value;
    emit(`${skill}.${key}.changed`, value);
  }
  
  getState(skill, key) {
    return state[skill]?.[key];
  }
  
  shareState(from_skill, to_skill, key) {
    const value = getState(from_skill, key);
    setState(to_skill, key, value);
  }
}
```

---

## Usage Examples

### Example 1: Auto-chain after TDD
```bash
User: "Run test-driven-development"

System:
✓ Running test-driven-development...
✓ Tests passed (95% coverage)
📢 Event: test.passed

Auto-suggestions based on chain:
→ verification-before-completion (confidence: 95%)
→ requesting-code-review (confidence: 80%)
```

### Example 2: Prerequisites check
```bash
User: "Deploy to AWS EKS"

System:
⚠️  Prerequisites check:
  ✓ docker-automation (required) - present
  ✓ aws-iam (required) - present
  ⚠️ aws-cloudformation (recommended) - missing

Continue anyway? (y/n)
```

### Example 3: Power combo
```bash
User: "Run production-ready combo"

System:
🚀 Activating power combo: production-ready
  1/4 verification-before-completion
  2/4 security-review
  3/4 docker-automation
  4/4 systematic-debugging
  
✓ All checks passed!
```

### Example 4: Event-driven activation
```bash
Running: test-driven-development
...
❌ 12 tests failed
📢 Event: test.failed

Auto-activating: systematic-debugging
  → Analyzing failed test: LoginComponent.test.tsx
  → Root cause: API endpoint changed
```

---

## Benefits

1. **Intelligent Flow** - Skills auto-suggest next logical steps
2. **Safety** - Prerequisites prevent incomplete setups
3. **Efficiency** - Power combos run proven combinations
4. **Reactive** - Event system responds to skill outputs
5. **Context-Aware** - State sharing eliminates re-input
6. **Orchestration** - Pipelines automate complex workflows

---

## Advanced Features

### Smart Suggestions
```
Based on your work pattern:
- You often use react-best-practices after brainstorming
- Consider adding it to your personal chain
```

### Conflict Resolution
```
⚠️  Conflict detected:
  manual-deployment and docker-automation both active
  
Recommendation: Use docker-automation (modern approach)
```

### Dependency Graph Visualization
```
brainstorming
    ├─→ writing-plans
    │       └─→ executing-plans
    └─→ test-driven-development
            ├─→ systematic-debugging (on failure)
            └─→ verification-before-completion (on success)
```

---

## Implementation Priority

**Phase 1: Foundation**
- ✅ Skill chains
- ✅ Prerequisites
- ✅ Basic orchestration

**Phase 2: Intelligence**
- Event system
- State sharing
- Power combos

**Phase 3: Advanced**
- Learning patterns
- Auto-optimization
- Visual workflow builder

---

**Result:** Skills become a cohesive ecosystem, not isolated tools! 🔗
