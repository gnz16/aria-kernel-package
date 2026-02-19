#!/bin/bash

# Configuration
# Note: Scripts using this should ensure SOURCE_DIR is correct for the specific project.
SOURCE_DIR="./_scripts"
BACKUP_DIR="$HOME/Desktop/APPM_BACKUPS"
FILES=("appm_state.json" "LOGIC_LOG.md")

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Copy files
for file in "${FILES[@]}"; do
    if [ -f "$SOURCE_DIR/$file" ]; then
        cp "$SOURCE_DIR/$file" "$BACKUP_DIR/$file"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backed up $file to Desktop."
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Warning: $file not found in $SOURCE_DIR."
    fi
done
