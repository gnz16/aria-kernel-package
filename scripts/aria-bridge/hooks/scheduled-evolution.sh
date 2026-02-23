#!/usr/bin/env bash
# scheduled-evolution.sh — Unattended ARIA health check for scheduled execution
# Checks that core ARIA components are present, then appends a status line to
# the evolution log via rotate-log.sh.
#
# Usage:
#   bash /root/.aria-bridge/hooks/scheduled-evolution.sh
#
# Schedule via cron (example — daily at 03:00):
#   0 3 * * * bash /root/.aria-bridge/hooks/scheduled-evolution.sh
#
# Output:
#   Stdout/stderr both redirected to LOG_FILE when run by cron.
#   When run interactively, output goes to terminal AND log file (tee).

set -uo pipefail

# ── Paths ─────────────────────────────────────────────────────────────────────
BRIDGE_DIR="/root/.aria-bridge"
SKILLS_DIR="/root/.aria-skills/skills"
CLAUDE_MD="/root/.claude/CLAUDE.md"
LOG_FILE="$BRIDGE_DIR/logs/scheduled-evolution.log"
ROTATE_LOG="$BRIDGE_DIR/hooks/rotate-log.sh"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# ── Ensure log directory exists ────────────────────────────────────────────────
mkdir -p "$BRIDGE_DIR/logs"

# ── Internal log helper ────────────────────────────────────────────────────────
_log() {
  echo "[$TIMESTAMP] $*" >> "$LOG_FILE"
}

_log "=== Scheduled evolution health check started ==="

# ── Health checks ─────────────────────────────────────────────────────────────
PASS=0
FAIL=0
NOTES=""

check() {
  local label="$1"
  local condition="$2"   # "exists_file", "exists_dir", or "exists_cmd"
  local target="$3"

  local ok=false
  case "$condition" in
    exists_file) [[ -f "$target" ]] && ok=true ;;
    exists_dir)  [[ -d "$target" ]] && ok=true ;;
    exists_cmd)  command -v "$target" >/dev/null 2>&1 && ok=true ;;
  esac

  if $ok; then
    _log "  PASS  $label"
    PASS=$(( PASS + 1 ))
  else
    _log "  FAIL  $label — $target not found"
    NOTES="${NOTES}FAIL: $label ($target); "
    FAIL=$(( FAIL + 1 ))
  fi
}

# Core config
check "CLAUDE.md present"            exists_file "$CLAUDE_MD"
check "Skills directory present"     exists_dir  "$SKILLS_DIR"

# Bridge scripts
check "aria-status.sh present"       exists_file "$BRIDGE_DIR/aria-status.sh"
check "aria-assign.sh present"       exists_file "$BRIDGE_DIR/aria-assign.sh"
check "aria-collect.sh present"      exists_file "$BRIDGE_DIR/aria-collect.sh"
check "aria-sync.sh present"         exists_file "$BRIDGE_DIR/aria-sync.sh"
check "aria-spawn.sh present"        exists_file "$BRIDGE_DIR/aria-spawn.sh"

# Hooks
check "rotate-log.sh present"        exists_file "$ROTATE_LOG"
check "session-start.sh present"     exists_file "$BRIDGE_DIR/hooks/session-start.sh"
check "post-session.sh present"      exists_file "$BRIDGE_DIR/hooks/post-session.sh"

# Evolution log itself
check "evolution-log.md present"     exists_file "$BRIDGE_DIR/evolution-log.md"

# Agent inboxes
for agent in logician oracle auditor craftsman archivist; do
  check "Agent $agent inbox present" exists_file "$BRIDGE_DIR/agents/$agent/inbox.md"
done

# ── Summary ───────────────────────────────────────────────────────────────────
TOTAL=$(( PASS + FAIL ))
STATUS_LINE="Health check: $PASS/$TOTAL passed"
[[ $FAIL -gt 0 ]] && STATUS_LINE="$STATUS_LINE | FAILURES: $NOTES"

_log "$STATUS_LINE"
_log "=== Health check complete ==="

# ── Append to evolution log via rotate-log.sh ─────────────────────────────────
if [[ -x "$ROTATE_LOG" ]] || [[ -f "$ROTATE_LOG" ]]; then
  bash "$ROTATE_LOG" \
    "Scheduled Health Check" \
    "$STATUS_LINE" \
    >> "$LOG_FILE" 2>&1
  _log "Evolution log updated via rotate-log.sh"
else
  _log "WARNING: rotate-log.sh not found at $ROTATE_LOG — skipping log rotation"
fi

# ── Exit with error if any checks failed ──────────────────────────────────────
if [[ $FAIL -gt 0 ]]; then
  _log "EXIT 1 — $FAIL check(s) failed"
  exit 1
fi

_log "EXIT 0 — all checks passed"
exit 0
