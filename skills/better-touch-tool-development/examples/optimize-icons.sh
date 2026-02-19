#!/bin/bash
# BTT Icon Optimization Script
# Extracts, compresses, and re-encodes embedded icons

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRESET_FILE="$SCRIPT_DIR/btt-preset-analysis/presetjson-optimized.bttpreset"
ICON_DIR="$SCRIPT_DIR/btt-icons-temp"
OUTPUT_FILE="$SCRIPT_DIR/btt-preset-analysis/presetjson-optimized-icons.bttpreset"

# Configuration
MIN_SIZE_TO_OPTIMIZE=50000  # Only optimize icons > 50KB
COMPRESSION_QUALITY=80      # 1-100, higher = better quality
MAX_DIMENSION=512           # Max width/height for icons

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              BTT ICON OPTIMIZATION SCRIPT                            ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check dependencies
echo -e "${YELLOW}Checking dependencies...${NC}"
MISSING_DEPS=()

if ! command -v pngquant &> /dev/null; then
    MISSING_DEPS+=("pngquant")
fi

if ! command -v optipng &> /dev/null; then
    MISSING_DEPS+=("optipng")
fi

if ! command -v convert &> /dev/null; then
    MISSING_DEPS+=("imagemagick")
fi

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Missing dependencies: ${MISSING_DEPS[*]}${NC}"
    echo -e "   Install with: ${BLUE}brew install ${MISSING_DEPS[*]}${NC}"
    echo ""
    echo -e "${YELLOW}Would you like to continue without optimization? (icons will be analyzed only)${NC}"
    read -p "Continue? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
    OPTIMIZE_ENABLED=false
else
    echo -e "${GREEN}✅ All dependencies found${NC}"
    OPTIMIZE_ENABLED=true
fi
echo ""

# Create temp directory
mkdir -p "$ICON_DIR"

# Extract icons
echo -e "${YELLOW}Extracting icons from preset...${NC}"

# Get all triggers with icons
jq -c '.BTTPresetContent[].BTTTriggers[]? | select(.BTTIconData != null) | {uuid: .BTTUUID, name: .BTTTriggerName, icon: .BTTIconData, size: (.BTTIconData | length)}' "$PRESET_FILE" | \
while IFS= read -r trigger; do
    UUID=$(echo "$trigger" | jq -r '.uuid')
    NAME=$(echo "$trigger" | jq -r '.name // "unnamed"')
    SIZE=$(echo "$trigger" | jq -r '.size')
    
    # Only process icons above minimum size
    if [ "$SIZE" -gt "$MIN_SIZE_TO_OPTIMIZE" ]; then
        echo -e "   Extracting: ${BLUE}$NAME${NC} ($UUID) - $(echo "scale=2; $SIZE / 1024" | bc) KB"
        
        # Decode base64 to PNG
        echo "$trigger" | jq -r '.icon' | base64 -d > "$ICON_DIR/$UUID.png" 2>/dev/null || {
            echo -e "     ${YELLOW}⚠️  Failed to decode, might not be PNG${NC}"
        }
    fi
done

EXTRACTED_COUNT=$(ls -1 "$ICON_DIR"/*.png 2>/dev/null | wc -l | tr -d ' ')
echo -e "${GREEN}✅ Extracted $EXTRACTED_COUNT icons for optimization${NC}"
echo ""

if [ "$OPTIMIZE_ENABLED" = false ]; then
    echo -e "${YELLOW}Optimization skipped (missing dependencies)${NC}"
    echo -e "Icon files saved in: ${BLUE}$ICON_DIR${NC}"
    exit 0
fi

# Optimize icons
echo -e "${YELLOW}Optimizing icons...${NC}"
TOTAL_ORIGINAL_SIZE=0
TOTAL_OPTIMIZED_SIZE=0

for icon in "$ICON_DIR"/*.png; do
    if [ -f "$icon" ]; then
        BASENAME=$(basename "$icon")
        ORIGINAL_SIZE=$(stat -f%z "$icon")
        TOTAL_ORIGINAL_SIZE=$((TOTAL_ORIGINAL_SIZE + ORIGINAL_SIZE))
        
        echo -e "   Processing: ${BLUE}$BASENAME${NC}"
        
        # Get dimensions
        DIMENSIONS=$(identify -format "%wx%h" "$icon" 2>/dev/null || echo "unknown")
        echo -e "     Original: $(echo "scale=2; $ORIGINAL_SIZE / 1024" | bc) KB, $DIMENSIONS"
        
        # Resize if too large
        if [ "$DIMENSIONS" != "unknown" ]; then
            WIDTH=$(echo "$DIMENSIONS" | cut -d'x' -f1)
            HEIGHT=$(echo "$DIMENSIONS" | cut -d'x' -f2)
            
            if [ "$WIDTH" -gt "$MAX_DIMENSION" ] || [ "$HEIGHT" -gt "$MAX_DIMENSION" ]; then
                echo -e "     ${YELLOW}Resizing to max ${MAX_DIMENSION}px...${NC}"
                convert "$icon" -resize "${MAX_DIMENSION}x${MAX_DIMENSION}>" "$icon.tmp"
                mv "$icon.tmp" "$icon"
            fi
        fi
        
        # Compress with pngquant
        pngquant --quality=60-$COMPRESSION_QUALITY --force --output "$icon.tmp" "$icon" 2>/dev/null && {
            mv "$icon.tmp" "$icon"
        }
        
        # Further optimize with optipng
        optipng -quiet -o2 "$icon" 2>/dev/null || true
        
        OPTIMIZED_SIZE=$(stat -f%z "$icon")
        TOTAL_OPTIMIZED_SIZE=$((TOTAL_OPTIMIZED_SIZE + OPTIMIZED_SIZE))
        SAVINGS=$((ORIGINAL_SIZE - OPTIMIZED_SIZE))
        PERCENT=$(echo "scale=1; $SAVINGS * 100 / $ORIGINAL_SIZE" | bc)
        
        echo -e "     ${GREEN}Optimized: $(echo "scale=2; $OPTIMIZED_SIZE / 1024" | bc) KB (saved ${PERCENT}%)${NC}"
    fi
done

echo ""
TOTAL_SAVINGS=$((TOTAL_ORIGINAL_SIZE - TOTAL_OPTIMIZED_SIZE))
TOTAL_PERCENT=$(echo "scale=1; $TOTAL_SAVINGS * 100 / $TOTAL_ORIGINAL_SIZE" | bc)

echo -e "${GREEN}✅ Icon optimization complete${NC}"
echo -e "   Original size: $(echo "scale=2; $TOTAL_ORIGINAL_SIZE / 1024 / 1024" | bc) MB"
echo -e "   Optimized size: $(echo "scale=2; $TOTAL_OPTIMIZED_SIZE / 1024 / 1024" | bc) MB"
echo -e "   Saved: ${GREEN}$(echo "scale=2; $TOTAL_SAVINGS / 1024 / 1024" | bc) MB ($TOTAL_PERCENT%)${NC}"
echo ""

# Re-encode icons back to preset
echo -e "${YELLOW}Re-encoding icons into preset...${NC}"

cp "$PRESET_FILE" "$OUTPUT_FILE"

for icon in "$ICON_DIR"/*.png; do
    if [ -f "$icon" ]; then
        UUID=$(basename "$icon" .png)
        BASE64_DATA=$(base64 -i "$icon")
        
        # Update icon data in JSON
        jq --arg uuid "$UUID" --arg data "$BASE64_DATA" \
           '(.BTTPresetContent[].BTTTriggers[]? | select(.BTTUUID == $uuid) | .BTTIconData) = $data' \
           "$OUTPUT_FILE" > "$OUTPUT_FILE.tmp" && mv "$OUTPUT_FILE.tmp" "$OUTPUT_FILE"
        
        echo -e "   ✅ Updated icon for $UUID"
    fi
done

echo -e "${GREEN}✅ All icons re-encoded${NC}"
echo ""

# Final size comparison
ORIGINAL_PRESET_SIZE=$(stat -f%z "$PRESET_FILE")
NEW_PRESET_SIZE=$(stat -f%z "$OUTPUT_FILE")
PRESET_SAVINGS=$((ORIGINAL_PRESET_SIZE - NEW_PRESET_SIZE))

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                  ICON OPTIMIZATION COMPLETE                          ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}📊 Results:${NC}"
echo -e "   Icons optimized: $EXTRACTED_COUNT"
echo -e "   Icon savings: $(echo "scale=2; $TOTAL_SAVINGS / 1024 / 1024" | bc) MB"
echo -e "   Preset file savings: $(echo "scale=2; $PRESET_SAVINGS / 1024 / 1024" | bc) MB"
echo ""
echo -e "${BLUE}📁 Output:${NC}"
echo -e "   Optimized preset: ${GREEN}presetjson-optimized-icons.bttpreset${NC}"
echo -e "   Icon files: ${BLUE}$ICON_DIR/${NC}"
echo ""
echo -e "${YELLOW}⚠️  Next Steps:${NC}"
echo -e "   1. Test optimized preset in BTT"
echo -e "   2. Verify icon quality is acceptable"
echo -e "   3. If satisfied, package as .bttpresetzip"
echo -e "   4. Clean up temp files: ${BLUE}rm -rf $ICON_DIR${NC}"
echo ""
