#!/usr/bin/env bash
# session-start.sh — ARIA startup auto-clone guard
# Checks if /root/.aria-skills/ is a valid git repo; re-clones if missing or broken.
# Usage: bash /root/.aria-bridge/hooks/session-start.sh

set -euo pipefail

SKILLS_DIR="/root/.aria-skills"
REPO_URL="https://github.com/gnz16/aria-kernel-package"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║         ARIA Session Start Guard                     ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "  Timestamp : $TIMESTAMP"
echo ""

# --- Check if skills directory exists and is a valid git repo ---
NEEDS_CLONE=false

if [[ ! -d "$SKILLS_DIR" ]]; then
  echo "  [WARN] Skills directory not found: $SKILLS_DIR"
  NEEDS_CLONE=true
elif ! git -C "$SKILLS_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
  echo "  [WARN] Skills directory exists but is not a valid git repo: $SKILLS_DIR"
  NEEDS_CLONE=true
else
  REMOTE_URL=$(git -C "$SKILLS_DIR" remote get-url origin 2>/dev/null || echo "none")
  echo "  Skills repo: OK"
  echo "    Path   : $SKILLS_DIR"
  echo "    Remote : $REMOTE_URL"
  SKILL_COUNT=$(find "$SKILLS_DIR/skills" -name "SKILL.md" 2>/dev/null | wc -l || echo 0)
  echo "    Skills : $SKILL_COUNT SKILL.md files found"
fi

# --- Re-clone if needed ---
if [[ "$NEEDS_CLONE" == "true" ]]; then
  echo ""
  echo "  Re-cloning from: $REPO_URL"
  # Remove broken directory if it exists but isn't a valid repo
  if [[ -d "$SKILLS_DIR" ]] && ! git -C "$SKILLS_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
    echo "  Removing broken directory before re-clone..."
    rm -rf "$SKILLS_DIR"
  fi
  git clone "$REPO_URL" "$SKILLS_DIR"
  echo "  Clone complete: $SKILLS_DIR"
  SKILL_COUNT=$(find "$SKILLS_DIR/skills" -name "SKILL.md" 2>/dev/null | wc -l || echo 0)
  echo "  Skills found: $SKILL_COUNT"
fi

echo ""
echo "── Session start guard complete ────────────────────────"
echo ""
