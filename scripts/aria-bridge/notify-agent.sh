#!/bin/bash
# ============================================================
# ARIA Bridge — notify-agent.sh v2.0
# Auto-injects task prompts into agent terminals.
# Uses osascript keystroke injection (no TTY permissions needed).
#
# Usage:
#   notify-agent.sh claude [BRIDGE-007]     # notify Claude Code
#   notify-agent.sh opencode [BRIDGE-006]   # notify OpenCode
#   notify-agent.sh all                     # notify all agents with PENDING tasks
#   notify-agent.sh --detect                # show TTY info
# ============================================================

BRIDGE_DIR="/Users/apple/.gemini/antigravity/scratch/_scripts/aria-bridge"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'
RED='\033[0;31m'; BOLD='\033[1m'; RESET='\033[0m'

# ── Detect TTY for an agent (returns full /dev/ttysXXX path) ─
detect_tty() {
    local raw
    case "$1" in
        claude)   raw=$(ps aux | grep -E "^\S+\s+[0-9]+.*claude$" | grep -v grep | grep "s0" | head -1 | awk '{print $7}') ;;
        opencode) raw=$(ps aux | grep "opencode-darwin" | grep -v grep | grep "s0" | head -1 | awk '{print $7}') ;;
    esac
    # Normalise: s006 → /dev/ttys006, ttys006 → /dev/ttys006
    if [[ "$raw" == s* ]]; then
        echo "/dev/tty$raw"
    elif [[ "$raw" == tty* ]]; then
        echo "/dev/$raw"
    else
        echo ""
    fi
}

# ── Build the prompt string ──────────────────────────────────
build_prompt() {
    local agent="$1" task_id="$2"
    local inbox="$BRIDGE_DIR/agents/$agent/inbox.md"
    [ ! -f "$inbox" ] && echo "ERROR: Inbox not found" && return 1
    local status
    status=$(grep "STATUS:" "$inbox" | head -1 | awk '{print $2}')
    [ "$status" = "DONE" ] && echo "SKIP" && return 1
    echo "Read $inbox and execute $task_id. Write results to $BRIDGE_DIR/agents/$agent/outbox.md."
}

# ── Method 1: TTY write (fastest, needs chmod) ───────────────
inject_via_tty() {
    local agent="$1" prompt="$2"
    local tty_path
    tty_path=$(detect_tty "$agent")
    [ -z "$tty_path" ] && return 1
    [ ! -w "$tty_path" ] && return 1
    printf '%s\n' "$prompt" > "$tty_path"
    echo -e "${GREEN}✅ Injected via TTY ($tty_path)${RESET}"
}

# ── Method 2: osascript keystroke injection ──────────────────
inject_via_osascript() {
    local agent="$1" prompt="$2"
    local tty_path tty
    tty_path=$(detect_tty "$agent")
    tty=$(basename "$tty_path")   # ttys006
    [ -z "$tty" ] && echo -e "${RED}❌ $agent process not found${RESET}" && return 1

    # Escape for AppleScript string
    local escaped
    escaped=$(echo "$prompt" | sed "s/'/\\\\'/g")

    # Find the Terminal window with this TTY and send keystrokes
    osascript <<EOF 2>/dev/null
tell application "Terminal"
    set targetTTY to "$tty"
    repeat with w in windows
        repeat with t in tabs of w
            if tty of t contains targetTTY then
                set selected of t to true
                set frontmost of w to true
                tell application "System Events"
                    keystroke "$escaped"
                    key code 36
                end tell
                return "OK"
            end if
        end repeat
    end repeat
    return "NOT_FOUND"
end tell
EOF
}

# ── Method 3: Write to TTY after chmod ──────────────────────
inject_via_tty_forced() {
    local agent="$1" prompt="$2"
    local tty_path
    tty_path=$(detect_tty "$agent")
    [ -z "$tty_path" ] && return 1
    # Try to make writable (may need sudo first time)
    chmod o+w "$tty_path" 2>/dev/null || sudo chmod o+w "$tty_path" 2>/dev/null
    [ ! -w "$tty_path" ] && return 1
    printf '%s\n' "$prompt" > "$tty_path"
    echo -e "${GREEN}✅ Injected via TTY (forced) ($tty_path)${RESET}"
}

# ── Main inject function (tries methods in order) ────────────
inject_prompt() {
    local agent="$1" task_id="$2"

    local prompt
    prompt=$(build_prompt "$agent" "$task_id")
    if [[ "$prompt" == "ERROR"* ]]; then
        echo -e "${RED}❌ $prompt${RESET}"; return 1
    fi
    if [[ "$prompt" == "SKIP" ]]; then
        echo -e "${YELLOW}⚠️  $agent inbox: $task_id already DONE — nothing to inject${RESET}"; return 0
    fi

    echo -e "${BOLD}🔔 Notifying $agent → $task_id${RESET}"

    # Try TTY first (instant), then osascript, then forced TTY
    if inject_via_tty "$agent" "$prompt" 2>/dev/null; then
        return 0
    fi

    echo -e "${CYAN}   TTY not writable — trying osascript keystroke injection...${RESET}"
    local result
    result=$(inject_via_osascript "$agent" "$prompt" 2>&1)
    if [[ "$result" == "OK" ]]; then
        echo -e "${GREEN}✅ Injected via osascript keystrokes${RESET}"
        return 0
    fi

    echo -e "${CYAN}   osascript failed — trying TTY with chmod...${RESET}"
    if inject_via_tty_forced "$agent" "$prompt" 2>/dev/null; then
        return 0
    fi

    # All methods failed — print the prompt for manual paste
    echo -e "${RED}❌ All injection methods failed. Paste manually:${RESET}"
    echo ""
    echo -e "${YELLOW}$prompt${RESET}"
    echo ""
    echo -e "${CYAN}Tip: Run once to unlock TTY: sudo chmod o+w $(detect_tty "$agent")${RESET}"
}

# ── Detect command ───────────────────────────────────────────
cmd_detect() {
    echo -e "${BOLD}${CYAN}── Agent TTY Detection ─────────────────────────${RESET}"
    for agent in claude opencode; do
        local tty_path
        tty_path=$(detect_tty "$agent")
        if [ -n "$tty_path" ]; then
            local status="${RED}(not writable)${RESET}"
            [ -w "$tty_path" ] && status="${GREEN}(writable ✅)${RESET}"
            echo -e "  ${BOLD}$agent${RESET}: $tty_path $status"
        else
            echo -e "  ${BOLD}$agent${RESET}: ${RED}not running${RESET}"
        fi
    done
    echo ""
    echo -e "  To unlock TTY injection (one-time per session):"
  # Dynamically show the actual TTY paths
  local c_tty o_tty
  c_tty=$(detect_tty claude); o_tty=$(detect_tty opencode)
  echo -e "  ${CYAN}sudo chmod o+w $o_tty $c_tty${RESET}"
    echo ""
}

# ── All agents with PENDING tasks ───────────────────────────
cmd_all() {
    for agent in claude opencode; do
        local inbox="$BRIDGE_DIR/agents/$agent/inbox.md"
        [ ! -f "$inbox" ] && continue
        local status task_id
        status=$(grep "STATUS:" "$inbox" | head -1 | awk '{print $2}')
        task_id=$(grep "TASK_ID:" "$inbox" | head -1 | awk '{print $2}')
        if [ "$status" = "PENDING" ]; then
            inject_prompt "$agent" "$task_id"
        else
            echo -e "  ${CYAN}$agent: $task_id [$status] — skipping${RESET}"
        fi
    done
}

# ── Entry point ───────────────────────────────────────────────
case "$1" in
    --detect) cmd_detect ;;
    all)      cmd_all ;;
    claude|opencode)
        AGENT="$1"
        TASK_ID="${2:-}"
        if [ -z "$TASK_ID" ]; then
            TASK_ID=$(grep "TASK_ID:" "$BRIDGE_DIR/agents/$AGENT/inbox.md" 2>/dev/null | head -1 | awk '{print $2}')
        fi
        inject_prompt "$AGENT" "$TASK_ID"
        ;;
    *)
        echo "Usage: notify-agent.sh [claude|opencode|all] [TASK_ID]"
        echo "       notify-agent.sh --detect"
        ;;
esac
