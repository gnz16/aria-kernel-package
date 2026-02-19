# ARIA Agent Bridge Protocol v2.0
## Tri-Agent Resonance Hub

**Location**: `/Users/apple/.gemini/antigravity/scratch/_scripts/aria-bridge/`

Three agents share the **ARIA v7.7 kernel** and coordinate via this filesystem hub:

| Agent ID | Tool | Strengths |
|----------|------|-----------|
| **gemini** | Antigravity IDE | Planning, file edits, UI, research, MCP config |
| **claude** | Claude Code (PID 94992) | Security audits, testing, git ops, Loki autonomous tasks |
| **opencode** | OpenCode (PID 91861) | Token optimization, refactoring, Desktop Commander MCP |

---

## 📁 Directory Structure

```
aria-bridge/
├── BRIDGE.md                    ← This file (v2.0 protocol)
├── join-bridge.sh               ← Agent startup script
├── bridge-daemon.sh             ← Background watcher/router
├── agents/
│   ├── gemini/inbox.md          ← Tasks for Antigravity
│   ├── gemini/outbox.md         ← Results from Antigravity
│   ├── claude/inbox.md          ← Tasks for Claude Code
│   ├── claude/outbox.md         ← Results from Claude Code
│   ├── opencode/inbox.md        ← Tasks for OpenCode
│   └── opencode/outbox.md       ← Results from OpenCode
├── shared-context/
│   ├── project-state.md         ← Full project state (source of truth)
│   ├── context-hash.txt         ← SHA of last project-state.md per agent
│   └── delta.md                 ← Only changes since last full read
└── token-ledger/
    ├── gemini.json              ← Per-agent token tracking
    ├── claude.json
    └── opencode.json
```

---

## 🔑 Token Deduplication Protocol (CRITICAL)

**Before reading `project-state.md`, every agent MUST:**

1. Read `shared-context/context-hash.txt`
2. Compare the hash for your agent ID against your last-seen hash
3. **If hash matches** → read `delta.md` only (saves ~80% tokens)
4. **If hash differs** → read full `project-state.md`, update your hash entry

```bash
# Quick check (replace AGENT_ID with: gemini | claude | opencode)
grep "AGENT_ID" shared-context/context-hash.txt
```

---

## 📬 Message Format

All `inbox.md` / `outbox.md` files use:

```
---
FROM: [gemini | claude | opencode]
TO:   [gemini | claude | opencode]
TASK_ID: [BRIDGE-XXX]
PRIORITY: [HIGH | MEDIUM | LOW]
STATUS: [PENDING | IN_PROGRESS | DONE | BLOCKED]
TIMESTAMP: [ISO 8601]
TOKENS_SAVED: [delta | full]   ← log which read mode was used
---

## Task
[Clear description]

## Context
[Relevant files, background — be minimal, reference project-state.md for shared context]

## Expected Output
[What to produce]

## Handoff
[What to write to outbox when done]
```

---

## 🔄 Workflow

1. Any agent writes a task to the target agent's `agents/<target>/inbox.md`
2. `bridge-daemon.sh` detects the new PENDING task and notifies (via log)
3. Target agent reads inbox, sets STATUS=IN_PROGRESS, executes
4. Target agent writes result to its own `agents/<target>/outbox.md` with STATUS=DONE
5. Originating agent reads outbox, integrates result, updates `shared-context/project-state.md`
6. After updating project-state.md, compute new SHA and update `context-hash.txt`

---

## ⚡ Quick Start

```bash
# Join as any agent:
bash join-bridge.sh --agent gemini
bash join-bridge.sh --agent claude
bash join-bridge.sh --agent opencode

# Start background router:
bash bridge-daemon.sh --start

# Check token savings:
python3 /Users/apple/.gemini/antigravity/scratch/_scripts/token-tracker.py --report
```

---

## 🧠 Agent Roles & Routing Matrix

### Agent Specializations

| Agent | Primary Role | Core Strengths | Avoid |
|-------|-------------|----------------|-------|
| **gemini** (Antigravity) | 🔍 Research + Planning | Web search, implementation plans, MCP config, file edits, UI | Heavy code execution, long autonomous runs |
| **opencode** | 🗜️ Context Compression | Delta reads, token ledger, summarization, context trimming | Security audits, intensive coding |
| **claude** (Claude Code) | ⚙️ Heavy Execution | Intensive coding, security audits, git ops, testing, Loki Mode | Research, planning |

### Task Routing Rules

| Task Type | Send To | Reason |
|-----------|---------|--------|
| Web research, documentation lookup | **gemini** | Built-in search tools |
| Implementation plan creation | **gemini** | IDE integration, planning strength |
| MCP configuration | **gemini** | Direct config file access |
| Context summarization / compression | **opencode** | Proven 54% token savings via delta reads |
| Token ledger updates | **opencode** | Owns the token tracking pipeline |
| Shrinking project-state.md | **opencode** | Context compression specialty |
| Feature implementation | **claude** | Most capable for intensive autonomous work |
| Security audits | **claude** | Hephaestus+Athena blend, audit expertise |
| Git operations, testing | **claude** | CLI-native, Loki Mode for parallel tasks |
| Refactoring large codebases | **claude** | Long-running autonomous execution |

### Delegation Flow

```
User Request
    │
    ▼
gemini (Antigravity)
    │ researches + plans
    │ writes implementation plan
    │
    ├──► opencode: "Compress context, update delta.md"
    │         (before any heavy task to save tokens)
    │
    └──► claude: "Execute plan [BRIDGE-XXX]"
              (reads compressed context from opencode)
              (writes results back to outbox)
```

---

*Bridge v2.0 — ARIA v7.7 Constellation Phase — Established 2026-02-18*
