# ARIA Bridge Protocol v3.0 — Unified Orchestration Hub

**Version**: 3.0 (Dual-Paradigm)
**Source**: `gnz16/aria-kernel-package` · `scripts/aria-bridge/`

---

## Agent Models

### Tool-Based Routing (Tri-Agent)

Routes tasks by **which IDE/tool handles it best**.

| Agent | Tool | Strengths |
|-------|------|-----------|
| **gemini** | Antigravity IDE | Planning, file edits, UI, research, MCP config |
| **claude** | Claude Code | Security audits, testing, git ops, autonomous tasks |
| **opencode** | OpenCode | Token optimization, refactoring, summarization |

### Role-Based Routing (Constellation)

Routes tasks by **which cognitive archetype the task needs**.

| Agent | Resonance | Role |
|-------|-----------|------|
| **Logician** | Apollo 100% | Architecture, schema, formal reasoning, type systems |
| **Oracle** | Dionysus 80% + Apollo 20% | Brainstorming, research, lateral thinking, reframing |
| **Auditor** | Hephaestus 70% + Athena 30% | Security audit, code review, vulnerability assessment |
| **Craftsman** | Hephaestus 80% + Athena 20% | Implementation, testing, debugging, production code |
| **Archivist** | Hephaestus 70% + Apollo 30% | Memory, context, documentation, shared-context sync |
| **Detective** | Apollo 60% + Athena 40% | Deduction, root cause analysis, hypothesis elimination |

### When to Use Which

| Scenario | Model | Example |
|----------|-------|---------|
| Cross-device file operations | Tri-Agent | "gemini: edit file X, claude: run tests" |
| IDE-specific capabilities | Tri-Agent | "opencode: compress context" |
| Complex multi-domain reasoning | Constellation | "logician: architect, craftsman: implement" |
| Specialized cognitive tasks | Constellation | "detective: investigate this bug" |

---

## Directory Structure

```
aria-bridge/
├── BRIDGE.md                     ← This file (v3.0)
├── aria-status.sh                ← Status dashboard (both models)
├── aria-assign.sh                ← Task assignment
├── aria-collect.sh               ← Result collection
├── aria-spawn.sh                 ← Constellation agent spawner (tmux)
├── aria-sync.sh                  ← Shared context sync
├── watch-bridge.sh               ← Live dashboard (watch -n 2)
├── evolution-log.md              ← Health audit history
├── td-bridge.sh                  ← Legacy tri-agent bridge
├── bridge-daemon.sh              ← Background watcher/router
├── join-bridge.sh                ← Agent startup script
├── agents/
│   ├── <agent>/
│   │   ├── inbox.md              ← Tasks for the agent
│   │   └── outbox.md             ← Results from the agent
├── agent-kernels/
│   └── <agent>.md                ← Per-agent CLAUDE.md for Constellation
├── hooks/
│   ├── session-start.sh          ← Self-healing: re-clone skills if broken
│   ├── post-session.sh           ← Memory size check + git status
│   ├── rotate-log.sh             ← Append entry to evolution log
│   ├── init-memory-git.sh        ← Bootstrap git versioning for memory
│   ├── scheduled-evolution.sh    ← Automated health check
│   └── install-cron.sh           ← Daily cron/launchd installer
├── mcp-server/
│   ├── server.js                 ← MCP server (6 tools, stdio transport)
│   ├── package.json
│   └── install.sh
├── shared-context/
│   ├── project-state.md          ← Full project state (source of truth)
│   ├── context-hash.txt          ← SHA per agent for deduplication
│   └── delta.md                  ← Delta changes since last full read
├── helpers/
│   ├── bridge_ledger.py          ← Token ledger updater
│   ├── bridge_status.py          ← Ledger display
│   └── bridge_sync.py            ← project-state sync
└── token-ledger/
    ├── gemini.json
    ├── claude.json
    └── opencode.json
```

---

## Token Deduplication Protocol

**Before reading `project-state.md`, every agent MUST:**

1. Read `shared-context/context-hash.txt`
2. Compare your hash against the `current:` hash
3. **Hash matches** → read `delta.md` only (~80% token savings)
4. **Hash differs** → read full `project-state.md`, update your entry

---

## Quick Reference — CLI Commands

```bash
# Status dashboard (auto-detects both agent models)
bash aria-status.sh

# Assign a task to any agent
bash aria-assign.sh <agent> <task-id> <priority> <task-file>

# Spawn a Constellation agent in tmux
bash aria-spawn.sh <agent> [working-dir]

# Collect results from all agent outboxes
bash aria-collect.sh [agent]

# Sync shared context after agents complete
bash aria-sync.sh "<summary>"

# Live dashboard
bash watch-bridge.sh

# Lifecycle hooks
bash hooks/session-start.sh       # Run at session start
bash hooks/post-session.sh        # Run at session end
bash hooks/rotate-log.sh          # Append to evolution log
bash hooks/scheduled-evolution.sh # Full health check
bash hooks/install-cron.sh        # Install daily health check
```

---

## Message Format

All `inbox.md` / `outbox.md` files use:

```yaml
---
FROM: [conductor | agent-name]
TO: [agent-name]
TASK_ID: [BRIDGE-XXX]
PRIORITY: [HIGH | MEDIUM | LOW]
STATUS: [PENDING | IN_PROGRESS | DONE | BLOCKED]
TIMESTAMP: [ISO 8601]
CONTEXT_HASH: [dedup hash]
---

## Task
[Clear description]

## Context
[Relevant background]

## Expected Output
[What the agent should produce]
```

---

## MCP Server (Optional)

The bridge can be accessed programmatically via MCP tools:

```bash
# Install dependencies
bash mcp-server/install.sh

# Register in your MCP config
# {"aria-bridge": {"command": "node", "args": ["/path/to/mcp-server/server.js"]}}
```

**Tools**: `bridge_status`, `bridge_assign`, `bridge_collect`, `bridge_sync`, `agent_inbox_read`, `agent_inbox_write`

---

*ARIA Bridge Protocol v3.0 — Dual-Paradigm Orchestration*
*Maintained by: Soheb Ganeriwala*
*Updated: 2026-02-24*
