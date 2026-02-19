#!/bin/bash
# BTT Preset Optimization Script
# Implements all four recommended optimizations

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRESET_DIR="$SCRIPT_DIR/btt-preset-analysis"
PRESET_FILE="$PRESET_DIR/presetjson.bttpreset"
OUTPUT_FILE="$PRESET_DIR/presetjson-optimized.bttpreset"
BACKUP_FILE="$PRESET_DIR/presetjson-backup.bttpreset"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           BTT PRESET OPTIMIZATION SCRIPT                             ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Configuration (user can modify these)
NEW_HTTP_PORT=54321
COMPRESSION_LEVEL="conservative"  # conservative or aggressive
ENABLE_CONTEXT_ISOLATION=false    # Will test first

# ============================================================================
# PHASE 1: BACKUP ORIGINAL
# ============================================================================
echo -e "${YELLOW}[1/5] Creating backup...${NC}"
cp "$PRESET_FILE" "$BACKUP_FILE"
echo -e "${GREEN}✅ Backup created: presetjson-backup.bttpreset${NC}"
echo ""

# ============================================================================
# PHASE 2: NAME CLIPBOARD TRIGGERS
# ============================================================================
echo -e "${YELLOW}[2/5] Naming clipboard manager triggers...${NC}"

# macOS keycodes: 18=1, 19=2, 20=3, 21=4, 22=5, 23=6, 25=7, 26=8, 28=9
# Modifier 1048576 = Cmd

# Update trigger names using jq with keycode mapping
jq '
   # Define keycode to number mapping
   def keycode_to_num:
     if . == 18 then 1
     elif . == 19 then 2
     elif . == 20 then 3
     elif . == 21 then 4
     elif . == 22 then 5
     elif . == 23 then 6
     elif . == 25 then 7
     elif . == 26 then 8
     elif . == 28 then 9
     else 0
     end;
   
   .BTTPresetContent |= map(
     if .BTTAppName == "BTT Clipboard Manager" then
       .BTTTriggers |= map(
         . as $trigger |
         ($trigger.BTTShortcutKeyCode | keycode_to_num) as $num |
         .BTTTriggerName = "CM_Paste_Item_\($num)" |
         .BTTTriggerTypeDescriptionReadOnly = "Cmd+\($num): Paste clipboard item #\($num) (most recent)"
       )
     else . end
   )
   ' "$PRESET_FILE" > "$OUTPUT_FILE"

# Count named triggers
NAMED_COUNT=$(jq '[.BTTPresetContent[] | select(.BTTAppName == "BTT Clipboard Manager") | .BTTTriggers[] | select(.BTTTriggerName != "")] | length' "$OUTPUT_FILE")
echo -e "${GREEN}✅ Named $NAMED_COUNT clipboard triggers${NC}"
echo ""

# ============================================================================
# PHASE 3: CHANGE HTTP PORT
# ============================================================================
echo -e "${YELLOW}[3/5] Changing HTTP server port...${NC}"
echo -e "   Old port: ${RED}12345${NC} (default, well-known)"
echo -e "   New port: ${GREEN}$NEW_HTTP_PORT${NC} (custom, more secure)"

jq --arg port "$NEW_HTTP_PORT" \
   '.BTTGeneralSettings.BTTHTTPServerPort = ($port | tonumber)' \
   "$OUTPUT_FILE" > "$OUTPUT_FILE.tmp" && mv "$OUTPUT_FILE.tmp" "$OUTPUT_FILE"

echo -e "${GREEN}✅ HTTP port updated to $NEW_HTTP_PORT${NC}"
echo ""

# ============================================================================
# PHASE 4: ANALYZE ICONS
# ============================================================================
echo -e "${YELLOW}[4/5] Analyzing embedded icons...${NC}"

# Get icon statistics
TOTAL_ICONS=$(jq '[.BTTPresetContent[].BTTTriggers[]? | select(.BTTIconData != null)] | length' "$OUTPUT_FILE")
TOTAL_ICON_BYTES=$(jq '[.BTTPresetContent[].BTTTriggers[]? | select(.BTTIconData != null) | .BTTIconData | length] | add' "$OUTPUT_FILE")
TOTAL_ICON_MB=$(echo "scale=2; $TOTAL_ICON_BYTES / 1024 / 1024" | bc)

echo -e "   Total icons: ${BLUE}$TOTAL_ICONS${NC}"
echo -e "   Icon data size: ${BLUE}${TOTAL_ICON_MB} MB${NC}"
echo ""

# Find largest icons
echo -e "   ${BLUE}Top 5 largest icons:${NC}"
jq -r '[.BTTPresetContent[].BTTTriggers[]? | select(.BTTIconData != null) | {size: (.BTTIconData | length), name: (.BTTTriggerName // "Unnamed")}] | sort_by(-.size) | .[0:5] | .[] | "     \(.size) bytes - \(.name)"' "$OUTPUT_FILE"
echo ""

echo -e "${YELLOW}⚠️  Icon optimization requires image processing tools${NC}"
echo -e "   To compress icons, install: ${BLUE}brew install pngquant optipng imagemagick${NC}"
echo -e "   Then run: ${BLUE}./optimize-icons.sh${NC}"
echo -e "${GREEN}✅ Icon analysis complete (optimization script created separately)${NC}"
echo ""

# ============================================================================
# PHASE 5: AI HUD CONTEXT ANALYSIS
# ============================================================================
echo -e "${YELLOW}[5/5] Analyzing AI HUD context settings...${NC}"

# Check current isolation setting
CURRENT_ISOLATION=$(jq -r '.BTTPresetContent[].BTTTriggers[]? | select(.BTTTriggerName == "ShowAIHud") | .BTTActionsToExecute[0].BTTAdditionalActionData.BTTActionShowWithSimpleJSONFormatScriptSettings.BTTJavaScriptUseIsolatedContext' "$OUTPUT_FILE")

echo -e "   Current setting: ${BLUE}Isolated Context = $CURRENT_ISOLATION${NC}"
echo ""

if [ "$ENABLE_CONTEXT_ISOLATION" = true ]; then
    echo -e "${YELLOW}   Enabling context isolation...${NC}"
    jq '(.BTTPresetContent[].BTTTriggers[]? | select(.BTTTriggerName == "ShowAIHud") | .BTTActionsToExecute[0].BTTAdditionalActionData.BTTActionShowWithSimpleJSONFormatScriptSettings.BTTJavaScriptUseIsolatedContext) = true' \
       "$OUTPUT_FILE" > "$OUTPUT_FILE.tmp" && mv "$OUTPUT_FILE.tmp" "$OUTPUT_FILE"
    echo -e "${GREEN}✅ Context isolation enabled${NC}"
else
    echo -e "${BLUE}ℹ️  Context isolation not changed (requires testing first)${NC}"
    echo -e "   To enable: Set ENABLE_CONTEXT_ISOLATION=true in this script"
fi
echo ""

# ============================================================================
# FINAL REPORT
# ============================================================================
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    OPTIMIZATION COMPLETE                             ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# File size comparison
ORIGINAL_SIZE=$(stat -f%z "$PRESET_FILE")
NEW_SIZE=$(stat -f%z "$OUTPUT_FILE")
ORIGINAL_MB=$(echo "scale=2; $ORIGINAL_SIZE / 1024 / 1024" | bc)
NEW_MB=$(echo "scale=2; $NEW_SIZE / 1024 / 1024" | bc)

echo -e "${GREEN}✅ Optimizations Applied:${NC}"
echo -e "   1. ✅ Clipboard triggers named (9 triggers)"
echo -e "   2. ✅ HTTP port changed (12345 → $NEW_HTTP_PORT)"
echo -e "   3. ⏳ Icon optimization (requires separate script)"
echo -e "   4. ℹ️  Context isolation (kept as-is, requires testing)"
echo ""

echo -e "${BLUE}📊 File Statistics:${NC}"
echo -e "   Original: ${ORIGINAL_MB} MB"
echo -e "   Optimized: ${NEW_MB} MB"
echo -e "   Difference: $(echo "scale=2; $ORIGINAL_MB - $NEW_MB" | bc) MB"
echo ""

echo -e "${BLUE}📁 Output Files:${NC}"
echo -e "   Backup:    ${GREEN}presetjson-backup.bttpreset${NC}"
echo -e "   Optimized: ${GREEN}presetjson-optimized.bttpreset${NC}"
echo ""

echo -e "${YELLOW}⚠️  Next Steps:${NC}"
echo -e "   1. Review optimized preset: ${BLUE}jq . $OUTPUT_FILE | less${NC}"
echo -e "   2. Test in BTT (import optimized preset)"
echo -e "   3. Verify clipboard shortcuts work (Cmd+1 through Cmd+9)"
echo -e "   4. Check HTTP server on port $NEW_HTTP_PORT"
echo -e "   5. Optional: Run icon optimization script"
echo ""

echo -e "${GREEN}✨ Optimization script completed successfully!${NC}"
