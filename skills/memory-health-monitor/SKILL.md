---
name: memory-health-monitor
description: >-
  Real-time health monitoring for ARIA memory system. Tracks line counts,
  growth rates, compression ratios, and alerts when thresholds breached.
  Provides dashboard and auto-maintenance triggers.
tags:
  - memory
  - monitoring
  - health
  - arria
  - metrics
triggers:
  - keyword: health
  - keyword: memory-health
  - keyword: monitor
  - keyword: status
  - keyword: dashboard
maintainer: ARIA Enhanced Team
version: 1.0.0
---

# Memory Health Monitor Skill

## What This Does

Continuously monitors ARIA's memory tiers (CONTINUITY.md, STRATEGIC_LEDGER.md) for:
- Line count thresholds
- Growth rate anomalies
- Compression efficiency
- Search index health
- Pattern library integrity

Provides dashboard, alerts, and auto-maintenance triggers.

## How It Works

### Metrics Collection (Every 5 minutes)

```python
metrics = {
  "continuity_lines": wc_l(CONTINUITY.md),
  "strategic_lines": wc_l(STRATEGIC_LEDGER.md),
  "growth_rate": (lines_now - baseline) / hours_active,
  "last_compression": get_timestamp(COMPRESSION.md),
  "compression_ratio": current_size / pre_compression_size,
  "index_entries": count(memory_index.json),
  "index_last_updated": index_meta.last_updated
}
```

### Health Score Calculation

```
Score = (
  continuityLines ≤ 50 ? 25 : 0 +
  strategicLines ≤ 30 ? 25 : 0 +
  compressionRatio in [0.3-0.5] ? 25 : 0 +
  growthRate < 15 ? 25 : 25 - (growthRate - 15)
)
```

### Alerts

| Condition | Severity | Action |
|-----------|----------|--------|
| CONTINUITY ≥ 45 | Warning | Log alert, suggest compression |
| CONTINUITY = 50 | Critical | Force compression trigger |
| STRATEGIC ≥ 28 | Warning | Suggest pruning |
| Growth > 20/hr | High | Preemptive compression recommended |
| Index corrupted | Critical | Rebuild index |

## Usage

```bash
# Show health dashboard
aria-health

# JSON format
aria-health --json

# Full report with recommendations
aria-health --full

# Force reindex
aria-health --reindex

# Prune old archives (older than N days)
aria-health --prune --older-than 90
```

## Dashboard Output

```
📊 MEMORY HEALTH [█████████░] 85/100

Volatile (Tier 1):
  • CONTINUITY.md: 42/50 lines (84%)
  • Growth rate: 8.2 lines/hr ✓
  • Last compression: 2h ago

Strategic (Tier 2):
  • STRATEGIC_LEDGER.md: 26/30 lines (87%)
  • Active priorities: 3
  • Archived decisions: 47

Compression:
  • Ratio: 0.41 (target: 0.3-0.5) ✓
  • Sessions compressed: 12
  • Semantic retention: 94%

Index:
  • Total entries: 2,841
  • Last update: 3m ago
  • Health: Good

Alerts: 0 active
```

## Integration with RARV

At each REFLECT phase:
- Check health score
- If <70: include in reflection: `"Memory health degraded to {score}. Recommend compression."`
- If critical: insert VERIFY step to run compression

At each VERIFY phase:
- Spot-check search integrity post-compression (3 random queries)

## Scheduled Maintenance

- **Hourly**: Metrics collection, alert check
- **Every 6h**: Line count assessment, auto-compression trigger if needed
- **Daily 02:00**: Full health report to LOGIC_LOG.md
- **Weekly**: Index rebuild, archive pruning
- **Monthly**: Full audit, health trend analysis

## Configuration

In `appm_state.json`:
```json
{
  "memory_health": {
    "thresholds": {
      "continuity_warn": 40,
      "continuity_critical": 45,
      "strategic_warn": 25,
      "strategic_critical": 28,
      "growth_warn": 15,
      "growth_critical": 20
    },
    "auto_compress": true,
    "compression_delay_minutes": 30,
    "notify_on_degradation": true
  }
}
```

## Troubleshooting

**Problem**: Health score stuck at <50
**Solution**: Run `aria-health --reindex && aria-compress --force`

**Problem**: Growth rate too high (>20/hr)
**Solution**: Check if session unusually active. If not, investigate root cause in CONTINUITY.md.

**Problem**: Compression ratio >0.6 (not compressing enough)
**Solution**: Adjust compression thresholds: `cont_compression_threshold: 38` (earlier trigger)

---

*ARIA v7.7-enhanced*
*Health is resonant sustainability.*
