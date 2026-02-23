#!/usr/bin/env bash
# init-memory-git.sh — Bootstrap git versioning for ARIA memory directory
# Run once to initialize the git repo. Safe to re-run (idempotent).
# Usage: bash /root/.aria-bridge/hooks/init-memory-git.sh

set -euo pipefail

MEMORY_DIR="/root/.claude/projects/-root/memory"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║         ARIA Memory Git Init                         ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

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
  git -C "$MEMORY_DIR" status --short
fi

echo ""
echo "  To commit memory changes after a session:"
echo "    git -C $MEMORY_DIR add -A"
echo "    git -C $MEMORY_DIR -c user.email=aria@local -c user.name='ARIA Archivist' commit -m 'memory: <description>'"
echo ""
echo "  To view history:"
echo "    git -C $MEMORY_DIR log --oneline"
echo ""
echo "── init-memory-git.sh complete ─────────────────────────"
echo ""
