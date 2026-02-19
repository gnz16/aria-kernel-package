# ARIA Agent Bridge — Persistent Guide
*Living document. Update whenever bridge mechanics change.*
*Last updated: 2026-02-18T23:01:00+05:30*

---

## What Is the Bridge?

A **filesystem-based communication layer** at:
```
/Users/apple/.gemini/antigravity/scratch/_scripts/aria-bridge/
```

Three agents share the **ARIA v7.7 kernel** and coordinate by reading/writing files here. No direct terminal scripting needed.

---

## Agent Roles (Refined 2026-02-18)

| Agent | Role | Best For |
|-------|------|----------|
| **Antigravity** (Gemini IDE) | 🔍 Research + Planning | Web search, implementation plans, MCP config |
| **OpenCode** | 🗜️ Context Compression | Delta reads, token ledger, summarization |
| **Claude Code** | ⚙️ Heavy Execution | Coding, audits, git, testing, Loki Mode |

---

## How to Send a Task to an Agent

### Step 1 — Write to their inbox

```bash
# File to write:
_scripts/aria-bridge/agents/<agent>/inbox.md

# Where <agent> is: claude | opencode | gemini
```

Use this message format:
```markdown
---
FROM: gemini
TO: claude
TASK_ID: BRIDGE-XXX
PRIORITY: HIGH | MEDIUM | LOW
STATUS: PENDING
TIMESTAMP: 2026-02-18T22:35:00+05:30
TOKENS_SAVED: delta | full
---

## Task
[Clear description of what to do]

## Context
[Minimal context — reference delta.md or project-state.md for shared state]

## Expected Output
[What to produce and where to write it]

## Handoff
Write results to: agents/<agent>/outbox.md with STATUS: DONE
```

### Step 2 — Tell the agent (paste into their terminal)

```
Read /Users/apple/.gemini/antigravity/scratch/_scripts/aria-bridge/agents/<agent>/inbox.md and execute [TASK_ID]. Write results to agents/<agent>/outbox.md.
```

### Step 3 — Read their outbox

```bash
cat _scripts/aria-bridge/agents/<agent>/outbox.md
```

### Step 4 — Update shared context

After integrating results, update `project-state.md` and `delta.md`:
```bash
# Update project-state.md with new status
# Compute new hash:
shasum -a 256 shared-context/project-state.md | cut -d' ' -f1

# Update context-hash.txt:
# gemini:<new_hash>
# claude:stale
# opencode:stale
```

---

## Token-Saving Protocol (CRITICAL)

Before any agent reads `project-state.md`, they MUST:

1. Check `shared-context/context-hash.txt` for their agent ID
2. If hash matches → read `delta.md` only (**saves ~54% tokens**)
3. If hash differs → read full `project-state.md`, update hash

```bash
# Quick check:
grep "claude" shared-context/context-hash.txt
# If "stale" → full read needed
# If hash matches your last read → delta only
```

---

## Daemon Commands

```bash
BRIDGE="/Users/apple/.gemini/antigravity/scratch/_scripts/aria-bridge"

# Start background watcher
bash $BRIDGE/bridge-daemon.sh --start &

# Check status + recent activity
bash $BRIDGE/bridge-daemon.sh --status

# Stop daemon
bash $BRIDGE/bridge-daemon.sh --stop

# Watch live (foreground)
bash $BRIDGE/bridge-daemon.sh --watch
```

---

## Standard Delegation Flow

```
1. User gives request to Antigravity
2. Antigravity researches + writes implementation plan
3. Antigravity → OpenCode: "Compress context, update delta.md"
4. Antigravity → Claude Code: "Execute plan [BRIDGE-XXX], read delta.md first"
5. Claude Code executes, writes to outbox
6. Antigravity reads outbox, integrates, updates project-state.md + delta.md
```

---

## Task ID Convention

| Prefix | Agent | Example |
|--------|-------|---------|
| `BRIDGE-G` | Gemini (Antigravity) | BRIDGE-G001 |
| `BRIDGE-C` | Claude Code | BRIDGE-C001 |
| `BRIDGE-O` | OpenCode | BRIDGE-O001 |
| `BRIDGE-` | Cross-agent (numbered) | BRIDGE-002 |

---

## Directory Structure

```
aria-bridge/
├── BRIDGE.md                    ← Protocol spec (routing matrix, message format)
├── BRIDGE_GUIDE.md              ← This file (how-to guide)
├── bridge-daemon.sh             ← Background watcher
├── join-bridge.sh               ← Agent startup script
├── daemon.log                   ← Activity log
├── agents/
│   ├── gemini/
│   │   ├── inbox.md             ← Tasks for Antigravity
│   │   └── outbox.md            ← Results from Antigravity
│   ├── claude/
│   │   ├── inbox.md             ← Tasks for Claude Code
│   │   └── outbox.md            ← Results from Claude Code
│   └── opencode/
│       ├── inbox.md             ← Tasks for OpenCode
│       └── outbox.md            ← Results from OpenCode
├── shared-context/
│   ├── project-state.md         ← Full project state (source of truth)
│   ├── delta.md                 ← Only changes since last full read
│   └── context-hash.txt         ← Per-agent SHA hash for dedup
└── token-ledger/
    ├── gemini.json
    ├── claude.json
    └── opencode.json
```

---

## td-bridge — Task Management Wrapper

`td-bridge.sh` unifies the `td` task CLI with bridge mechanics in one script.

```bash
BRIDGE="/Users/apple/.gemini/antigravity/scratch/_scripts/aria-bridge"

# Session start: context-aware join (token dedup)
bash $BRIDGE/td-bridge.sh join

# Check what's in your inbox
bash $BRIDGE/td-bridge.sh check-inbox

# Convert a bridge inbox task → td issue
bash $BRIDGE/td-bridge.sh create-from-bridge

# Start td issue + mark bridge task IN_PROGRESS
bash $BRIDGE/td-bridge.sh start <td-id>

# Log progress to td + bridge outbox
bash $BRIDGE/td-bridge.sh log <td-id> "what I did"

# Handoff: td handoff + write bridge outbox result
bash $BRIDGE/td-bridge.sh handoff <td-id>

# Route a new task to another agent's inbox
bash $BRIDGE/td-bridge.sh route gemini "Research X and write plan"
bash $BRIDGE/td-bridge.sh route opencode "Compress project-state.md"

# Sync td board state → project-state.md
bash $BRIDGE/td-bridge.sh sync

# Combined td + bridge dashboard
bash $BRIDGE/td-bridge.sh status
```

**Agent identity** defaults to `claude`. Override with env var:
```bash
TD_BRIDGE_AGENT=opencode bash $BRIDGE/td-bridge.sh status
```

---

## APM + LOGIC_LOG Integration

The bridge should log all major decisions to the ARIA memory system:

**LOGIC_LOG** (`/Users/apple/.gemini/_scripts/LOGIC_LOG.md`):
- Log every new BRIDGE task created
- Log every outbox result integrated
- Format: `[TIMESTAMP] [ACT/REASON/VERIFY] bridge_task → description`

**APM State** (`/Users/apple/.gemini/antigravity/scratch/_scripts/appm_state.json`):
- Update `objective` to current project phase
- Update `current_subtask` to active BRIDGE task
- Update `last_updated` on every session

---

## Completed Tasks Log

| Task | Agent | Date | Result |
|------|-------|------|--------|
| BRIDGE-001 | Claude Code | 2026-02-18 | Calculator security audit — PASSED ✅ |
| BRIDGE-002 | Claude Code | 2026-02-18 | Desktop Commander MCP — needs session restart |
| BRIDGE-003 | OpenCode | 2026-02-18 | Delta reads verified — 54% token savings ✅ |
| BRIDGE-004 | Claude Code | 2026-02-18 | bridge-daemon.sh audit — SAFE ✅ |
| BRIDGE-005 | OpenCode | 2026-02-18 | Token ledger format review — 7 improvements proposed |
