---
name: memory-compression-engine
description: >-
  Semantic compression engine for ARIA memory system. Automatically compresses
  CONTINUITY.md when approaching line limits, distilling RARV cycles,
  dissonance events, and learnings into condensed summaries while preserving
  semantic meaning and pattern value.
tags:
  - memory
  - compression
  - arria
  - continuity
  - semantic-summarization
 triggers:
  - keyword: compress
  - keyword: memory-compression
  - keyword: continuity
  - keyword: APM
  - file_pattern: CONTINUITY.md
  - keyword: summarize
  - keyword: archive
maintainer: ARIA Enhanced Team
version: 1.0.0
---

# Memory Compression Engine Skill

## What This Does

Automatically compresses ARIA's volatile memory (CONTINUITY.md) using semantic compression that preserves patterns, decisions, and learnings while reducing line count.

## How It Works

- Monitors line count (triggers at ≥45 lines, mandatory at ≥50)
- Applies compression strategies:
  - RARV cycle compression (multi-line → single-line)
  - Dissonance event summarization
  - Technical notes distillation
  - Learning pattern extraction
- Maintains semantic meaning while reducing size 50-70%
- Archives compressed sessions to monthly rollups

## Usage

```bash
# Manually trigger compression
aria-compress

# Compress with archive
aria-compress --archive

# Force compression even if under threshold
aria-compress --force

# Show what would be compressed (dry-run)
aria-compress --dry-run
```

## Compression Format

Before:
```markdown
[10:30] REASON Explore auth patterns
- examined OAuth2 vs JWT
- decision: short-lived JWTs
[10:45] ACT Implemented token system
```

After:
```markdown
[10:30] Auth: OAuth2 vs JWT analysis → short-lived JWTs (RARV: REASON+ACT)
```

## Integration

- Part of ARIA's 4-Tier Memory system (Tier 1 → Semi-Stable)
- Updates memory health metrics automatically
- Triggers search index rebuild after compression
- Logs compression events to LOGIC_LOG.md

## Configuration

Settings in `appm_state.json`:
```json
{
  "memory_health": {
    "compression_threshold": 45,
    "compression_mandatory": 50,
    "target_ratio": 0.4,
    "preserve_last_n_cycles": 3
  }
}
```

## Performance

- Compression speed: ~50 lines/sec
- Semantic retention: >90% (validated by pattern match tests)
- Archive size reduction: 60-70%

---
*ARIA v7.7-enhanced*
*Compression is intelligent forgetfulness.*
