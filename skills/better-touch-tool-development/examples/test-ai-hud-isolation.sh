#!/bin/bash
# AI HUD Context Isolation Test Script
# Tests AI HUD functionality with and without context isolation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_HUD_DIR="$SCRIPT_DIR/contextual-ai-hud"
TEST_RESULTS="$SCRIPT_DIR/ai-hud-test-results.txt"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           AI HUD CONTEXT ISOLATION TEST                              ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Initialize results file
echo "AI HUD Context Isolation Test Results" > "$TEST_RESULTS"
echo "Generated: $(date)" >> "$TEST_RESULTS"
echo "========================================" >> "$TEST_RESULTS"
echo "" >> "$TEST_RESULTS"

# ============================================================================
# TEST 1: Check for BTT Global Variable Usage
# ============================================================================
echo -e "${YELLOW}[1/4] Analyzing JavaScript files for BTT globals...${NC}"

BTT_GLOBALS=(
    "callBTT"
    "get_string_variable"
    "set_string_variable"
    "execute_assigned_actions_for_trigger"
    "trigger_action"
    "refresh_widget"
)

echo "Test 1: BTT Global Variable Usage" >> "$TEST_RESULTS"
echo "-----------------------------------" >> "$TEST_RESULTS"

FOUND_GLOBALS=false

for file in "$AI_HUD_DIR"/*.js; do
    if [ -f "$file" ]; then
        BASENAME=$(basename "$file")
        echo -e "   Checking: ${BLUE}$BASENAME${NC}"
        
        for global in "${BTT_GLOBALS[@]}"; do
            if grep -q "$global" "$file"; then
                echo -e "     ${YELLOW}⚠️  Found: $global${NC}"
                echo "   $BASENAME: Uses $global" >> "$TEST_RESULTS"
                FOUND_GLOBALS=true
            fi
        done
    fi
done

if [ "$FOUND_GLOBALS" = false ]; then
    echo -e "${GREEN}✅ No BTT global variables found${NC}"
    echo "   Result: No BTT globals detected - SAFE for isolation" >> "$TEST_RESULTS"
else
    echo -e "${YELLOW}⚠️  BTT globals detected - may need refactoring${NC}"
    echo "   Result: BTT globals found - requires code changes for isolation" >> "$TEST_RESULTS"
fi
echo "" >> "$TEST_RESULTS"
echo ""

# ============================================================================
# TEST 2: Check btt-config.json Structure
# ============================================================================
echo -e "${YELLOW}[2/4] Validating btt-config.json...${NC}"

CONFIG_FILE="$AI_HUD_DIR/btt-config.json"

echo "Test 2: btt-config.json Validation" >> "$TEST_RESULTS"
echo "-----------------------------------" >> "$TEST_RESULTS"

if [ -f "$CONFIG_FILE" ]; then
    # Validate JSON
    if jq empty "$CONFIG_FILE" 2>/dev/null; then
        echo -e "${GREEN}✅ Valid JSON structure${NC}"
        echo "   Result: Valid JSON" >> "$TEST_RESULTS"
        
        # Check for script references
        SCRIPT_REFS=$(jq -r '.. | .BTTActionScript? // empty' "$CONFIG_FILE" 2>/dev/null | wc -l | tr -d ' ')
        echo -e "   Script references: ${BLUE}$SCRIPT_REFS${NC}"
        echo "   Script references found: $SCRIPT_REFS" >> "$TEST_RESULTS"
        
        # Check for external file paths
        EXTERNAL_PATHS=$(jq -r '.. | .BTTScriptExternalPath? // empty' "$CONFIG_FILE" 2>/dev/null)
        if [ -n "$EXTERNAL_PATHS" ]; then
            echo -e "   ${BLUE}External scripts:${NC}"
            echo "$EXTERNAL_PATHS" | while read -r path; do
                if [ -f "$path" ]; then
                    echo -e "     ${GREEN}✅ $path${NC}"
                    echo "     Found: $path" >> "$TEST_RESULTS"
                else
                    echo -e "     ${RED}❌ Missing: $path${NC}"
                    echo "     Missing: $path" >> "$TEST_RESULTS"
                fi
            done
        fi
    else
        echo -e "${RED}❌ Invalid JSON${NC}"
        echo "   Result: INVALID JSON - must fix before testing" >> "$TEST_RESULTS"
    fi
else
    echo -e "${RED}❌ Config file not found${NC}"
    echo "   Result: File not found" >> "$TEST_RESULTS"
fi
echo "" >> "$TEST_RESULTS"
echo ""

# ============================================================================
# TEST 3: Syntax Check JavaScript Files
# ============================================================================
echo -e "${YELLOW}[3/4] Checking JavaScript syntax...${NC}"

echo "Test 3: JavaScript Syntax Validation" >> "$TEST_RESULTS"
echo "--------------------------------------" >> "$TEST_RESULTS"

SYNTAX_ERRORS=false

for file in "$AI_HUD_DIR"/*.js; do
    if [ -f "$file" ]; then
        BASENAME=$(basename "$file")
        echo -e "   Checking: ${BLUE}$BASENAME${NC}"
        
        if node --check "$file" 2>/dev/null; then
            echo -e "     ${GREEN}✅ Syntax OK${NC}"
            echo "   $BASENAME: Syntax OK" >> "$TEST_RESULTS"
        else
            echo -e "     ${RED}❌ Syntax errors${NC}"
            echo "   $BASENAME: SYNTAX ERRORS" >> "$TEST_RESULTS"
            SYNTAX_ERRORS=true
        fi
    fi
done

if [ "$SYNTAX_ERRORS" = false ]; then
    echo -e "${GREEN}✅ All JavaScript files have valid syntax${NC}"
else
    echo -e "${RED}❌ Syntax errors found - must fix before testing${NC}"
fi
echo "" >> "$TEST_RESULTS"
echo ""

# ============================================================================
# TEST 4: Recommendations
# ============================================================================
echo -e "${YELLOW}[4/4] Generating recommendations...${NC}"

echo "Test 4: Recommendations" >> "$TEST_RESULTS"
echo "-----------------------" >> "$TEST_RESULTS"

if [ "$FOUND_GLOBALS" = true ]; then
    echo -e "${YELLOW}⚠️  Context Isolation: NOT RECOMMENDED${NC}"
    echo "   Reason: BTT global variables detected"
    echo ""
    echo "   To enable isolation, refactor code:"
    echo -e "   ${BLUE}// Before (non-isolated):${NC}"
    echo "   callBTT('trigger_named', {name: 'MyTrigger'});"
    echo ""
    echo -e "   ${BLUE}// After (isolated):${NC}"
    echo "   window.bttAPI.callBTT('trigger_named', {name: 'MyTrigger'});"
    
    echo "Recommendation: KEEP context isolation DISABLED" >> "$TEST_RESULTS"
    echo "Reason: BTT globals in use, requires code refactoring" >> "$TEST_RESULTS"
else
    echo -e "${GREEN}✅ Context Isolation: SAFE TO ENABLE${NC}"
    echo "   No BTT globals detected"
    echo "   Scripts appear self-contained"
    
    echo "Recommendation: SAFE to enable context isolation" >> "$TEST_RESULTS"
    echo "Reason: No BTT globals detected" >> "$TEST_RESULTS"
fi

echo "" >> "$TEST_RESULTS"
echo ""

# ============================================================================
# FINAL REPORT
# ============================================================================
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    TEST COMPLETE                                     ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo "Summary" >> "$TEST_RESULTS"
echo "-------" >> "$TEST_RESULTS"

if [ "$FOUND_GLOBALS" = false ] && [ "$SYNTAX_ERRORS" = false ]; then
    echo -e "${GREEN}✅ All tests passed${NC}"
    echo -e "${GREEN}✅ Safe to enable context isolation${NC}"
    echo "Status: PASS - Safe for context isolation" >> "$TEST_RESULTS"
    EXIT_CODE=0
else
    echo -e "${YELLOW}⚠️  Tests completed with warnings${NC}"
    echo -e "${YELLOW}⚠️  Review results before enabling isolation${NC}"
    echo "Status: WARNINGS - Review before enabling isolation" >> "$TEST_RESULTS"
    EXIT_CODE=1
fi

echo "" >> "$TEST_RESULTS"
echo "Detailed results saved to: $TEST_RESULTS" >> "$TEST_RESULTS"

echo ""
echo -e "${BLUE}📄 Full results: ${GREEN}$TEST_RESULTS${NC}"
echo ""

exit $EXIT_CODE
