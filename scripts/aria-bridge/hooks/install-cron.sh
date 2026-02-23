#!/usr/bin/env bash
# install-cron.sh — Idempotent installer for the ARIA scheduled-evolution cron job
#
# Attempts to install a daily cron job (03:00 UTC) that runs scheduled-evolution.sh.
# Safe to run multiple times — will not add a duplicate entry.
#
# On PRoot/mobile Linux where crontab(1) is unavailable but crond is present,
# this script falls back to writing a system-level crontab file instead.
#
# Usage:
#   bash /root/.aria-bridge/hooks/install-cron.sh
#   bash /root/.aria-bridge/hooks/install-cron.sh --uninstall

set -uo pipefail

BRIDGE_DIR="/root/.aria-bridge"
SCRIPT="$BRIDGE_DIR/hooks/scheduled-evolution.sh"
LOG_FILE="$BRIDGE_DIR/logs/scheduled-evolution.log"
CRON_TAG="aria-scheduled-evolution"
CRON_SCHEDULE="0 3 * * *"
CRON_LINE="$CRON_SCHEDULE bash $SCRIPT >> $LOG_FILE 2>&1 # $CRON_TAG"

# System crontab fallback paths (tried in order)
SYSTEM_CRONTAB_DIR="/etc/cron.d"
SYSTEM_CRONTAB_FILE="$SYSTEM_CRONTAB_DIR/aria-evolution"
CRON_DAILY_DIR="/etc/cron.daily"
CRON_DAILY_SCRIPT="$CRON_DAILY_DIR/aria-evolution"

# ── Argument handling ─────────────────────────────────────────────────────────
UNINSTALL=false
[[ "${1:-}" == "--uninstall" ]] && UNINSTALL=true

echo ""
echo "ARIA Cron Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Script : $SCRIPT"
echo "  Schedule: daily at 03:00 UTC"
echo ""

# ── Verify target script exists ───────────────────────────────────────────────
if [[ ! -f "$SCRIPT" ]]; then
  echo "ERROR: $SCRIPT does not exist. Cannot install cron job." >&2
  exit 1
fi

mkdir -p "$BRIDGE_DIR/logs"

# ─────────────────────────────────────────────────────────────────────────────
# Method 1: crontab(1) command — standard user cron
# ─────────────────────────────────────────────────────────────────────────────
if command -v crontab >/dev/null 2>&1; then
  echo "  Method: crontab(1) found — using user crontab"

  if $UNINSTALL; then
    # Remove lines matching our tag
    ( crontab -l 2>/dev/null | grep -v "$CRON_TAG" ) | crontab -
    echo "  Status: uninstalled (tag: $CRON_TAG)"
    exit 0
  fi

  # Check if already installed
  if crontab -l 2>/dev/null | grep -q "$CRON_TAG"; then
    echo "  Status: already installed (idempotent — no change)"
    crontab -l 2>/dev/null | grep "$CRON_TAG"
    exit 0
  fi

  # Install
  ( crontab -l 2>/dev/null; echo "$CRON_LINE" ) | crontab -
  echo "  Status: installed successfully"
  echo "  Entry : $CRON_LINE"
  exit 0
fi

echo "  Note: crontab(1) not found. Trying fallback methods."
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Method 2: /etc/cron.d drop-in (requires root write access)
# ─────────────────────────────────────────────────────────────────────────────
if [[ -d "$SYSTEM_CRONTAB_DIR" ]] && [[ -w "$SYSTEM_CRONTAB_DIR" ]]; then
  echo "  Method: /etc/cron.d drop-in"

  if $UNINSTALL; then
    rm -f "$SYSTEM_CRONTAB_FILE"
    echo "  Status: uninstalled ($SYSTEM_CRONTAB_FILE removed)"
    exit 0
  fi

  if [[ -f "$SYSTEM_CRONTAB_FILE" ]]; then
    echo "  Status: already installed at $SYSTEM_CRONTAB_FILE (idempotent — no change)"
    cat "$SYSTEM_CRONTAB_FILE"
    exit 0
  fi

  # /etc/cron.d format requires a username field
  cat > "$SYSTEM_CRONTAB_FILE" << EOF
# ARIA scheduled evolution health check
# Installed by: $BRIDGE_DIR/hooks/install-cron.sh
# Tag: $CRON_TAG
$CRON_SCHEDULE root bash $SCRIPT >> $LOG_FILE 2>&1
EOF
  chmod 644 "$SYSTEM_CRONTAB_FILE"
  echo "  Status: installed at $SYSTEM_CRONTAB_FILE"
  exit 0
fi

# ─────────────────────────────────────────────────────────────────────────────
# Method 3: /etc/cron.daily script (no time precision, runs once daily)
# ─────────────────────────────────────────────────────────────────────────────
if [[ -d "$CRON_DAILY_DIR" ]] && [[ -w "$CRON_DAILY_DIR" ]]; then
  echo "  Method: /etc/cron.daily wrapper script"

  if $UNINSTALL; then
    rm -f "$CRON_DAILY_SCRIPT"
    echo "  Status: uninstalled ($CRON_DAILY_SCRIPT removed)"
    exit 0
  fi

  if [[ -f "$CRON_DAILY_SCRIPT" ]]; then
    echo "  Status: already installed at $CRON_DAILY_SCRIPT (idempotent — no change)"
    exit 0
  fi

  cat > "$CRON_DAILY_SCRIPT" << EOF
#!/usr/bin/env bash
# ARIA scheduled evolution — daily health check
# Installed by: $BRIDGE_DIR/hooks/install-cron.sh
bash $SCRIPT >> $LOG_FILE 2>&1
EOF
  chmod +x "$CRON_DAILY_SCRIPT"
  echo "  Status: installed at $CRON_DAILY_SCRIPT"
  exit 0
fi

# ─────────────────────────────────────────────────────────────────────────────
# No automatic method succeeded — print manual instructions
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "  RESULT: Automatic cron installation not available on this system."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  MANUAL INSTALLATION OPTIONS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  This device (PRoot/mobile Linux) does not have crontab(1),"
echo "  writable /etc/cron.d, or writable /etc/cron.daily."
echo ""
echo "  Option A: Termux crond (recommended for Termux/PRoot)"
echo "  ─────────────────────────────────────────────────────"
echo "  1. Install cronie in Termux (if not present):"
echo "       pkg install cronie"
echo ""
echo "  2. Start crond in the background:"
echo "       crond"
echo "     Or add to your ~/.bashrc / ~/.profile:"
echo "       command -v crond >/dev/null && crond"
echo ""
echo "  3. Install the cron entry once crond is running:"
echo "       (crontab -l 2>/dev/null; echo \"$CRON_LINE\") | crontab -"
echo ""
echo "  Option B: Termux boot (run at device boot via Termux:Boot)"
echo "  ─────────────────────────────────────────────────────────────"
echo "  1. Install Termux:Boot app"
echo "  2. Create ~/.termux/boot/aria-evolution.sh:"
echo "       #!/usr/bin/env bash"
echo "       sleep 30  # wait for network"
echo "       bash $SCRIPT >> $LOG_FILE 2>&1"
echo "  3. chmod +x ~/.termux/boot/aria-evolution.sh"
echo ""
echo "  Option C: Manual or CI trigger"
echo "  ─────────────────────────────────────────────────────"
echo "  Run the health check manually any time:"
echo "       bash $SCRIPT"
echo ""
echo "  The script is fully safe to run manually at any time."
echo ""
echo "  Option D: at(1) one-shot (if 'at' command is available)"
echo "  ─────────────────────────────────────────────────────"
echo "  Schedule a single run:"
echo "       echo \"bash $SCRIPT\" | at 03:00 tomorrow"
echo ""
exit 1
