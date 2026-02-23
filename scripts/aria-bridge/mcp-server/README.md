# ARIA Bridge MCP Server

Exposes the ARIA Constellation Bridge as a set of structured MCP tools, allowing Claude Code (and any MCP-capable client) to drive multi-agent orchestration via protocol rather than direct shell calls.

---

## Tools Provided

| Tool | Description |
|------|-------------|
| `bridge_status` | Run `aria-status.sh` — returns the full agent dashboard |
| `bridge_assign` | Assign a task to an agent inbox via `aria-assign.sh` |
| `bridge_collect` | Collect outbox results via `aria-collect.sh` |
| `bridge_sync` | Sync shared context via `aria-sync.sh` |
| `agent_inbox_read` | Read a named agent's `inbox.md` |
| `agent_inbox_write` | Append a message to a named agent's `inbox.md` |

---

## Setup

### Step 1 — Install dependencies (once)

```bash
bash /root/.aria-bridge/mcp-server/install.sh
```

This installs `@modelcontextprotocol/sdk` into `node_modules/` inside the server directory.

### Step 2 — Test the server manually (optional)

```bash
node /root/.aria-bridge/mcp-server/server.js
```

The server starts and waits on stdin for MCP protocol messages. Press Ctrl+C to exit.
Status messages go to stderr; they will not interfere with the protocol.

---

## Registering with Claude Code

Claude Code reads MCP server configuration from `~/.claude/mcp.json`.

### Option A — Global user-level registration (recommended)

Create or edit `/root/.claude/mcp.json`:

```json
{
  "mcpServers": {
    "aria-bridge": {
      "command": "node",
      "args": ["/root/.aria-bridge/mcp-server/server.js"],
      "env": {}
    }
  }
}
```

After saving, restart Claude Code (or run `/mcp` to reload). The server tools will appear prefixed as `mcp__aria-bridge__<tool-name>`.

### Option B — Project-level registration

Create or edit `.mcp.json` in your project root:

```json
{
  "aria-bridge": {
    "command": "node",
    "args": ["/root/.aria-bridge/mcp-server/server.js"]
  }
}
```

### Option C — settings.json mcpServers block

Add to `/root/.claude/settings.json`:

```json
{
  "mcpServers": {
    "aria-bridge": {
      "command": "node",
      "args": ["/root/.aria-bridge/mcp-server/server.js"]
    }
  }
}
```

---

## Verifying Registration

After restarting Claude Code, run the slash command:

```
/mcp
```

You should see `aria-bridge` in the list. Individual tools will show as:

```
mcp__aria-bridge__bridge_status
mcp__aria-bridge__bridge_assign
mcp__aria-bridge__bridge_collect
mcp__aria-bridge__bridge_sync
mcp__aria-bridge__agent_inbox_read
mcp__aria-bridge__agent_inbox_write
```

---

## Transport

This server uses **stdio** transport. Claude Code spawns the process and communicates over stdin/stdout. The server process terminates when Claude Code exits.

---

## Architecture Notes

- Shell scripts are invoked via `execFile("bash", [script, ...args])` — no shell injection surface
- Temporary task files for `bridge_assign` are written to `/tmp/` and cleaned up after the script exits
- All tool errors are returned as MCP error responses (not process crashes)
- Agent name and priority validation is performed before any shell invocation

---

## Files

```
/root/.aria-bridge/mcp-server/
├── server.js       ← MCP server entry point (Node.js, ESM)
├── package.json    ← npm manifest; dependency: @modelcontextprotocol/sdk
├── install.sh      ← One-time dependency installer
└── README.md       ← This file
```

---

## Troubleshooting

**Server not appearing in /mcp**
- Verify `node_modules/@modelcontextprotocol` exists: `ls /root/.aria-bridge/mcp-server/node_modules/`
- Check mcp.json syntax is valid JSON
- Restart Claude Code after config changes

**Tool call fails with bash error**
- Ensure bridge scripts are executable: `chmod +x /root/.aria-bridge/*.sh`
- Run `bash /root/.aria-bridge/aria-status.sh` manually to confirm the bridge is operational

**Permission denied on server.js**
- Run: `chmod +x /root/.aria-bridge/mcp-server/server.js`

---

*ARIA Bridge MCP Server v1.0.0*
*Part of ARIA Constellation Bridge v2.0*
