#!/bin/bash
# ARIA v7.5 Security Scanner
# Checks for potentially malicious processes and suspicious activity
# Usage: ./security_scan.sh

SCRIPTS_DIR="$(dirname "$0")"
LOGIC_LOG="$SCRIPTS_DIR/LOGIC_LOG.md"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Known suspicious process patterns
SUSPICIOUS_PATTERNS=(
    "cryptominer"
    "xmrig"
    "minerd"
    "cgminer"
    "bfgminer"
    "cpuminer"
    "coinhive"
    "kworker.*crypto"
    "kdevtmpfsi"
    "kinsing"
    "portscan"
    "masscan"
    "hydra"
    "nmap.*-sS"
    "reverse.*shell"
    "nc -e"
    "bash -i"
    "perl.*socket"
    "python.*socket"
)

# Known suspicious ports (commonly used by malware)
SUSPICIOUS_PORTS=(
    "4444"   # Metasploit default
    "5555"   # Android Debug
    "6666"   # IRC botnet
    "6667"   # IRC
    "31337"  # Back Orifice
    "12345"  # NetBus
)

log_alert() {
    local message="$1"
    local severity="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "\n## [$timestamp] SECURITY_ALERT\n**Severity**: $severity\n**Finding**: $message\n" >> "$LOGIC_LOG"
}

echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     ${GREEN}ARIA v7.5 Security Scanner${BLUE}           ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Scanning for malicious activity...${NC}"
echo ""

ISSUES_FOUND=0

# Check 1: Suspicious Processes by Name
echo -e "${BLUE}[1/5] Checking process names...${NC}"
for pattern in "${SUSPICIOUS_PATTERNS[@]}"; do
    matches=$(pgrep -fil "$pattern" 2>/dev/null | grep -v "security_scan.sh" | grep -v "grep")
    if [[ -n "$matches" ]]; then
        echo -e "${RED}⚠ FOUND suspicious pattern '$pattern':${NC}"
        echo "$matches" | while read line; do
            echo -e "  ${YELLOW}→ $line${NC}"
        done
        log_alert "Suspicious process pattern detected: $pattern" "HIGH"
        ((ISSUES_FOUND++))
    fi
done
if [[ $ISSUES_FOUND -eq 0 ]]; then
    echo -e "${GREEN}  ✓ No suspicious process names found${NC}"
fi

# Check 2: High CPU Consumers (potential miners)
echo -e "${BLUE}[2/5] Checking for high CPU consumers...${NC}"
high_cpu=$(ps -A -o %cpu,comm 2>/dev/null | awk '$1 > 80 {print $2}' | head -5)
if [[ -n "$high_cpu" ]]; then
    echo -e "${YELLOW}⚠ High CPU processes (>80%):${NC}"
    echo "$high_cpu" | while read proc; do
        echo -e "  ${YELLOW}→ $proc${NC}"
    done
    log_alert "High CPU usage detected: $high_cpu" "MEDIUM"
    ((ISSUES_FOUND++))
else
    echo -e "${GREEN}  ✓ No abnormal CPU usage${NC}"
fi

# Check 3: Listening Ports
echo -e "${BLUE}[3/5] Checking network listeners...${NC}"
for port in "${SUSPICIOUS_PORTS[@]}"; do
    listening=$(lsof -i :$port 2>/dev/null | grep LISTEN)
    if [[ -n "$listening" ]]; then
        echo -e "${RED}⚠ Suspicious port $port is listening:${NC}"
        echo -e "  ${YELLOW}→ $listening${NC}"
        log_alert "Suspicious port $port is active" "HIGH"
        ((ISSUES_FOUND++))
    fi
done
echo -e "${GREEN}  ✓ No suspicious ports open${NC}"

# Check 4: LaunchAgents and LaunchDaemons (persistence mechanisms)
echo -e "${BLUE}[4/5] Checking persistence mechanisms...${NC}"
suspicious_agents=0
for dir in ~/Library/LaunchAgents /Library/LaunchAgents /Library/LaunchDaemons; do
    if [[ -d "$dir" ]]; then
        # Look for recently modified plist files
        recent=$(find "$dir" -name "*.plist" -mtime -7 2>/dev/null)
        if [[ -n "$recent" ]]; then
            echo -e "${YELLOW}  Recently modified LaunchAgents in $dir:${NC}"
            echo "$recent" | while read f; do
                echo -e "    ${YELLOW}→ $(basename "$f")${NC}"
            done
        fi
    fi
done
echo -e "${GREEN}  ✓ Persistence check complete${NC}"

# Check 5: Unusual Login Items
echo -e "${BLUE}[5/5] Checking for hidden processes...${NC}"
# Check for processes running from /tmp or hidden locations
hidden_procs=$(lsof 2>/dev/null | grep -E "/tmp/|/var/tmp/|\.\./|/dev/shm" | awk '{print $1}' | sort -u | head -5)
if [[ -n "$hidden_procs" ]]; then
    echo -e "${YELLOW}⚠ Processes running from temp/hidden locations:${NC}"
    echo "$hidden_procs" | while read proc; do
        echo -e "  ${YELLOW}→ $proc${NC}"
    done
    log_alert "Processes running from suspicious locations" "MEDIUM"
    ((ISSUES_FOUND++))
else
    echo -e "${GREEN}  ✓ No hidden process locations detected${NC}"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
if [[ $ISSUES_FOUND -eq 0 ]]; then
    echo -e "${GREEN}✓ SCAN COMPLETE: No malicious activity detected${NC}"
    echo -e "${GREEN}  System Status: SECURE${NC}"
else
    echo -e "${RED}⚠ SCAN COMPLETE: $ISSUES_FOUND potential issue(s) found${NC}"
    echo -e "${RED}  System Status: REVIEW RECOMMENDED${NC}"
    echo -e "${YELLOW}  Check LOGIC_LOG.md for details${NC}"
fi
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo ""
echo "Scan completed at: $(date "+%Y-%m-%d %H:%M:%S")"
