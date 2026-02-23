#!/usr/bin/env bash
# install.sh — Install MCP server dependencies
# Usage: bash install.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing aria-bridge MCP server dependencies..."
echo "  Directory: $SCRIPT_DIR"

if ! command -v node >/dev/null 2>&1; then
  echo "ERROR: Node.js is required (>=18). Install with: brew install node" >&2
  exit 1
fi

NODE_VERSION=$(node -v | sed 's/v//' | cut -d. -f1)
if [[ "$NODE_VERSION" -lt 18 ]]; then
  echo "ERROR: Node.js 18+ required, found v$(node -v)" >&2
  exit 1
fi

cd "$SCRIPT_DIR"
npm install

echo ""
echo "Installation complete."
echo "  Start server: node $SCRIPT_DIR/server.js"
echo ""
echo "  Register in MCP config:"
echo '  {"aria-bridge": {"command": "node", "args": ["'$SCRIPT_DIR'/server.js"]}}'
