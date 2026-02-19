---
description: Systemic workflow for autonomous task execution with persistence and logic logging.
---

// turbo-all
# Autonomous Manager Workflow (v2 - RARV Integrated)

This workflow ensures ARIA maintains state, documents reasoning, and operates within safety guardrails using the **Reason-Act-Reflect-Verify (RARV)** cycle.

## 🕹️ The RARV Loop

For every iteration in an autonomous task, follow these mandatory steps:

### 1. REASON (Synchronize & Plan)
- **Read Memory**: Read `_scripts/CONTINUITY.md` (Volatile) and `_scripts/appm_state.json` (State).
- **Audit History**: Check `_scripts/LOGIC_LOG.md` for the last decision and "Mistakes & Learnings" in Continuity.
- **Document**: Append a new entry to `_scripts/LOGIC_LOG.md`.
    - Format: `## [Timestamp] [PHASE: REASON] [Subtask Name]`
    - Content: Detailed reasoning, tool selection, and expected outcome.

### 2. ACT (Secure Execution)
- **Security Guardrail**: Before running any bash command or accessing `.env`, run `_scripts/security-guardrails.sh`.
- **Primary Action**: Execute the core tool (e.g., `write_to_file`, `replace_file_content`, `run_command`).
- **Constraint**: Focus on ONE subtask. Do not over-extend context.

### 3. REFLECT (Internal Audit)
- **Analyze Outcome**: Check the tool output for success or failure.
- **Update Continuity**: Document any errors, unexpected behaviors, or new learnings in `_scripts/CONTINUITY.md` under "Mistakes & Learnings".
- **Update State**: Update `_scripts/appm_state.json` (current_subtask, progress, last_updated).

### 4. VERIFY (Validation & Persistence)
- **Test Work**: Run a verification command (tests, `ls`, `cat`, etc.) to confirm effectiveness.
- **Update Dashboard**: Run `python3 _scripts/generate-dashboard.py` to refresh the visual state.
- **Persistence**: Run `_scripts/backup-logic.sh` to sync state and log to the Desktop.
- **Save Point**: If on a git-enabled repo, create a `git checkpoint` for the completed subtask.

## 🛡️ Safety Controls
- **Dangerous Commands**: `rm -rf`, `sudo`, and base directory operations are BLOCKED unless explicitly approved via `notify_user`.
- **Secrets**: Never read `.env` files directly. Use `.env.sample`.
