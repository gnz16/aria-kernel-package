#!/usr/bin/env bash
# install-cron.sh — Install daily ARIA health check
# macOS: uses launchd (primary) or crontab (fallback)
# Linux: uses crontab, /etc/cron.d, or /etc/cron.daily
# Usage: bash hooks/install-cron.sh [--uninstall]

set -uo pipefail

BRIDGE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$BRIDGE_DIR/hooks/scheduled-evolution.sh"
LOG_DIR="$BRIDGE_DIR/logs"
LOG_FILE="$LOG_DIR/scheduled-evolution.log"
CRON_TAG="aria-scheduled-evolution"
CRON_SCHEDULE="0 3 * * *"
CRON_LINE="$CRON_SCHEDULE bash $SCRIPT >> $LOG_FILE 2>&1 # $CRON_TAG"

UNINSTALL=false
[[ "${1:-}" == "--uninstall" ]] && UNINSTALL=true

echo ""
echo "ARIA Health Check Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Script   : $SCRIPT"
echo "  Schedule : daily at 03:00 UTC"
echo "  Platform : $(uname -s)"
echo ""

# Verify target script exists
if [[ ! -f "$SCRIPT" ]]; then
  echo "ERROR: $SCRIPT does not exist." >&2
  exit 1
fi

mkdir -p "$LOG_DIR"

# ─── Method 0: macOS launchd (preferred on Darwin) ────────────────────────────
if [[ "$(uname)" == "Darwin" ]]; then
  PLIST_DIR="$HOME/Library/LaunchAgents"
  PLIST_FILE="$PLIST_DIR/com.aria.evolution.plist"
  LABEL="com.aria.evolution"

  echo "  Method: macOS launchd (LaunchAgent)"

  if $UNINSTALL; then
    launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
    rm -f "$PLIST_FILE"
    echo "  Status: uninstalled ($PLIST_FILE removed)"
    exit 0
  fi

  if [[ -f "$PLIST_FILE" ]]; then
    echo "  Status: already installed (idempotent — no change)"
    echo "    $PLIST_FILE"
    exit 0
  fi

  mkdir -p "$PLIST_DIR"
  cat > "$PLIST_FILE" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>$SCRIPT</string>
  </array>
  <key>StandardOutPath</key>
  <string>$LOG_FILE</string>
  <key>StandardErrorPath</key>
  <string>$LOG_FILE</string>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key>
    <integer>3</integer>
    <key>Minute</key>
    <integer>0</integer>
  </dict>
  <key>RunAtLoad</key>
  <false/>
</dict>
</plist>
PLIST

  launchctl bootstrap "gui/$(id -u)" "$PLIST_FILE" 2>/dev/null || \
    launchctl load "$PLIST_FILE" 2>/dev/null || true
  echo "  Status: installed successfully"
  echo "    Plist  : $PLIST_FILE"
  echo "    Log    : $LOG_FILE"
  echo ""
  echo "  Commands:"
  echo "    Verify  : launchctl list | grep aria"
  echo "    Manual  : bash $SCRIPT"
  echo "    Remove  : bash $0 --uninstall"
  exit 0
fi

# ─── Method 1: crontab (standard — Linux/other) ──────────────────────────────
if command -v crontab >/dev/null 2>&1; then
  echo "  Method: crontab(1)"

  if $UNINSTALL; then
    ( crontab -l 2>/dev/null | grep -v "$CRON_TAG" ) | crontab -
    echo "  Status: uninstalled"
    exit 0
  fi

  if crontab -l 2>/dev/null | grep -q "$CRON_TAG"; then
    echo "  Status: already installed (idempotent)"
    crontab -l 2>/dev/null | grep "$CRON_TAG"
    exit 0
  fi

  ( crontab -l 2>/dev/null; echo "$CRON_LINE" ) | crontab -
  echo "  Status: installed"
  echo "  Entry : $CRON_LINE"
  exit 0
fi

echo "  Note: crontab not found. Trying fallback methods."
echo ""

# ─── Method 2: /etc/cron.d (requires root) ───────────────────────────────────
SYSTEM_CRONTAB_DIR="/etc/cron.d"
SYSTEM_CRONTAB_FILE="$SYSTEM_CRONTAB_DIR/aria-evolution"

if [[ -d "$SYSTEM_CRONTAB_DIR" ]] && [[ -w "$SYSTEM_CRONTAB_DIR" ]]; then
  echo "  Method: /etc/cron.d drop-in"

  if $UNINSTALL; then
    rm -f "$SYSTEM_CRONTAB_FILE"
    echo "  Status: uninstalled"
    exit 0
  fi

  if [[ -f "$SYSTEM_CRONTAB_FILE" ]]; then
    echo "  Status: already installed"
    exit 0
  fi

  cat > "$SYSTEM_CRONTAB_FILE" <<EOF
# ARIA scheduled evolution health check
$CRON_SCHEDULE root bash $SCRIPT >> $LOG_FILE 2>&1
EOF
  chmod 644 "$SYSTEM_CRONTAB_FILE"
  echo "  Status: installed at $SYSTEM_CRONTAB_FILE"
  exit 0
fi

# ─── No automatic method ─────────────────────────────────────────────────────
echo ""
echo "  No automatic installation method available."
echo ""
echo "  Manual option — run any time:"
echo "    bash $SCRIPT"
echo ""
exit 1
