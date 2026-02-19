---
name: session-isolation-manager
description: >-
  Create and manage ARIA sessions with fresh context tokens while maintaining
  cross-session memory recall. Enables clean workspace isolation without
  losing access to archived knowledge.
tags:
  - arria
  - session
  - isolation
  - memory
  - recall
triggers:
  - keyword: session
  - keyword: fresh
  - keyword: context
  - keyword: reset
  - keyword: archive
maintainer: ARIA Enhanced Team
version: 1.0.0
---

# Session Isolation Manager Skill

## What This Does

ARIA normally accumulates context in CONTINUITY.md across a session. This skill enables:

- **Fresh sessions**: Start with empty context token, no memory crowding
- **Persistent recall**: Even in fresh sessions, can search all archived sessions
- **Auto-archiving**: Clean separation between workstreams
- **Cross-session intelligence**: Patterns and resonance library remain accessible

## Session Types

| Type | Context Token | Volatile Memory | When to Use |
|------|---------------|-----------------|-------------|
| **fresh** | EMPTY | CLEARED | New project, no context carry |
| **continue** | PRESERVED | CONTINUOUS | Same workstream |
| **hybrid** | MINIMAL | SELECTIVE | Related work, need some context |

---

## Usage

```bash
# Start fresh session (recommended for new tasks)
aria-session new --objective "Build authentication system"

# List all sessions
aria-session list

# Archive current session
aria-session archive

# Search across all sessions (even from fresh)
aria-session search "JWT token strategy"

# Resume an archived session (read-only recall)
aria-session resume SESSION-2025-02-17-042

# Prune old sessions (30+ days)
aria-session prune --days 30
```

---

## Workflow Example

```bash
# Session 1: Auth work
$ aria-session new --objective "Implement OAuth2"
... work continues, CONTINUITY builds up ...
$ aria-session archive
✓ Session archived. CONTINUITY cleared.

# Session 2: Different project, fresh context
$ aria-session new --objective "Design dashboard"
Context: Clean. No auth memory floating. ✓

# But I can recall from Session 1:
User: "What auth pattern did we use last session?"
ARIA: [ Searches archives automatically ]
       "Found in SESSION-2025-02-17-042: OAuth2 with JWT, 15min expiry + refresh rotation"
Context: Still clean (only this response). ✓
```

---

## How It Works

### architecture

```
~/.opencode/
├── _scripts/                    # Global strategic files (always accessible)
│   ├── STRATEGIC_LEDGER.md     # Persistent across sessions
│   ├── RESONANCE_PATTERNS.md   # Learnings across all work
│   └── ...
├── _sessions/                   # Active sessions (isolated)
│   ├── SESSION-2025-02-18-001/
│   │   ├── appm_state.json     # Session-specific state
│   │   ├── CONTINUITY.md       # Volatile (cleared between sessions)
│   │   └── ...
└── _archives/                   # Archived sessions (searchable)
    ├── session_SESSION-2025-02-17-042_2025-02-18.md
    └── ...
```

### Session Isolation Guarantee

- **Context token**: Completely fresh (no previous conversation)
- **Session files**: Each session gets its own directory
- **Global memory**: Strategic insights, patterns, decisions (read-only)
- **Archives**: Searchable but not loaded into context automatically

---

## Environment Variables

These are set automatically when you use `aria-session new`:

- `ARIA_SESSION_ID` - Current session identifier
- `ARIA_SESSION_TYPE` - fresh | continue | hybrid
- `ARIA_SESSION_DIR` - Path to session directory

ARIA runtime (`session_runtime.py`) uses these to load correct files.

---

## Integration with RARV

### REASON Phase
- Check session type
- If fresh: consult cross-session index for relevant past patterns
- If recall needed: `runtime.search_across_sessions(query)` adds context

### ACT Phase
- All writes go to session-specific CONTINUITY.md
- Strategic insights promoted to global STRATEGIC_LEDGER

### REFLECT Phase
- Evaluate if session should be archived
- Update cross-session pattern library

### VERIFY Phase
- Verify search works: `aria-session search "test query"` returns results

---

## Memory Recall Triggers

ARIA automatically detects when to search archives:

```yaml
recall_triggers:
  - pattern: "last time we"
    action: "search previous sessions for context"
  - pattern: "previously we"
    action: "search previous sessions"
  - pattern: "what did we use for"
    action: "search across sessions"
  - pattern: "like before"
    action: "find similar prior work"
```

User can also explicitly request: `aria-session search "query"`

---

## Benefits

✅ **No context crowding** - Fresh start every new workstream
✅ **Knowledge persistence** - All past sessions searchable
✅ **Pattern learning** - Resonance library grows across sessions
✅ **Clean boundaries** - Sessions don't bleed into each other
✅ **Compliance** - Easy to delete/archive entire sessions (GDPR)

---

## Technical Details

### File Locations

- Session templates: `~/.opencode/_templates/fresh_session/`
- Active sessions: `~/.opencode/_sessions/`
- Archives: `~/.opencode/_archives/`
- Session index: `~/.opencode/_session_index.json`
- Runtime hook: `~/.opencode/session_runtime.py`

### Session Manager

`session_manager.py` handles lifecycle:
- `create_fresh_session(objective)` - New isolated session
- `archive_session(session_id)` - Archive with compression
- `search_across_sessions(query)` - Cross-session recall
- `prune_old_sessions(days)` - Cleanup

### ARIA Integration

ARIA code should use:
```python
from session_runtime import get_runtime
runtime = get_runtime()

# Load memory file (session-aware)
continuity = runtime.load_memory_file('CONTINUITY.md')

# Get recall context
if "last time" in user_query:
    recall = runtime.get_recall_context("topic")
    add_to_prompt(recall)

# Save (goes to session dir automatically)
runtime.save_memory_file('CONTINUITY.md', new_content)
```

---

## Commands Reference

| Command | Description |
|---------|-------------|
| `aria-session new --objective TEXT` | Create fresh session |
| `aria-session list` | Show all sessions |
| `aria-session archive` | Archive current session |
| `aria-session search QUERY` | Search across sessions |
| `aria-session resume ID` | Resume (attach) archived session |
| `aria-session prune --days N` | Delete old archives |

---

*ARIA v7.7.1-session-aware*
*Isolation without amnesia.*
