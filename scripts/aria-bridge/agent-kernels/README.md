# Agent Kernels

Per-agent kernel Markdown files for the Constellation model.

When `aria-spawn.sh` spawns an agent, it copies `<agent>.md` from this directory
into the agent's working directory as `CLAUDE.md`, giving each agent its
specialized cognitive blend.

## Expected Files

| File | Agent | Archetype |
|------|-------|-----------|
| `logician.md` | The Logician | Apollo 100% |
| `oracle.md` | The Oracle | Dionysus 80% + Apollo 20% |
| `auditor.md` | The Auditor | Hephaestus 70% + Athena 30% |
| `craftsman.md` | The Craftsman | Hephaestus 80% + Athena 20% |
| `archivist.md` | The Archivist | Hephaestus 70% + Apollo 30% |

## Format

Each kernel file should be a minimal CLAUDE.md containing:
1. Agent identity and resonance blend
2. Task-specific instructions
3. Handoff protocol reference

These are intentionally compressed to minimize token usage per agent.
