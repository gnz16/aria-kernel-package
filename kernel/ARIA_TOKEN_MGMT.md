# ARIA Token Usage Reduction Mechanisms

## Active Mechanisms

### 1. Memory Tier Compression
- **Volatile Memory**: CONTINUITY.md limited to 50 lines
- **Strategic Memory**: STRATEGIC_LEDGER.md limited to 30 lines  
- **Compression**: Automatic summarization and archiving via `compression_engine.sh`
- **Health Monitoring**: `memory_health.sh` checks limits every hour

### 2. Context Window Management
- **Serial Position Optimization**: Important content placed at start/end of context
- **Intelligent Summarization**: Summarize by importance, not just recency
- **Tiered Context Strategy**: Different strategies based on context size
- **Token Counting**: Active monitoring of token usage

### 3. DesktopCommanderMCP Integration
- **Direct File Operations**: Read/write files without chat descriptions
- **Terminal Control**: Execute commands directly, reducing conversational overhead
- **Process Management**: Long-running processes managed outside chat context
- **Search/Replace**: Surgical edits avoid full file rewrites

### 4. Conversation Memory (Optional)
- Persistent chat history storage
- Entity-based memory for key information
- Retrieval-augmented generation for context

## Setup Instructions

### Memory Health Monitor (Already Installed)
```bash
# Check health
~/.gemini/_scripts/memory_health.sh

# Manual compression
~/.gemini/_scripts/compression_engine.sh
```

### Automated Scheduling (LaunchAgent for macOS)
Create `~/Library/LaunchAgents/com.aria.memory-health.plist`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.aria.memory-health</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/apple/.gemini/_scripts/memory_health.sh</string>
    </array>
    <key>StartInterval</key>
    <integer>3600</integer>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/Users/apple/.gemini/_scripts/logs/memory-health.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/apple/.gemini/_scripts/logs/memory-health.err</string>
</dict>
</plist>
```

Load: `launchctl load ~/Library/LaunchAgents/com.aria.memory-health.plist`

### Context Window Strategies
The `context-window-management` skill is loaded automatically when:
- Conversation exceeds 1000 tokens
- Multiple files are being discussed
- Code generation tasks are detected

Strategies applied:
- **Trim old turns**: Keep last 5 turns + key references
- **Summarize long files**: Files > 500 lines get summary + key snippets
- **Use embeddings**: For very long conversations, semantic search finds relevant history

## Verification

Run these commands to verify setup:

```bash
# 1. Memory health
~/.gemini/_scripts/memory_health.sh

# 2. DesktopCommander status
npx @wonderwhy-er/desktop-commander@latest status

# 3. Check ARIA state
cat ~/.gemini/_scripts/appm_state.json | jq '.memory_health'

# 4. View recent compression logs
tail -20 ~/.gemini/_scripts/compression.log
```

## Configuration

Edit `~/.gemini/_scripts/appm_state.json` to customize thresholds:
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
    "compression_delay_minutes": 30
  }
}
```

## Token Savings Estimates

- **Memory Compression**: ~20-40% reduction in system prompt size
- **Context Trimming**: ~30-50% reduction in conversation history
- **DesktopCommander**: ~50-70% reduction in file descriptions (use file paths instead)
- **Combined**: Potential for 60-80% overall token reduction in active sessions

## Best Practices

1. **Always use DesktopCommander for file operations** - say "edit file X" rather than pasting content
2. **Monitor memory health** - run `memory_health.sh` before long sessions
3. **Compress regularly** - especially after completing large tasks
4. **Let ARIA auto-summarize** - don't fight compression; trust the system
