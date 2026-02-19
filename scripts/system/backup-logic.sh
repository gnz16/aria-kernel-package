#!/bin/bash

# Configuration
SOURCE_DIR="/Users/apple/.gemini/_scripts"
BACKUP_DIR="/Users/apple/.gemini/appm_backups"
DESKTOP_BACKUP_DIR="/Users/apple/Desktop/APPM_BACKUPS"
FILES=("appm_state.json" "LOGIC_LOG.md")

# Create backup directories
mkdir -p "$BACKUP_DIR"
mkdir -p "$DESKTOP_BACKUP_DIR" 2>/dev/null

# Copy files
for file in "${FILES[@]}"; do
    if [ -f "$SOURCE_DIR/$file" ]; then
        # Local Backup
        if cp "$SOURCE_DIR/$file" "$BACKUP_DIR/$file"; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backed up $file to $BACKUP_DIR."
        fi
        
        # Desktop Backup (May fail due to macOS permissions)
        if [ -d "$DESKTOP_BACKUP_DIR" ]; then
            if cp "$SOURCE_DIR/$file" "$DESKTOP_BACKUP_DIR/$file" 2>/dev/null; then
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backed up $file to $DESKTOP_BACKUP_DIR."
            else
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] Desktop backup skipped (Permission Denied)."
            fi
        fi
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Warning: $file not found in $SOURCE_DIR."
    fi
done
