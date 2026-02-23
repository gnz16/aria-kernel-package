#!/usr/bin/env bash
# watch-bridge.sh — Live dashboard: polls aria-status.sh every 2 seconds
# Usage: bash /root/.aria-bridge/watch-bridge.sh

exec watch -n 2 bash /root/.aria-bridge/aria-status.sh
