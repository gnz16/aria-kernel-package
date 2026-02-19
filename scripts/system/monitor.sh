#!/bin/bash
# ARIA v7.5 System Monitor (macOS Compatible)
# Usage: ./monitor.sh [--once|--watch]

SCRIPTS_DIR="$(dirname "$0")"
LOGIC_LOG="$SCRIPTS_DIR/LOGIC_LOG.md"

# Thresholds
CPU_THRESHOLD=80
MEM_THRESHOLD=90

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

get_cpu_usage() {
    # Use sysctl for CPU load average (1 min)
    local load=$(sysctl -n vm.loadavg 2>/dev/null | awk '{print $2}')
    local cores=$(sysctl -n hw.ncpu 2>/dev/null)
    if [[ -n "$load" && -n "$cores" ]]; then
        echo "$load $cores" | awk '{printf "%.0f", ($1/$2)*100}'
    else
        echo "0"
    fi
}

get_memory_usage() {
    # Parse vm_stat for memory info
    local page_size=$(pagesize 2>/dev/null || echo 4096)
    local stats=$(vm_stat 2>/dev/null)
    if [[ -n "$stats" ]]; then
        local free=$(echo "$stats" | grep "Pages free" | awk '{print $3}' | tr -d '.')
        local active=$(echo "$stats" | grep "Pages active" | awk '{print $3}' | tr -d '.')
        local inactive=$(echo "$stats" | grep "Pages inactive" | awk '{print $3}' | tr -d '.')
        local wired=$(echo "$stats" | grep "Pages wired" | awk '{print $4}' | tr -d '.')
        local total=$((free + active + inactive + wired))
        local used=$((active + wired))
        if [[ $total -gt 0 ]]; then
            echo "$used $total" | awk '{printf "%.0f", ($1/$2)*100}'
        else
            echo "0"
        fi
    else
        echo "0"
    fi
}

get_disk_usage() {
    df -h / 2>/dev/null | awk 'NR==2 {print $5}' | sed 's/%//'
}

log_alert() {
    local message="$1"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "\n## [$timestamp] HEALTH_ALERT\n**Warning**: $message\n**Status**: LOGGED\n" >> "$LOGIC_LOG"
}

display_status() {
    clear
    echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     ${GREEN}ARIA v7.5 System Monitor${BLUE}            ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
    echo ""

    local cpu=$(get_cpu_usage)
    local mem=$(get_memory_usage)
    local disk=$(get_disk_usage)
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")

    # CPU Status
    if [[ "$cpu" -gt "$CPU_THRESHOLD" ]] 2>/dev/null; then
        echo -e "${RED}⚠ CPU:  ${cpu}% [CRITICAL]${NC}"
        log_alert "CPU usage at ${cpu}% exceeds threshold of ${CPU_THRESHOLD}%"
    elif [[ "$cpu" -gt 50 ]] 2>/dev/null; then
        echo -e "${YELLOW}● CPU:  ${cpu}% [MODERATE]${NC}"
    else
        echo -e "${GREEN}● CPU:  ${cpu}% [OK]${NC}"
    fi

    # Memory Status
    if [[ "$mem" -gt "$MEM_THRESHOLD" ]] 2>/dev/null; then
        echo -e "${RED}⚠ MEM:  ${mem}% [CRITICAL]${NC}"
        log_alert "Memory usage at ${mem}% exceeds threshold of ${MEM_THRESHOLD}%"
    elif [[ "$mem" -gt 70 ]] 2>/dev/null; then
        echo -e "${YELLOW}● MEM:  ${mem}% [MODERATE]${NC}"
    else
        echo -e "${GREEN}● MEM:  ${mem}% [OK]${NC}"
    fi

    # Disk Status
    if [[ "$disk" -gt 90 ]] 2>/dev/null; then
        echo -e "${RED}⚠ DISK: ${disk}% [CRITICAL]${NC}"
    elif [[ "$disk" -gt 70 ]] 2>/dev/null; then
        echo -e "${YELLOW}● DISK: ${disk}% [MODERATE]${NC}"
    else
        echo -e "${GREEN}● DISK: ${disk}% [OK]${NC}"
    fi

    echo ""
    echo -e "${BLUE}System Info:${NC}"
    echo "  Cores: $(sysctl -n hw.ncpu 2>/dev/null || echo 'N/A')"
    echo "  Uptime: $(uptime 2>/dev/null | awk -F',' '{print $1}' | awk '{$1=$2=""; print $0}' | xargs)"

    echo ""
    echo -e "${BLUE}Last Check: ${NC}$timestamp"

    # Determine overall health
    local health="READY"
    if [[ "$cpu" -gt "$CPU_THRESHOLD" ]] 2>/dev/null || [[ "$mem" -gt "$MEM_THRESHOLD" ]] 2>/dev/null; then
        health="DEGRADED"
    fi
    
    echo -e "${BLUE}System Status: ${NC}$health"
}

# Main
case "$1" in
    --watch)
        while true; do
            display_status
            sleep 5
        done
        ;;
    --once|*)
        display_status
        ;;
esac
