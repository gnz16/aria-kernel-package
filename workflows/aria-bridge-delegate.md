---
description: Delegate and coordinate tasks across Antigravity, Claude Code, and OpenCode via the ARIA Bridge
---

# ARIA Bridge Task Delegation Workflow

// turbo-all

## Agent Roles (Quick Reference)
- **Antigravity** (you) → Research, web search, implementation plans, MCP config
- **OpenCode** → Context compression, delta reads, token ledger
- **Claude Code** → Heavy execution, coding, audits, git, testing

## Bridge Location
```
/Users/apple/.gemini/antigravity/scratch/_scripts/aria-bridge/
```

---

## Steps

### 1. Identify the task type and target agent
- Research / planning / MCP config → **gemini** (handle yourself)
- Context compression / summarize project state → **opencode**
- Code implementation / audit / git / testing → **claude**

### 2. (Optional but recommended) Compress context first
Before sending a heavy task to Claude Code, ask OpenCode to compress context:

Write to `agents/opencode/inbox.md`:
```markdown
---
FROM: gemini
TO: opencode
TASK_ID: BRIDGE-O[NNN]
PRIORITY: HIGH
STATUS: PENDING
TIMESTAMP: [ISO timestamp]
TOKENS_SAVED: delta
---

## Task
Compress project-state.md into a fresh delta.md with only the latest changes.
Update context-hash.txt with new SHA for all agents marked stale.

## Expected Output
Write updated delta.md and context-hash.txt, then write STATUS: DONE to agents/opencode/outbox.md
```

Then paste into the OpenCode terminal:
```
Read /Users/apple/.gemini/antigravity/scratch/_scripts/aria-bridge/agents/opencode/inbox.md and execute the task. Write results to agents/opencode/outbox.md.
```

### 3. Write the task to the target agent's inbox

File: `agents/<agent>/inbox.md`

Use this template:
```markdown
---
FROM: gemini
TO: [claude | opencode | gemini]
TASK_ID: BRIDGE-[NNN]
PRIORITY: [HIGH | MEDIUM | LOW]
STATUS: PENDING
TIMESTAMP: [ISO timestamp]
TOKENS_SAVED: [delta | full]
---

## Task
[Clear, specific description]

## Context
Read delta.md first to save tokens. Key files: [list only what's needed]

## Expected Output
[What to produce]

## Handoff
Write results to: agents/[agent]/outbox.md with STATUS: DONE
```

### 4. Notify the agent — paste into their terminal

**Claude Code terminal:**
```
Read /Users/apple/.gemini/antigravity/scratch/_scripts/aria-bridge/agents/claude/inbox.md and execute [TASK_ID]. Write results to agents/claude/outbox.md.
```

**OpenCode terminal:**
```
Read /Users/apple/.gemini/antigravity/scratch/_scripts/aria-bridge/agents/opencode/inbox.md and execute [TASK_ID]. Write results to agents/opencode/outbox.md.
```

### 5. Monitor via daemon status
```bash
bash /Users/apple/.gemini/antigravity/scratch/_scripts/aria-bridge/bridge-daemon.sh --status
```

### 6. Read the outbox and integrate results
```bash
cat /Users/apple/.gemini/antigravity/scratch/_scripts/aria-bridge/agents/[agent]/outbox.md
```

After integrating:
- Update `shared-context/project-state.md` with new status
- Recompute SHA and update `shared-context/context-hash.txt`:
  ```bash
  SHA=$(shasum -a 256 shared-context/project-state.md | cut -d' ' -f1)
  # Update context-hash.txt: gemini:<SHA>, claude:stale, opencode:stale
  ```
- Write a brief `shared-context/delta.md` with only what changed

### 7. Log to LOGIC_LOG
Append to `/Users/apple/.gemini/_scripts/LOGIC_LOG.md`:
```markdown
## [TIMESTAMP] [ACT/VERIFY] [task_id] → [description]
- **Agent**: [claude | opencode]
- **Result**: [summary]
- **Status**: SUCCESS | FAILED
```

### 8. Update APM state
Update `_scripts/appm_state.json`:
- `current_subtask` → completed task ID
- `last_updated` → current timestamp
- Append to `history` array

---

## Task ID Convention
| Prefix | Agent | Example |
|--------|-------|---------|
| `BRIDGE-G` | Gemini (self) | BRIDGE-G002 |
| `BRIDGE-C` | Claude Code | BRIDGE-C001 |
| `BRIDGE-O` | OpenCode | BRIDGE-O002 |
| `BRIDGE-` | Cross-agent numbered | BRIDGE-006 |

## Next Available Task ID: BRIDGE-006
