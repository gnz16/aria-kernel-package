#!/bin/bash
# ============================================================
# td-bridge.sh — ARIA Bridge + td Task Management Wrapper
# Integrates the `td` CLI with the ARIA Agent Bridge Protocol v2.0
#
# Usage:
#   td-bridge check-inbox               Check your agent's inbox for pending tasks
#   td-bridge create-from-bridge        Convert bridge inbox task → td issue
#   td-bridge start <td-id>             Start td issue + mark bridge task IN_PROGRESS
#   td-bridge log <td-id> "msg"         Log to td + append to bridge outbox
#   td-bridge handoff <td-id>           td handoff + write bridge outbox result
#   td-bridge route <agent> <title>     Write a task to another agent's inbox
#   td-bridge sync                      Export td board state → project-state.md
#   td-bridge status                    Combined td + bridge dashboard
#   td-bridge join                      Read context using token dedup protocol
# ============================================================

BRIDGE_DIR="/Users/apple/.gemini/antigravity/scratch/_scripts/aria-bridge"
HELPERS_DIR="$BRIDGE_DIR/helpers"
AGENT="${TD_BRIDGE_AGENT:-claude}"   # Default agent identity; override with env var
STATE_FILE="$BRIDGE_DIR/shared-context/project-state.md"
DELTA_FILE="$BRIDGE_DIR/shared-context/delta.md"
HASH_FILE="$BRIDGE_DIR/shared-context/context-hash.txt"
INBOX_DIR="$BRIDGE_DIR/agents/$AGENT/inbox"
OUTBOX="$BRIDGE_DIR/agents/$AGENT/outbox.md"
LEDGER="$BRIDGE_DIR/token-ledger/$AGENT.json"
DAEMON_PID="$BRIDGE_DIR/.daemon.pid"

# Ensure inbox directory exists
mkdir -p "$INBOX_DIR"

# ── Colors ───────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BLUE='\033[0;34m'; BOLD='\033[1m'; RESET='\033[0m'
MAGENTA='\033[0;35m'

# ── Utilities ─────────────────────────────────────────────────
ts() { date '+%Y-%m-%dT%H:%M:%S%z'; }

md5_file() {
    md5 -q "$1" 2>/dev/null || md5sum "$1" 2>/dev/null | awk '{print $1}'
}

# Cross-platform sed in-place edit
portable_sed_i() {
    if [[ "$(uname)" == "Darwin" ]]; then
        sed -i '' "$@"
    else
        sed -i "$@"
    fi
}

print_header() {
    echo -e "${BOLD}${CYAN}"
    echo "  ╔══════════════════════════════════════════════╗"
    echo "  ║  🌉 td-bridge — ARIA Bridge + td Wrapper     ║"
    echo "  ║  Agent: ${BOLD}${MAGENTA}${AGENT}${CYAN}$(printf '%*s' $((27 - ${#AGENT})) '')║"
    echo "  ╚══════════════════════════════════════════════╝"
    echo -e "${RESET}"
}

separator() { echo -e "${CYAN}  ─────────────────────────────────────────────${RESET}"; }

# Get the newest PENDING task file from an agent's inbox queue
get_active_inbox_task() {
    local inbox_dir="${1:-$INBOX_DIR}"
    ls -t "$inbox_dir"/*.md 2>/dev/null | while read -r f; do
        if grep -q "STATUS: PENDING\|STATUS: IN_PROGRESS" "$f" 2>/dev/null; then
            echo "$f"
            return
        fi
    done
}

require_td() {
    if ! command -v td &>/dev/null; then
        echo -e "${RED}❌ td CLI not found in PATH${RESET}"
        exit 1
    fi
}

# ── Token Deduplication ───────────────────────────────────────
# Returns "delta" or "full" and prints context
read_context() {
    if [ ! -f "$STATE_FILE" ]; then
        echo -e "${YELLOW}⚠️  project-state.md not found — skipping context read${RESET}"
        return
    fi

    CURRENT_HASH=$(md5_file "$STATE_FILE")
    LAST_HASH=$(grep "^$AGENT:" "$HASH_FILE" 2>/dev/null | cut -d: -f2 | tr -d ' ')

    if [[ "$CURRENT_HASH" == "$LAST_HASH" && -n "$LAST_HASH" ]]; then
        echo -e "${GREEN}⚡ TOKEN DEDUP: project-state unchanged — reading delta only${RESET}"
        echo ""
        cat "$DELTA_FILE" 2>/dev/null || echo "(no delta)"
        _update_ledger "delta"
    else
        echo -e "${BLUE}📋 Full project state (hash changed or first read):${RESET}"
        echo ""
        cat "$STATE_FILE"
        # Update this agent's hash
        if grep -q "^$AGENT:" "$HASH_FILE" 2>/dev/null; then
            portable_sed_i "s|^$AGENT:.*|$AGENT: $CURRENT_HASH|" "$HASH_FILE"
        else
            echo "$AGENT: $CURRENT_HASH" >> "$HASH_FILE"
        fi
        _update_ledger "full"
    fi
}

# Update token ledger entry
_update_ledger() {
    local mode="$1"
    [ ! -f "$LEDGER" ] && return
    python3 "$HELPERS_DIR/bridge_ledger.py" "$LEDGER" "$mode" 2>/dev/null
}

# Mark project-state as stale for other agents
_mark_others_stale() {
    local agents=("claude" "gemini" "opencode")
    for a in "${agents[@]}"; do
        [ "$a" == "$AGENT" ] && continue
        if grep -q "^$a:" "$HASH_FILE" 2>/dev/null; then
            portable_sed_i "s|^$a:.*|$a: stale|" "$HASH_FILE"
        else
            echo "$a: stale" >> "$HASH_FILE"
        fi
    done
}

# ── Bridge Message Writer ─────────────────────────────────────
write_bridge_message() {
    local target="$1"
    local task_id="$2"
    local priority="${3:-MEDIUM}"
    local status="${4:-PENDING}"
    local title="$5"
    local body="$6"
    local target_inbox_dir="$BRIDGE_DIR/agents/$target/inbox"
    mkdir -p "$target_inbox_dir"
    local target_inbox_file="$target_inbox_dir/${task_id}.md"

    cat > "$target_inbox_file" <<EOF
---
FROM: $AGENT
TO: $target
TASK_ID: $task_id
PRIORITY: $priority
STATUS: $status
TIMESTAMP: $(ts)
TOKENS_SAVED: delta
---

## Task
$title

## Context
See \`shared-context/delta.md\` for latest project state.

$body

## Handoff
Write results to: agents/$target/outbox.md with STATUS: DONE
EOF

    echo -e "${GREEN}✅ Task written to $target's inbox: $task_id${RESET}"
    echo -e "   ${CYAN}File: $target_inbox_file${RESET}"
}

# Write result to own outbox
write_outbox() {
    local task_id="$1"
    local status="${2:-DONE}"
    local result="$3"

    cat > "$OUTBOX" <<EOF
---
FROM: $AGENT
TASK_ID: $task_id
STATUS: $status
TIMESTAMP: $(ts)
---

## Result

$result
EOF
    echo -e "${GREEN}✅ Result written to outbox: $task_id [$status]${RESET}"
}

# ── Commands ──────────────────────────────────────────────────

cmd_check_inbox() {
    print_header
    echo -e "${BOLD}── Your Inbox ($AGENT) ──────────────────────────────${RESET}"
    echo ""
    local task_files=("$INBOX_DIR"/*.md)
    if [ ! -e "${task_files[0]}" ]; then
        echo -e "  ${CYAN}(inbox is empty)${RESET}"
        return
    fi

    local count=0
    for tf in "${task_files[@]}"; do
        local t_id=$(grep "^TASK_ID:" "$tf" | head -1 | awk '{print $2}')
        local t_status=$(grep "^STATUS:" "$tf" | head -1 | awk '{print $2}')
        local t_from=$(grep "^FROM:" "$tf" | head -1 | awk '{print $2}')
        local t_prio=$(grep "^PRIORITY:" "$tf" | head -1 | awk '{print $2}')
        echo -e "  ${YELLOW}$t_id${RESET} | From: $t_from | Priority: $t_prio | Status: ${BOLD}$t_status${RESET}"
        count=$((count + 1))
    done

    echo ""
    echo -e "  ${CYAN}Total: $count task(s) in queue${RESET}"

    # Show details of the active (newest PENDING/IN_PROGRESS) task
    local active_file=$(get_active_inbox_task)
    if [ -n "$active_file" ]; then
        echo ""
        separator
        echo -e "  ${BOLD}Active task details:${RESET}"
        cat "$active_file"
        echo ""
        local active_status=$(grep "^STATUS:" "$active_file" | head -1 | awk '{print $2}')
        if [ "$active_status" == "PENDING" ]; then
            echo -e "  ${YELLOW}💡 To start: td-bridge start <td-id> (or create-from-bridge to make a new td issue)${RESET}"
        fi
    fi
}

cmd_create_from_bridge() {
    require_td
    print_header

    local active_file=$(get_active_inbox_task)
    if [ -z "$active_file" ]; then
        echo -e "${YELLOW}⚠️  No inbox task found${RESET}"
        exit 1
    fi

    TASK_ID=$(grep "^TASK_ID:" "$active_file" | head -1 | awk '{print $2}')
    PRIORITY=$(grep "^PRIORITY:" "$active_file" | head -1 | awk '{print $2}')
    FROM=$(grep "^FROM:" "$active_file" | head -1 | awk '{print $2}')

    # Extract task title (line after "## Task")
    TITLE=$(awk '/^## Task/{getline; print; exit}' "$active_file")
    [ -z "$TITLE" ] && TITLE="Bridge task $TASK_ID from $FROM"

    # Map priority
    local td_priority="medium"
    case "$PRIORITY" in
        HIGH)   td_priority="high" ;;
        LOW)    td_priority="low" ;;
        MEDIUM) td_priority="medium" ;;
    esac

    echo -e "${BOLD}Creating td issue from $TASK_ID...${RESET}"
    echo -e "  Title:    $TITLE"
    echo -e "  Priority: $td_priority"
    echo ""

    # Create the td issue with bridge task as note
    TD_OUTPUT=$(td add "$TITLE [bridge:$TASK_ID]" --priority "$td_priority" 2>&1)
    echo "$TD_OUTPUT"

    # Extract new issue ID
    TD_ID=$(echo "$TD_OUTPUT" | grep -oE '#[0-9]+' | head -1 | tr -d '#')

    if [ -n "$TD_ID" ]; then
        echo ""
        echo -e "${GREEN}✅ Created td issue #$TD_ID for bridge task $TASK_ID${RESET}"
        echo -e "${CYAN}   Next: td-bridge start $TD_ID${RESET}"
    fi
}

cmd_start() {
    require_td
    local td_id="$1"
    [ -z "$td_id" ] && { echo "Usage: td-bridge start <td-id>"; exit 1; }

    print_header
    echo -e "${BOLD}Starting td issue #$td_id...${RESET}"
    td start "$td_id"

    # If there's a pending bridge task, mark it IN_PROGRESS
    local active_file=$(get_active_inbox_task)
    if [ -n "$active_file" ] && grep -q "STATUS: PENDING" "$active_file"; then
        TASK_ID=$(grep "^TASK_ID:" "$active_file" | head -1 | awk '{print $2}')
        portable_sed_i "s/STATUS: PENDING/STATUS: IN_PROGRESS/" "$active_file"
        echo ""
        echo -e "${GREEN}✅ Bridge task $TASK_ID marked IN_PROGRESS${RESET}"
    fi

    echo ""
    echo -e "${CYAN}💡 Use 'td log $td_id \"msg\"' or 'td-bridge log $td_id \"msg\"' to track progress${RESET}"
}

cmd_log() {
    require_td
    local td_id="$1"
    local msg="$2"
    [ -z "$td_id" ] || [ -z "$msg" ] && { echo "Usage: td-bridge log <td-id> \"msg\""; exit 1; }

    td log "$td_id" "$msg"

    # Also append to outbox as running note
    if [ -f "$OUTBOX" ]; then
        echo "" >> "$OUTBOX"
        echo "**LOG $(ts):** $msg" >> "$OUTBOX"
    fi
}

cmd_handoff() {
    require_td
    local td_id="$1"
    [ -z "$td_id" ] && { echo "Usage: td-bridge handoff <td-id>"; exit 1; }

    print_header
    echo -e "${BOLD}Running td handoff for #$td_id...${RESET}"
    echo ""

    # Capture td handoff output
    HANDOFF_OUTPUT=$(td handoff "$td_id" 2>&1)
    echo "$HANDOFF_OUTPUT"

    # Get bridge task ID from active inbox task
    local active_file=$(get_active_inbox_task)
    TASK_ID="BRIDGE-???"
    if [ -n "$active_file" ]; then
        TASK_ID=$(grep "^TASK_ID:" "$active_file" | head -1 | awk '{print $2}')
        [ -z "$TASK_ID" ] && TASK_ID="BRIDGE-???"
    fi

    # Write to bridge outbox
    echo ""
    echo -e "${BOLD}Writing to bridge outbox...${RESET}"
    write_outbox "$TASK_ID" "DONE" "$(echo "$HANDOFF_OUTPUT" | head -30)"

    # Mark bridge task DONE in inbox
    if [ -n "$active_file" ]; then
        portable_sed_i "s/STATUS: IN_PROGRESS/STATUS: DONE/" "$active_file"
        portable_sed_i "s/STATUS: PENDING/STATUS: DONE/" "$active_file"
    fi

    echo ""
    echo -e "${GREEN}✅ td handoff + bridge outbox complete for $TASK_ID${RESET}"
    echo -e "${CYAN}💡 Next: update project-state.md, then run 'td-bridge sync'${RESET}"
}

cmd_route() {
    local target="$1"
    local title="$2"
    shift 2
    local body="$*"
    [ -z "$target" ] || [ -z "$title" ] && {
        echo "Usage: td-bridge route <agent> \"title\" [body]"
        echo "  Agents: claude | gemini | opencode"
        exit 1
    }

    # Validate target agent
    if [[ "$target" != "claude" && "$target" != "gemini" && "$target" != "opencode" ]]; then
        echo -e "${RED}❌ Unknown agent: $target. Use: claude | gemini | opencode${RESET}"
        exit 1
    fi

    # Auto-generate task ID
    LAST_ID=$(grep -oE 'BRIDGE-[GCO]?[0-9]+' "$BRIDGE_DIR/shared-context/project-state.md" 2>/dev/null | \
              grep -oE '[0-9]+' | sort -n | tail -1)
    NEXT_NUM=$(( ${LAST_ID:-0} + 1 ))
    printf -v NEXT_NUM "%03d" "$NEXT_NUM"

    # Agent prefix
    case "$target" in
        claude)   PREFIX="BRIDGE-C" ;;
        gemini)   PREFIX="BRIDGE-G" ;;
        opencode) PREFIX="BRIDGE-O" ;;
    esac
    TASK_ID="${PREFIX}${NEXT_NUM}"

    print_header
    echo -e "${BOLD}Routing task to $target...${RESET}"
    echo ""

    write_bridge_message "$target" "$TASK_ID" "MEDIUM" "PENDING" "$title" "$body"

    echo ""
    echo -e "${CYAN}📋 Task: $TASK_ID → $target${RESET}"
    echo -e "${CYAN}   Tell $target: \"Read agents/$target/inbox/$TASK_ID.md and execute $TASK_ID\"${RESET}"
}

cmd_sync() {
    require_td
    print_header
    echo -e "${BOLD}Syncing td board → project-state.md...${RESET}"
    echo ""

    # Get td board state
    TD_STATUS=$(td status 2>&1 || td current 2>&1)
    TD_BOARD=$(td list --status open 2>&1 | head -20)
    TD_IN_PROGRESS=$(td list --status in_progress 2>&1 | head -10)

    # Current bridge inbox task
    local active_file=$(get_active_inbox_task)
    BRIDGE_TASK=""
    BRIDGE_STATUS=""
    if [ -n "$active_file" ]; then
        BRIDGE_TASK=$(grep "^TASK_ID:" "$active_file" | head -1 | awk '{print $2}')
        BRIDGE_STATUS=$(grep "^STATUS:" "$active_file" | head -1 | awk '{print $2}')
    fi

    # Build Active Tasks section for state file
    ACTIVE_SECTION="## Active Tasks
| Task | Agent | Status |
|------|-------|--------|"

    if [ -n "$BRIDGE_TASK" ]; then
        ACTIVE_SECTION="$ACTIVE_SECTION
| $BRIDGE_TASK | $AGENT | $BRIDGE_STATUS |"
    fi

    # Append td issues to active section
    if [ -n "$TD_IN_PROGRESS" ]; then
        while IFS= read -r line; do
            TD_ID=$(echo "$line" | grep -oE '#[0-9]+' | head -1)
            TD_TITLE=$(echo "$line" | sed 's/#[0-9]* //' | cut -c1-40)
            [ -n "$TD_ID" ] && ACTIVE_SECTION="$ACTIVE_SECTION
| td${TD_ID} | $AGENT | IN_PROGRESS |"
        done <<< "$TD_IN_PROGRESS"
    fi

    # Update project-state.md Active Tasks section
    if [ -f "$STATE_FILE" ]; then
        python3 "$HELPERS_DIR/bridge_sync.py" "$STATE_FILE" "$AGENT" "$ACTIVE_SECTION"

        # Recompute hash and update this agent's entry, mark others stale
        NEW_HASH=$(md5_file "$STATE_FILE")
        if grep -q "^$AGENT:" "$HASH_FILE" 2>/dev/null; then
            portable_sed_i "s|^$AGENT:.*|$AGENT: $NEW_HASH|" "$HASH_FILE"
        else
            echo "$AGENT: $NEW_HASH" >> "$HASH_FILE"
        fi
        _mark_others_stale

        echo -e "${GREEN}✅ project-state.md synced${RESET}"
        echo -e "${CYAN}   Other agents' hashes marked stale (they'll do full read next)${RESET}"
    else
        echo -e "${YELLOW}⚠️  project-state.md not found — cannot sync${RESET}"
    fi
}

cmd_status() {
    require_td
    print_header

    echo -e "${BOLD}── td Board ──────────────────────────────────────${RESET}"
    td status 2>&1 || td current 2>&1
    echo ""
    separator

    echo -e "${BOLD}── Bridge Inbox ($AGENT) ────────────────────${RESET}"
    local task_files=("$INBOX_DIR"/*.md)
    if [ -e "${task_files[0]}" ]; then
        local count=0
        for tf in "${task_files[@]}"; do
            local t_id=$(grep "^TASK_ID:" "$tf" | head -1 | awk '{print $2}')
            local t_status=$(grep "^STATUS:" "$tf" | head -1 | awk '{print $2}')
            local t_from=$(grep "^FROM:" "$tf" | head -1 | awk '{print $2}')
            local t_prio=$(grep "^PRIORITY:" "$tf" | head -1 | awk '{print $2}')
            echo -e "  ${YELLOW}$t_id${RESET} | From: $t_from | Priority: $t_prio | Status: ${BOLD}$t_status${RESET}"
            count=$((count + 1))
        done
        echo -e "  ${CYAN}($count task(s) in queue)${RESET}"
    else
        echo -e "  ${CYAN}(inbox empty)${RESET}"
    fi
    echo ""

    echo -e "${BOLD}── Bridge Daemon ─────────────────────────────${RESET}"
    if [ -f "$DAEMON_PID" ] && kill -0 "$(cat "$DAEMON_PID")" 2>/dev/null; then
        echo -e "  ${GREEN}● RUNNING${RESET} (PID $(cat "$DAEMON_PID"))"
    else
        echo -e "  ${RED}● STOPPED${RESET} — run: bash bridge-daemon.sh --start"
    fi
    echo ""

    echo -e "${BOLD}── Token Ledger ($AGENT) ─────────────────────${RESET}"
    if [ -f "$LEDGER" ]; then
        python3 "$HELPERS_DIR/bridge_status.py" "$LEDGER"
    else
        echo -e "  ${CYAN}(no ledger)${RESET}"
    fi
    echo ""
}

cmd_join() {
    print_header
    separator
    echo -e "${BOLD}Bridge context for agent: $AGENT${RESET}"
    separator
    echo ""
    read_context
    echo ""
    separator
    echo -e "${BOLD}Inbox Queue:${RESET}"
    local task_files=("$INBOX_DIR"/*.md)
    if [ -e "${task_files[0]}" ]; then
        for tf in "${task_files[@]}"; do
            local t_id=$(grep "^TASK_ID:" "$tf" | head -1 | awk '{print $2}')
            local t_status=$(grep "^STATUS:" "$tf" | head -1 | awk '{print $2}')
            echo -e "  ${YELLOW}$t_id${RESET} [$t_status]"
        done
        echo ""
        local active_file=$(get_active_inbox_task)
        if [ -n "$active_file" ]; then
            echo -e "${BOLD}Active task:${RESET}"
            cat "$active_file"
        fi
    else
        echo "(empty)"
    fi
    echo ""
    separator
    echo -e "${GREEN}✅ Bridge active | Agent: $AGENT${RESET}"
    echo -e "${CYAN}   Write results to: $OUTBOX${RESET}"
}

# ── Help ──────────────────────────────────────────────────────
cmd_help() {
    print_header
    echo "  A wrapper integrating td CLI with the ARIA Agent Bridge v2.0"
    echo ""
    echo -e "  ${BOLD}Agent identity:${RESET} set via TD_BRIDGE_AGENT env var (default: claude)"
    echo "  Example: TD_BRIDGE_AGENT=opencode td-bridge status"
    echo ""
    separator
    echo -e "  ${BOLD}Commands:${RESET}"
    echo ""
    echo -e "  ${CYAN}join${RESET}                     Read bridge context (token dedup aware)"
    echo -e "  ${CYAN}check-inbox${RESET}              Show your agent's current inbox task"
    echo -e "  ${CYAN}create-from-bridge${RESET}       Convert inbox task → td issue"
    echo -e "  ${CYAN}start <td-id>${RESET}            Start td issue + mark bridge task IN_PROGRESS"
    echo -e "  ${CYAN}log <td-id> \"msg\"${RESET}       Log to td + append to bridge outbox"
    echo -e "  ${CYAN}handoff <td-id>${RESET}          td handoff + write bridge outbox"
    echo -e "  ${CYAN}route <agent> \"title\"${RESET}   Write task to another agent's inbox"
    echo -e "  ${CYAN}sync${RESET}                     Sync td board state → project-state.md"
    echo -e "  ${CYAN}status${RESET}                   Combined td + bridge dashboard"
    echo ""
    separator
    echo -e "  ${BOLD}Bridge directory:${RESET}"
    echo -e "  $BRIDGE_DIR"
    echo ""
}

# ── Entry point ───────────────────────────────────────────────
case "$1" in
    join)               cmd_join ;;
    check-inbox)        cmd_check_inbox ;;
    create-from-bridge) cmd_create_from_bridge ;;
    start)              cmd_start "$2" ;;
    log)                cmd_log "$2" "$3" ;;
    handoff)            cmd_handoff "$2" ;;
    route)              shift; cmd_route "$@" ;;
    sync)               cmd_sync ;;
    status)             cmd_status ;;
    help|--help|-h|"")  cmd_help ;;
    *)
        echo -e "${RED}❌ Unknown command: $1${RESET}"
        echo "   Run: td-bridge help"
        exit 1
        ;;
esac
