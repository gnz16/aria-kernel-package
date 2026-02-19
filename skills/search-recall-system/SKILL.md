---
name: search-recall-system
description: >-
  Cross-tier memory search and recall for ARIA. Indexes and retrieves
  information across volatile, strategic, and immutable memory tiers with
  semantic understanding, temporal search, and pattern-based queries.
tags:
  - memory
  - search
  - recall
  - semantic
  - retrieval
  - arria
triggers:
  - keyword: search
  - keyword: recall
  - keyword: find
  - keyword: lookup
  - keyword: memory
  - keyword: query
maintainer: ARIA Enhanced Team
version: 1.0.0
---

# Search & Recall System Skill

## What This Does

Enables ARIA to search and retrieve information across all memory tiers:
- Volatile (CONTINUITY.md)
- Strategic (STRATEGIC_LEDGER.md)
- Immutable (AGENTS.md, SOUL.md, ARIA_KERNEL.md)
- Pattern library (RESONANCE_PATTERNS.md)

Supports direct match, semantic search, pattern queries, and temporal ranges.

## How It Works

### Indexing

Three-tier index maintained automatically:
1. **Ephemeral**: In-memory index of current session entries
2. **Persistent**: Disk-based JSON/SQLite with full-text search
3. **Immutable**: Read-only keyword/semantic index of kernel files

On each memory write, index updates incrementally. Full reindex nightly.

### Query Types

```bash
# Direct keyword
aria-search "OAuth2"

# Semantic search
aria-search --semantic "secure authentication design"

# Pattern-based
aria-search --pattern "dissonance:Intent" --pattern "blend:Strategic Architect"

# Temporal
aria-search --since "2 days ago" --until "now"

# Tier-specific
aria-search --tier strategic "key decisions"
aria-search --tier volatile "last RARV cycle"
```

## Usage

```bash
# Interactive search
aria-search "query"

# JSON output
aria-search --json "blend:Auditor"

# Count only
aria-search --count "security"

# Export results
aria-search --export results.json
```

## During Session Recall

When user asks: "How did we handle authentication?"

ARIA automatically:
1. Searches volatile for recent cycles
2. Cross-references strategic for decisions
3. Checks pattern library for resonance effectiveness
4. Synthesizes answer with provenance: `[Recall: 2025-02-17, decision D-042, blend: Strategic Architect (92% effective)]`

## Search Results Format

Standard output:
```
📋 Search Results: "OAuth2" (3 matches)

1. [Volatile] 2025-02-18 10:30
   Context: RARV cycle about auth patterns
   Snippet: "explored OAuth2 vs JWT → chose short-lived JWTs with refresh"
   Tags: auth, security, OAuth2, JWT
   Relevance: 0.94

2. [Strategic] Decision D-042 (2025-02-17)
   Context: Auth strategy decision
   Snippet: "Adopted short-lived JWTs with rotation for stateless auth"
   Impact: "Improved scalability, added refresh complexity"
   Relevance: 0.91

3. [Pattern] Resonance Pattern RP-001
   Context: Security audit domain
   Snippet: "Hephaestus+Athena (70/30) achieves 95% effectiveness"
   Relevance: 0.67
```

## Index Maintenance

- **Real-time**: Incremental updates on writes
- **Hourly**: Health check, index corruption detection
- **Daily 02:00**: Full reindex, old entries pruning
- **Manual**: `aria-search --reindex`

## Performance

- Query latency: < 100ms for simple, < 500ms for semantic
- Index size: ~1KB per 100 memory entries
- Memory usage: ~50MB for typical working set

---

*ARIA v7.7-enhanced*
*Recall is resonance across time.*
