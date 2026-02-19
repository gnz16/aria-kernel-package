#!/bin/bash
# ============================================================
# ARIA Agent Bridge Daemon v2.0
# Watches per-agent inbox dirs and outboxes for all three agents
# Updated 2026-02-19 to support directory-based inbox structure
# Usage:
#   bridge-daemon.sh --start    Start daemon in background
#   bridge-daemon.sh --stop     Stop running daemon
#   bridge-daemon.sh --status   Show daemon status + recent activity
#   bridge-daemon.sh --watch    Run in foreground (verbose)
# ============================================================

BRIDGE_DIR="/Users/apple/.gemini/antigravity/scratch/_scripts/aria-bridge"
PID_FILE="$BRIDGE_DIR/.daemon.pid"
LOG_FILE="$BRIDGE_DIR/daemon.log"
AGENTS=("claude" "gemini" "opencode")
STATE_FILE="$BRIDGE_DIR/shared-context/project-state.md"

# ── Colors ──────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

print_header() {
    echo -e "${BOLD}${CYAN}"
    echo "  ╔══════════════════════════════════════════╗"
    echo "  ║     🌉 ARIA Agent Bridge Daemon v2.0     ║"
    echo "  ║     Tri-Agent Directory Inbox Watcher    ║"
    echo "  ╚══════════════════════════════════════════╝"
    echo -e "${RESET}"
}

# ── Hash helpers ─────────────────────────────────────────────
md5_file() { md5 -q "$1" 2>/dev/null || md5sum "$1" 2>/dev/null | awk '{print $1}'; }

# Compute a combined hash for all *.md files in a directory
dir_hash() {
    local dir="$1"
    ls "$dir"/*.md 2>/dev/null | sort | xargs md5 -q 2>/dev/null | md5 -q 2>/dev/null || echo "empty"
}

# ── Watch loop (runs as daemon) ──────────────────────────────
watch_loop() {
    log "DAEMON v2.0 STARTED (PID $$)"

    # Initialise baseline hashes
    declare -A INBOX_HASH OUTBOX_HASH
    for a in "${AGENTS[@]}"; do
        INBOX_HASH[$a]=$(dir_hash "$BRIDGE_DIR/agents/$a/inbox")
        OUTBOX_HASH[$a]=$(md5_file "$BRIDGE_DIR/agents/$a/outbox.md" 2>/dev/null || echo "absent")
    done
    local state_hash=$(md5_file "$STATE_FILE" 2>/dev/null || echo "absent")

    while true; do
        for a in "${AGENTS[@]}"; do
            # ── Inbox directory: detect new/changed task files
            cur=$(dir_hash "$BRIDGE_DIR/agents/$a/inbox")
            if [ "$cur" != "${INBOX_HASH[$a]}" ] && [ -n "${INBOX_HASH[$a]}" ]; then
                # Find the newest PENDING file
                newest=$(ls -t "$BRIDGE_DIR/agents/$a/inbox/"*.md 2>/dev/null | head -1)
                if [ -n "$newest" ]; then
                    task_id=$(grep "^TASK_ID:" "$newest" | head -1 | awk '{print $2}')
                    status=$(grep "^STATUS:" "$newest" | head -1 | awk '{print $2}')
                    log "📬 INBOX[$a] changed — task: $task_id [$status]"
                else
                    log "📬 INBOX[$a] changed (no tasks found)"
                fi
                INBOX_HASH[$a]="$cur"
            fi

            # ── Outbox: detect new results
            cur=$(md5_file "$BRIDGE_DIR/agents/$a/outbox.md" 2>/dev/null || echo "absent")
            if [ "$cur" != "${OUTBOX_HASH[$a]}" ] && [ "${OUTBOX_HASH[$a]}" != "absent" ]; then
                task_id=$(grep "^TASK_ID:" "$BRIDGE_DIR/agents/$a/outbox.md" | head -1 | awk '{print $2}')
                log "📤 OUTBOX[$a] updated — task: $task_id"
                OUTBOX_HASH[$a]="$cur"
            elif [ "$cur" != "${OUTBOX_HASH[$a]}" ]; then
                OUTBOX_HASH[$a]="$cur"
            fi
        done

        # ── Shared context: detect project-state changes
        cur=$(md5_file "$STATE_FILE" 2>/dev/null || echo "absent")
        if [ "$cur" != "$state_hash" ] && [ "$state_hash" != "absent" ]; then
            log "🗂️  project-state.md updated"
            state_hash="$cur"
        elif [ "$cur" != "$state_hash" ]; then
            state_hash="$cur"
        fi

        sleep 5
    done
}

# ── Commands ─────────────────────────────────────────────────
cmd_start() {
    print_header
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
        echo -e "  ${YELLOW}⚠️  Daemon already running (PID $(cat "$PID_FILE"))${RESET}"
        return 0
    fi

    # Ensure directories exist
    for a in "${AGENTS[@]}"; do
        mkdir -p "$BRIDGE_DIR/agents/$a/inbox"
    done
    mkdir -p "$BRIDGE_DIR/shared-context"

    # Start watch loop in background
    watch_loop &
    echo $! > "$PID_FILE"
    log "DAEMON STARTED by user (PID $!)"

    echo -e "  ${GREEN}✅ Bridge daemon started (PID $!)${RESET}"
    echo -e "  ${CYAN}📁 Bridge dir: $BRIDGE_DIR${RESET}"
    echo -e "  ${CYAN}📋 Log file:   $LOG_FILE${RESET}"
    echo ""
    echo -e "  ${BOLD}Watching (all agents):${RESET}"
    for a in "${AGENTS[@]}"; do
        echo -e "    📬 agents/$a/inbox/*.md"
        echo -e "    📤 agents/$a/outbox.md"
    done
    echo ""
    echo -e "  Run ${BOLD}bridge-daemon.sh --status${RESET} to check activity"
}

cmd_stop() {
    print_header
    if [ ! -f "$PID_FILE" ]; then
        echo -e "  ${YELLOW}⚠️  No daemon PID file found — daemon may not be running${RESET}"
        return 0
    fi
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID"
        rm -f "$PID_FILE"
        log "DAEMON STOPPED by user"
        echo -e "  ${RED}🛑 Daemon stopped (was PID $PID)${RESET}"
    else
        echo -e "  ${YELLOW}⚠️  Daemon (PID $PID) was not running — cleaning up${RESET}"
        rm -f "$PID_FILE"
    fi
}

cmd_status() {
    print_header
    echo -e "  ${BOLD}── Daemon Status ──────────────────────────────${RESET}"

    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
        echo -e "  ${GREEN}● RUNNING${RESET} (PID $(cat "$PID_FILE"))"
    else
        echo -e "  ${RED}● STOPPED${RESET}"
    fi

    echo ""
    echo -e "  ${BOLD}── Inbox Status (all agents) ──────────────────${RESET}"
    for a in "${AGENTS[@]}"; do
        inbox_dir="$BRIDGE_DIR/agents/$a/inbox"
        files=("$inbox_dir"/*.md)
        if [ -e "${files[0]}" ]; then
            for f in "${files[@]}"; do
                task=$(grep "^TASK_ID:" "$f" | head -1 | awk '{print $2}')
                status=$(grep "^STATUS:" "$f" | head -1 | awk '{print $2}')
                echo -e "  📬 $a: ${YELLOW}$task${RESET} [${BOLD}$status${RESET}]"
            done
        else
            echo -e "  📬 $a: ${CYAN}(empty)${RESET}"
        fi
    done

    echo ""
    echo -e "  ${BOLD}── Recent Activity (last 10 log entries) ──────${RESET}"
    if [ -f "$LOG_FILE" ]; then
        tail -10 "$LOG_FILE" | while read -r line; do
            echo -e "  ${CYAN}$line${RESET}"
        done
    else
        echo -e "  ${YELLOW}  (no log yet)${RESET}"
    fi
    echo ""
}

cmd_watch() {
    print_header
    echo -e "  ${BOLD}Running in foreground — Ctrl+C to stop${RESET}"
    echo ""
    watch_loop
}

# ── Entry point ───────────────────────────────────────────────
case "$1" in
    --start)  cmd_start ;;
    --stop)   cmd_stop ;;
    --status) cmd_status ;;
    --watch)  cmd_watch ;;
    *)
        echo "Usage: bridge-daemon.sh [--start|--stop|--status|--watch]"
        echo ""
        echo "  --start   Start the bridge daemon in background"
        echo "  --stop    Stop the running daemon"
        echo "  --status  Show daemon status and recent activity"
        echo "  --watch   Run in foreground (verbose mode)"
        ;;
esac
