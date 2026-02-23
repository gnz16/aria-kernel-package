# ARIA Constellation Bridge v2.0
## Multi-Agent Orchestration Hub

---

## Agents

| Agent | Resonance | Role |
|-------|-----------|------|
| **Logician** | Apollo 100% | Architecture, schema, formal reasoning, type systems |
| **Oracle** | Dionysus 80% + Apollo 20% | Brainstorming, research, lateral thinking, reframing |
| **Auditor** | Hephaestus 70% + Athena 30% | Security audit, code review, vulnerability assessment |
| **Craftsman** | Hephaestus 80% + Athena 20% | Implementation, testing, debugging, production code |
| **Archivist** | Hephaestus 70% + Apollo 30% | Memory, context, documentation, shared-context maintenance |

---

## Task Routing

| Task Type | Agent |
|-----------|-------|
| System architecture, API design, schema | Logician |
| Feature brainstorm, UX, problem reframing | Oracle |
| Security audit, code review, risk assessment | Auditor |
| Feature implementation, testing, debugging | Craftsman |
| Documentation, memory compression, context sync | Archivist |
| Multi-domain (complexity >7) | Decompose → parallel dispatch |

---

## Workflow

```
User Request
    │
    ▼
Conductor (you, main Claude session)
    │ decompose task by domain
    │
    ├──► Archivist: "Compress context, update delta.md" (optional, before heavy tasks)
    │
    ├──► Logician: architecture subtask
    ├──► Oracle: brainstorm subtask        } parallel when independent
    ├──► Craftsman: implementation subtask }
    │
    ▼
Collect outboxes → integrate → sync shared-context → DONE
```

---

## Commands

```bash
# Check status of all agents
bash /root/.aria-bridge/aria-status.sh

# Spawn an agent in tmux
bash /root/.aria-bridge/aria-spawn.sh <agent>
# agents: logician | oracle | auditor | craftsman | archivist

# Assign a task
bash /root/.aria-bridge/aria-assign.sh <agent> <TASK-ID> <PRIORITY> <task.md>
# priority: HIGH | MEDIUM | LOW

# Collect results from outboxes
bash /root/.aria-bridge/aria-collect.sh [agent]

# Sync shared context after results integrated
bash /root/.aria-bridge/aria-sync.sh "what changed"
```

---

## Directory Structure

```
/root/.aria-bridge/
├── BRIDGE.md                        ← This file
├── aria-spawn.sh                    ← Spawn agent in tmux (claude CLI)
├── aria-assign.sh                   ← Write task to agent inbox
├── aria-status.sh                   ← Status dashboard
├── aria-collect.sh                  ← Collect outbox results + feed Archivist
├── aria-sync.sh                     ← Sync shared context + hash
├── watch-bridge.sh                  ← Live dashboard (watch -n 2)
├── evolution-log.md                 ← Versioned system change log
├── hooks/
│   ├── session-start.sh             ← Startup guard: re-clone skills if missing
│   ├── post-session.sh              ← Memory check + compression reminder
│   ├── rotate-log.sh                ← Append timestamped entry to evolution log
│   └── init-memory-git.sh           ← One-time: init git versioning on memory/
├── agent-kernels/
│   ├── logician.md                  ← Role CLAUDE.md for Logician
│   ├── oracle.md                    ← Role CLAUDE.md for Oracle
│   ├── auditor.md                   ← Role CLAUDE.md for Auditor
│   ├── craftsman.md                 ← Role CLAUDE.md for Craftsman
│   └── archivist.md                 ← Role CLAUDE.md for Archivist
├── agents/
│   ├── logician/{inbox.md,outbox.md}
│   ├── oracle/{inbox.md,outbox.md}
│   ├── auditor/{inbox.md,outbox.md}
│   ├── craftsman/{inbox.md,outbox.md}
│   └── archivist/{inbox.md,outbox.md}
└── shared-context/
    ├── project-state.md             ← Source of truth
    ├── delta.md                     ← Changes since last full read
    └── context-hash.txt             ← Per-agent staleness tracking
```

---

## Message Format (inbox/outbox)

```markdown
---
FROM: conductor
TO: craftsman
TASK_ID: BRIDGE-C001
PRIORITY: HIGH
STATUS: PENDING
TIMESTAMP: 2026-02-19T00:00:00Z
CONTEXT_HASH: <sha256>
---

## Task
[Clear, specific description]

## Context
Read delta.md first. Key files: [list only what's needed]

## Expected Output
[What to produce]

## Handoff
Write result to: /root/.aria-bridge/agents/craftsman/outbox.md
```

---

## Task ID Convention

| Prefix | Agent | Example |
|--------|-------|---------|
| BRIDGE-L | Logician | BRIDGE-L001 |
| BRIDGE-O | Oracle | BRIDGE-O001 |
| BRIDGE-A | Auditor | BRIDGE-A001 |
| BRIDGE-C | Craftsman | BRIDGE-C001 |
| BRIDGE-R | Archivist | BRIDGE-R001 |
| BRIDGE- | Cross-agent | BRIDGE-001 |

---

*ARIA Constellation Bridge v2.0 — Adapted from gnz16/aria-kernel-package*
*Established: 2026-02-19*
