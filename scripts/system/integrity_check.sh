#!/bin/bash
# ARIA v7.7 System Integrity Check (Constellation Edition)
# Comprehensive verification of all system components

GEMINI_DIR="/Users/apple/.gemini"
SCRIPTS_DIR="$GEMINI_DIR/_scripts"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

PASS=0
WARN=0
FAIL=0

check_file() {
    local file="$1"
    local name="$2"
    if [[ -f "$file" ]]; then
        echo -e "  ${GREEN}✓${NC} $name"
        ((PASS++))
        return 0
    else
        echo -e "  ${RED}✗${NC} $name - MISSING"
        ((FAIL++))
        return 1
    fi
}

check_contains() {
    local file="$1"
    local pattern="$2"
    local name="$3"
    if grep -q "$pattern" "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $name"
        ((PASS++))
    else
        echo -e "  ${YELLOW}⚠${NC} $name - NOT FOUND"
        ((WARN++))
    fi
}

echo -e "${CYAN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   ${GREEN}ARIA v7.7 System Integrity Check${CYAN}              ║${NC}"
echo -e "${CYAN}║   ${GREEN}Constellation Edition${CYAN}                         ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# 1. Configuration Files
echo -e "${BLUE}[1/6] Configuration Files${NC}"
check_file "$GEMINI_DIR/GEMINI.md" "GEMINI.md"
check_file "$GEMINI_DIR/ARIA_KERNEL.md" "ARIA_KERNEL.md"
check_file "/Users/apple/.cursorrules" ".cursorrules"
check_file "/Users/apple/.claude/CLAUDE.md" "~/.claude/CLAUDE.md (Claude Code port)"

# Version check
if grep -q "7.7" "$GEMINI_DIR/ARIA_KERNEL.md" 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} ARIA_KERNEL.md version 7.7 confirmed"
    ((PASS++))
else
    echo -e "  ${YELLOW}⚠${NC} ARIA_KERNEL.md version mismatch (expected 7.7)"
    ((WARN++))
fi

if grep -q "7.7" "/Users/apple/.cursorrules" 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} .cursorrules version 7.7 confirmed"
    ((PASS++))
else
    echo -e "  ${YELLOW}⚠${NC} .cursorrules version mismatch (expected 7.7)"
    ((WARN++))
fi

echo ""

# 2. Core Scripts
echo -e "${BLUE}[2/6] Core Scripts${NC}"
check_file "$SCRIPTS_DIR/monitor.sh" "monitor.sh"
check_file "$SCRIPTS_DIR/security_scan.sh" "security_scan.sh"
check_file "$SCRIPTS_DIR/backup-logic.sh" "backup-logic.sh"
check_file "$SCRIPTS_DIR/LOGIC_LOG.md" "LOGIC_LOG.md"
check_file "$SCRIPTS_DIR/appm_state.json" "appm_state.json"
check_file "$SCRIPTS_DIR/CONTINUITY.md" "CONTINUITY.md (v7.7 volatile memory)"
check_file "$SCRIPTS_DIR/STRATEGIC_LEDGER.md" "STRATEGIC_LEDGER.md (v7.7 navigation layer)"

# Check if scripts are executable
for script in monitor.sh security_scan.sh backup-logic.sh; do
    if [[ -x "$SCRIPTS_DIR/$script" ]]; then
        echo -e "  ${GREEN}✓${NC} $script is executable"
        ((PASS++))
    else
        echo -e "  ${YELLOW}⚠${NC} $script not executable"
        ((WARN++))
    fi
done

echo ""

# 3. Skills Directory
echo -e "${BLUE}[3/6] Skills Inventory${NC}"
skill_count=$(find "$GEMINI_DIR/skills" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
echo -e "  ${GREEN}✓${NC} Found $skill_count skills with SKILL.md"
((PASS++))

# Check key skills
for skill in skill-manager autonomous-prompt-manager ui-testing loki-mode; do
    check_file "$GEMINI_DIR/skills/$skill/SKILL.md" "Skill: $skill"
done

echo ""

# 4. Workflows
echo -e "${BLUE}[4/6] Workflows${NC}"
workflow_count=$(ls -1 "$GEMINI_DIR/.agent/workflows"/*.md 2>/dev/null | wc -l | tr -d ' ')
echo -e "  ${GREEN}✓${NC} Found $workflow_count workflows"
((PASS++))

for wf in system-scan feature-development bug-fix autonomous-manager; do
    check_file "$GEMINI_DIR/.agent/workflows/$wf.md" "Workflow: $wf"
done

echo ""

# 5. Key Configurations
echo -e "${BLUE}[5/6] Key Configurations${NC}"
check_contains "$GEMINI_DIR/ARIA_KERNEL.md" "Resonance Matrix" "Resonance Matrix defined"
check_contains "$GEMINI_DIR/ARIA_KERNEL.md" "Dual-Gaze" "Recursive Integrity defined"
check_contains "$GEMINI_DIR/ARIA_KERNEL.md" "Ghost Module" "Ghost Module defined"
check_contains "$GEMINI_DIR/ARIA_KERNEL.md" "Constellation Mode" "Constellation Mode defined (v7.7)"
check_contains "$GEMINI_DIR/ARIA_KERNEL.md" "RARV" "RARV Cycle defined"
check_contains "/Users/apple/.cursorrules" "v7.7" ".cursorrules v7.7"
check_contains "/Users/apple/.claude/CLAUDE.md" "Constellation" "Claude Code port has Constellation Mode"

echo ""

# 6. System Health
echo -e "${BLUE}[6/6] System Health${NC}"
cpu=$(sysctl -n vm.loadavg 2>/dev/null | awk '{print $2}')
cores=$(sysctl -n hw.ncpu 2>/dev/null)
if [[ -n "$cpu" && -n "$cores" ]]; then
    cpu_pct=$(echo "$cpu $cores" | awk '{printf "%.0f", ($1/$2)*100}')
    if [[ "$cpu_pct" -lt 80 ]]; then
        echo -e "  ${GREEN}✓${NC} CPU: ${cpu_pct}% [OK]"
        ((PASS++))
    else
        echo -e "  ${YELLOW}⚠${NC} CPU: ${cpu_pct}% [HIGH]"
        ((WARN++))
    fi
fi

disk=$(df -h / 2>/dev/null | awk 'NR==2 {print $5}' | sed 's/%//')
if [[ "$disk" -lt 90 ]]; then
    echo -e "  ${GREEN}✓${NC} Disk: ${disk}% [OK]"
    ((PASS++))
else
    echo -e "  ${YELLOW}⚠${NC} Disk: ${disk}% [HIGH]"
    ((WARN++))
fi

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Summary:${NC}"
echo -e "  ${GREEN}PASS: $PASS${NC}"
echo -e "  ${YELLOW}WARN: $WARN${NC}"
echo -e "  ${RED}FAIL: $FAIL${NC}"
echo ""

if [[ $FAIL -eq 0 && $WARN -eq 0 ]]; then
    echo -e "${GREEN}✓ SYSTEM INTEGRITY: VERIFIED${NC}"
    echo -e "${GREEN}  Status: READY${NC}"
elif [[ $FAIL -eq 0 ]]; then
    echo -e "${YELLOW}⚠ SYSTEM INTEGRITY: VERIFIED WITH WARNINGS${NC}"
    echo -e "${YELLOW}  Status: DEGRADED${NC}"
else
    echo -e "${RED}✗ SYSTEM INTEGRITY: FAILED${NC}"
    echo -e "${RED}  Status: CRITICAL${NC}"
fi

echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo "Check completed at: $(date "+%Y-%m-%d %H:%M:%S")"
