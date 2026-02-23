#!/usr/bin/env bash
# install.sh — Install npm dependencies for aria-bridge MCP server
# Run this once before registering the server with Claude Code.
#
# Usage: bash /root/.aria-bridge/mcp-server/install.sh

set -euo pipefail

MCP_DIR="/root/.aria-bridge/mcp-server"

echo ""
echo "ARIA Bridge MCP Server — Dependency Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Directory : $MCP_DIR"
echo ""

# Verify node is available
if ! command -v node >/dev/null 2>&1; then
  echo "ERROR: node not found. Install Node.js >= 18 first." >&2
  exit 1
fi

NODE_VERSION=$(node --version)
echo "  Node      : $NODE_VERSION"

# Verify npm is available
if ! command -v npm >/dev/null 2>&1; then
  echo "ERROR: npm not found. Install npm first." >&2
  exit 1
fi

NPM_VERSION=$(npm --version)
echo "  npm       : $NPM_VERSION"
echo ""

# Change to MCP server directory and install deps
cd "$MCP_DIR"

if [[ -d "node_modules/@modelcontextprotocol" ]]; then
  echo "  Status: @modelcontextprotocol/sdk already installed (idempotent — no change)"
  echo ""
  echo "  To force reinstall: rm -rf $MCP_DIR/node_modules && bash $MCP_DIR/install.sh"
  exit 0
fi

echo "  Installing @modelcontextprotocol/sdk ..."
npm install --prefer-offline 2>&1

echo ""
echo "  Status: Dependencies installed successfully."
echo "  Entry point: node $MCP_DIR/server.js"
echo ""
echo "  Next: Register in Claude Code (see $MCP_DIR/README.md)"
echo ""
