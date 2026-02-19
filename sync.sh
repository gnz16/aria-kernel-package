#!/bin/bash
# sync.sh — ARIA Kernel Package Sync Helper
# Usage: sync.sh [pull|deploy-claude|deploy-gemini|deploy-all]

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BOLD='\033[1m'; RESET='\033[0m'

cmd_pull() {
    echo -e "${BOLD}Pulling latest from origin...${RESET}"
    git -C "$SCRIPT_DIR" pull origin main
    echo -e "${GREEN}✅ Package updated${RESET}"
}

cmd_deploy_claude() {
    echo -e "${BOLD}Deploying kernel to Claude Code (~/.claude/)...${RESET}"
    cp "$SCRIPT_DIR/kernel/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
    echo -e "${GREEN}✅ CLAUDE.md deployed${RESET}"
}

cmd_deploy_gemini() {
    echo -e "${BOLD}Deploying kernel to Antigravity (~/.gemini/)...${RESET}"
    cp "$SCRIPT_DIR/kernel/GEMINI.md" "$HOME/.gemini/GEMINI.md"
    cp "$SCRIPT_DIR/kernel/ARIA_KERNEL.md" "$HOME/.gemini/ARIA_KERNEL.md"
    cp "$SCRIPT_DIR/kernel/ARIA_TOKEN_MGMT.md" "$HOME/.gemini/ARIA_TOKEN_MGMT.md"
    echo -e "${GREEN}✅ Gemini kernel files deployed${RESET}"
}

cmd_deploy_all() {
    cmd_deploy_claude
    cmd_deploy_gemini
    echo -e "${GREEN}✅ All agents updated${RESET}"
}

case "${1:-help}" in
    pull)          cmd_pull ;;
    deploy-claude) cmd_deploy_claude ;;
    deploy-gemini) cmd_deploy_gemini ;;
    deploy-all)    cmd_deploy_all ;;
    *)
        echo "Usage: sync.sh [pull|deploy-claude|deploy-gemini|deploy-all]"
        echo ""
        echo "  pull           Pull latest from GitHub"
        echo "  deploy-claude  Copy CLAUDE.md to ~/.claude/"
        echo "  deploy-gemini  Copy kernel files to ~/.gemini/"
        echo "  deploy-all     Deploy to all agents"
        ;;
esac
