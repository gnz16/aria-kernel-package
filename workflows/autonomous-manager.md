---
description: Systemic workflow for autonomous task execution with persistence and logic logging.
---

// turbo-all
# Autonomous Manager Workflow

This workflow ensures ARIA maintains state and documents reasoning during complex, multi-step tasks.

## 🕹️ The APPM Loop

Follow these steps for every turn in an autonomous task:

### 1. Synchronize State
- Read `_scripts/appm_state.json` to understand the current `subtasks` and `progress`.
- Check `_scripts/LOGIC_LOG.md` for the last decision made.

### 2. Document Reasoning
- Before taking any action, append a new entry to `_scripts/LOGIC_LOG.md`.
- Format: `## [Timestamp] [Subtask Name]`.
- Include: Reasoning, expected outcome, and tools to be used.

### 3. Execute & Update
- Execute the necessary tools to complete the current `subtask`.
- Update `_scripts/appm_state.json` with the results:
    - Update `current_subtask`.
    - Move completed subtasks to `completed_subtasks`.
    - Update `last_updated`.

### 4. Persist & Backup
- Run `_scripts/backup-logic.sh` to sync the state and log to the Desktop.

### 5. Evaluate
- Determine if the global `objective` is met.
- If not, identify the next `subtask` and repeat the loop.

## 🛡️ Safety Controls
- If a high-risk command is required, use `notify_user` to pause and get approval.
- Ensure the state is saved BEFORE and AFTER any high-risk operation.
