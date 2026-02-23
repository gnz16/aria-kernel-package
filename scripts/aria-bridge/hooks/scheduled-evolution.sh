#!/usr/bin/env bash
# scheduled-evolution.sh — ARIA automated health check
# Runs unattended to verify framework coherence.
# Usage: bash hooks/scheduled-evolution.sh

set -uo pipefail

BRIDGE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
ISSUES=0

# Platform detection
if [[ "$(uname)" == "Darwin" ]]; then
  SKILLS_DIR="${HOME}/.gemini/skills"
  MEMORY_DIR="${HOME}/.gemini/antigravity/scratch/_scripts"
  KERNEL_FILE="${HOME}/.gemini/GEMINI.md"
else
  SKILLS_DIR="${HOME}/.aria-skills"
  MEMORY_DIR="${HOME}/.claude/projects/-root/memory"
  KERNEL_FILE="${HOME}/.claude/CLAUDE.md"
fi

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║   ARIA Scheduled Evolution — Health Check            ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "  Timestamp : $TIMESTAMP"
echo "  Platform  : $(uname -s) $(uname -m)"
echo ""

# --- 1. Kernel version check ---
echo "  1. Kernel:"
if [[ -f "$KERNEL_FILE" ]]; then
  VERSION=$(grep -m1 "Version.*7\." "$KERNEL_FILE" 2>/dev/null | head -1 || echo "UNKNOWN")
  echo "    File    : $KERNEL_FILE"
  echo "    Version : $VERSION"
else
  echo "    [WARN] Kernel not found: $KERNEL_FILE"
  ISSUES=$((ISSUES + 1))
fi

# --- 2. Skills directory ---
echo ""
echo "  2. Skills:"
if [[ -d "$SKILLS_DIR" ]]; then
  SKILL_COUNT=$(find "$SKILLS_DIR" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
  echo "    Path   : $SKILLS_DIR"
  echo "    Count  : $SKILL_COUNT SKILL.md files"
  if [[ "$SKILL_COUNT" -lt 10 ]]; then
    echo "    [WARN] Low skill count — may need re-clone"
    ISSUES=$((ISSUES + 1))
  fi
else
  echo "    [WARN] Skills directory not found: $SKILLS_DIR"
  ISSUES=$((ISSUES + 1))
fi

# --- 3. Bridge health ---
echo ""
echo "  3. Bridge:"
echo "    Dir : $BRIDGE_DIR"
for f in BRIDGE.md shared-context/project-state.md shared-context/delta.md; do
  if [[ -f "$BRIDGE_DIR/$f" ]]; then
    LINES=$(wc -l < "$BRIDGE_DIR/$f" | tr -d ' ')
    printf "    %-35s %s lines\n" "$f" "$LINES"
  else
    printf "    %-35s [MISSING]\n" "$f"
  fi
done

# --- 4. Memory size ---
echo ""
echo "  4. Memory:"
if [[ -d "$MEMORY_DIR" ]]; then
  for mf in CONTINUITY.md MEMORY.md STRATEGIC_LEDGER.md; do
    if [[ -f "$MEMORY_DIR/$mf" ]]; then
      ML=$(wc -l < "$MEMORY_DIR/$mf" | tr -d ' ')
      WARN=""
      [[ "$ML" -gt 200 ]] && WARN=" [WARN: over 200 lines]" && ISSUES=$((ISSUES + 1))
      printf "    %-25s %s lines%s\n" "$mf" "$ML" "$WARN"
    fi
  done
else
  echo "    Memory dir not found: $MEMORY_DIR"
fi

# --- 5. Evolution log ---
echo ""
echo "  5. Evolution log:"
EVOLUTION_LOG="$BRIDGE_DIR/evolution-log.md"
if [[ -f "$EVOLUTION_LOG" ]]; then
  ENTRY_COUNT=$(grep -cE "^## Entry" "$EVOLUTION_LOG" 2>/dev/null || echo "0")
  LAST=$(grep -m1 "^## Entry" "$EVOLUTION_LOG" 2>/dev/null || echo "none")
  echo "    Entries : $ENTRY_COUNT"
  echo "    Latest  : $LAST"
else
  echo "    [INFO] Evolution log not found — run rotate-log.sh to create"
fi

# --- Summary ---
echo ""
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [[ "$ISSUES" -eq 0 ]]; then
  echo "  Result: ✅ ALL CHECKS PASSED"
else
  echo "  Result: ⚠️  $ISSUES issue(s) found — review above"
fi
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
