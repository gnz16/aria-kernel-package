#!/usr/bin/env bash
# watch-bridge.sh — Live dashboard: polls aria-status.sh every 2 seconds
# Usage: bash watch-bridge.sh

BRIDGE_DIR="$(cd "$(dirname "$0")" && pwd)"
exec watch -n 2 bash "$BRIDGE_DIR/aria-status.sh"
