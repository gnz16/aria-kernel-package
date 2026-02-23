#!/usr/bin/env bash
# init-memory-git.sh — Bootstrap git versioning for ARIA memory directory
# Run once to initialize. Safe to re-run (idempotent).
# Usage: bash hooks/init-memory-git.sh

set -euo pipefail

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Platform-aware memory directory
if [[ "$(uname)" == "Darwin" ]]; then
  MEMORY_DIR="${HOME}/.gemini/antigravity/scratch/_scripts"
else
  MEMORY_DIR="${HOME}/.claude/projects/-root/memory"
fi

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║         ARIA Memory Git Init                         ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

if [[ ! -d "$MEMORY_DIR" ]]; then
  echo "  Memory directory does not exist: $MEMORY_DIR"
  echo "  Nothing to do."
  exit 0
fi

if ! git -C "$MEMORY_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
  echo "  Initializing git repo at: $MEMORY_DIR"
  git -C "$MEMORY_DIR" init
  git -C "$MEMORY_DIR" -c user.email="aria@local" -c user.name="ARIA Archivist" \
    add -A
  git -C "$MEMORY_DIR" -c user.email="aria@local" -c user.name="ARIA Archivist" \
    commit -m "chore: initialize git-backed memory versioning [$TIMESTAMP]"
  echo "  Git repo initialized with initial commit."
else
  echo "  Memory directory is already a git repo — nothing to do."
  git -C "$MEMORY_DIR" log --oneline -3 2>/dev/null | sed 's/^/    /'
fi

echo ""
echo "  To commit memory changes after a session:"
echo "    git -C $MEMORY_DIR add -A"
echo "    git -C $MEMORY_DIR commit -m 'memory: <description>'"
echo ""
echo "── init-memory-git.sh complete ─────────────────────────"
echo ""
