#!/usr/bin/env bash
# session-start.sh — ARIA startup auto-clone guard
# Checks if skills repo is valid; re-clones if missing or broken.
# Usage: bash hooks/session-start.sh

set -euo pipefail

# Cross-platform portability
BRIDGE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REPO_URL="https://github.com/gnz16/aria-kernel-package"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Detect skills directory (macOS vs Linux)
if [[ "$(uname)" == "Darwin" ]]; then
  SKILLS_DIR="${HOME}/.gemini/skills"
else
  SKILLS_DIR="${HOME}/.aria-skills"
fi

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║         ARIA Session Start Guard                     ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "  Timestamp : $TIMESTAMP"
echo "  Platform  : $(uname -s) $(uname -m)"
echo ""

# --- Check if skills directory exists and is valid ---
NEEDS_CLONE=false

if [[ ! -d "$SKILLS_DIR" ]]; then
  echo "  [WARN] Skills directory not found: $SKILLS_DIR"
  NEEDS_CLONE=true
elif [[ -d "$SKILLS_DIR/.git" ]] && ! git -C "$SKILLS_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
  echo "  [WARN] Skills directory exists but git repo is broken: $SKILLS_DIR"
  NEEDS_CLONE=true
else
  SKILL_COUNT=$(find "$SKILLS_DIR" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
  echo "  Skills repo: OK"
  echo "    Path   : $SKILLS_DIR"
  echo "    Skills : $SKILL_COUNT SKILL.md files found"
fi

# --- Re-clone if needed ---
if [[ "$NEEDS_CLONE" == "true" ]]; then
  echo ""
  echo "  Re-cloning from: $REPO_URL"
  if [[ -d "$SKILLS_DIR" ]] && [[ -d "$SKILLS_DIR/.git" ]]; then
    rm -rf "$SKILLS_DIR"
  fi
  git clone "$REPO_URL" "$SKILLS_DIR"
  echo "  Clone complete: $SKILLS_DIR"
  SKILL_COUNT=$(find "$SKILLS_DIR" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
  echo "  Skills found: $SKILL_COUNT"
fi

# --- Bridge health ---
echo ""
echo "  Bridge dir: $BRIDGE_DIR"
if [[ -f "$BRIDGE_DIR/shared-context/project-state.md" ]]; then
  LINES=$(wc -l < "$BRIDGE_DIR/shared-context/project-state.md" | tr -d ' ')
  echo "  project-state.md : $LINES lines"
else
  echo "  project-state.md : NOT FOUND"
fi

echo ""
echo "── Session start guard complete ────────────────────────"
echo ""
