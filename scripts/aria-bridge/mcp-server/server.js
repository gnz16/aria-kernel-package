#!/usr/bin/env node
/**
 * aria-bridge-mcp — MCP server for the ARIA Bridge
 *
 * Exposes Bridge operations as structured MCP tools:
 *   bridge_status       — runs aria-status.sh
 *   bridge_assign       — wraps aria-assign.sh
 *   bridge_collect      — runs aria-collect.sh
 *   bridge_sync         — runs aria-sync.sh
 *   agent_inbox_read    — reads a named agent's inbox.md
 *   agent_inbox_write   — appends to a named agent's inbox.md
 *
 * Transport: stdio (spawned by Claude Code or Antigravity)
 * Usage: node server.js
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
    CallToolRequestSchema,
    ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { readFile, appendFile, access, writeFile, unlink } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import path from "node:path";

const execFileAsync = promisify(execFile);

// Auto-detect bridge directory from this script's location
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const BRIDGE_DIR = path.resolve(__dirname, "..");

const VALID_AGENTS = [
    // Tri-agent model
    "gemini", "claude", "opencode",
    // Constellation model
    "logician", "oracle", "auditor", "craftsman", "archivist",
];
const VALID_PRIORITIES = ["HIGH", "MEDIUM", "LOW"];

// ── Helper: run a bridge shell script ─────────────────────────────────────────
async function runScript(scriptPath, args = [], timeoutMs = 15000) {
    try {
        const { stdout, stderr } = await execFileAsync("bash", [scriptPath, ...args], {
            timeout: timeoutMs,
            env: {
                ...process.env,
                PATH: process.env.PATH || "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
            },
        });
        return { success: true, output: stdout, stderr: stderr || "" };
    } catch (err) {
        return {
            success: false,
            output: err.stdout || "",
            stderr: err.stderr || err.message,
            exitCode: err.code ?? -1,
        };
    }
}

function validateAgent(agent) {
    if (!VALID_AGENTS.includes(agent)) {
        throw new Error(`Invalid agent "${agent}". Valid: ${VALID_AGENTS.join(", ")}`);
    }
}

function textResult(content) {
    return { content: [{ type: "text", text: content }] };
}

// ── Tool handlers ─────────────────────────────────────────────────────────────

async function handleBridgeStatus() {
    const result = await runScript(`${BRIDGE_DIR}/aria-status.sh`);
    return textResult(result.success ? result.output : `ERROR:\n${result.stderr}\n${result.output}`);
}

async function handleBridgeAssign(args) {
    const { agent, task_id, priority = "MEDIUM", task_content } = args;
    validateAgent(agent);
    if (!task_id?.trim()) throw new Error("task_id is required.");
    if (!VALID_PRIORITIES.includes(priority)) throw new Error(`Invalid priority "${priority}".`);
    if (!task_content?.trim()) throw new Error("task_content is required.");

    const tmpFile = `/tmp/aria-mcp-task-${Date.now()}.md`;
    await writeFile(tmpFile, task_content, "utf8");
    const result = await runScript(`${BRIDGE_DIR}/aria-assign.sh`, [agent, task_id.trim(), priority, tmpFile]);
    await unlink(tmpFile).catch(() => { });

    return textResult(result.success ? result.output : `ASSIGN FAILED:\n${result.stderr}\n${result.output}`);
}

async function handleBridgeCollect(args) {
    const scriptArgs = args?.agent ? [args.agent] : [];
    if (args?.agent) validateAgent(args.agent);
    const result = await runScript(`${BRIDGE_DIR}/aria-collect.sh`, scriptArgs, 30000);
    return textResult(result.success ? result.output : `ERROR:\n${result.stderr}\n${result.output}`);
}

async function handleBridgeSync(args) {
    if (!args?.summary?.trim()) throw new Error("summary is required.");
    const result = await runScript(`${BRIDGE_DIR}/aria-sync.sh`, [args.summary.trim()]);
    return textResult(result.success ? result.output : `SYNC FAILED:\n${result.stderr}\n${result.output}`);
}

async function handleAgentInboxRead(args) {
    validateAgent(args.agent);
    const inboxPath = `${BRIDGE_DIR}/agents/${args.agent}/inbox.md`;
    try { await access(inboxPath); } catch { return textResult(`No inbox for "${args.agent}"`); }
    return textResult(await readFile(inboxPath, "utf8") || `(${args.agent} inbox is empty)`);
}

async function handleAgentInboxWrite(args) {
    validateAgent(args.agent);
    if (!args?.message?.trim()) throw new Error("message is required.");
    const inboxPath = `${BRIDGE_DIR}/agents/${args.agent}/inbox.md`;
    const timestamp = new Date().toISOString();
    await appendFile(inboxPath, `\n---\n<!-- MCP append @ ${timestamp} -->\n${args.message.trim()}\n`, "utf8");
    return textResult(`Message appended to ${args.agent} inbox at ${timestamp}`);
}

// ── Tool definitions ──────────────────────────────────────────────────────────
const TOOLS = [
    {
        name: "bridge_status",
        description: "Show ARIA Bridge status dashboard — all agent inboxes, shared context, tmux session.",
        inputSchema: { type: "object", properties: {}, required: [] },
    },
    {
        name: "bridge_assign",
        description: "Assign a task to a bridge agent by writing to their inbox.",
        inputSchema: {
            type: "object",
            properties: {
                agent: { type: "string", description: `Agent name`, enum: VALID_AGENTS },
                task_id: { type: "string", description: "Unique task ID, e.g. BRIDGE-C001" },
                priority: { type: "string", enum: VALID_PRIORITIES, default: "MEDIUM" },
                task_content: { type: "string", description: "Full markdown task content." },
            },
            required: ["agent", "task_id", "task_content"],
        },
    },
    {
        name: "bridge_collect",
        description: "Collect outbox results from one or all agents. DONE results auto-feed the Archivist.",
        inputSchema: {
            type: "object",
            properties: { agent: { type: "string", enum: VALID_AGENTS } },
            required: [],
        },
    },
    {
        name: "bridge_sync",
        description: "Sync shared context: recompute hash, write delta, mark agents stale.",
        inputSchema: {
            type: "object",
            properties: { summary: { type: "string", description: "What changed in this sync." } },
            required: ["summary"],
        },
    },
    {
        name: "agent_inbox_read",
        description: "Read an agent's inbox.md contents.",
        inputSchema: {
            type: "object",
            properties: { agent: { type: "string", enum: VALID_AGENTS } },
            required: ["agent"],
        },
    },
    {
        name: "agent_inbox_write",
        description: "Append a message to an agent's inbox.md.",
        inputSchema: {
            type: "object",
            properties: {
                agent: { type: "string", enum: VALID_AGENTS },
                message: { type: "string", description: "Markdown message to append." },
            },
            required: ["agent", "message"],
        },
    },
];

// ── Server ────────────────────────────────────────────────────────────────────
const server = new Server(
    { name: "aria-bridge", version: "1.1.0" },
    { capabilities: { tools: {} } },
);

server.setRequestHandler(ListToolsRequestSchema, async () => ({ tools: TOOLS }));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
    const { name, arguments: args = {} } = request.params;
    try {
        switch (name) {
            case "bridge_status": return await handleBridgeStatus();
            case "bridge_assign": return await handleBridgeAssign(args);
            case "bridge_collect": return await handleBridgeCollect(args);
            case "bridge_sync": return await handleBridgeSync(args);
            case "agent_inbox_read": return await handleAgentInboxRead(args);
            case "agent_inbox_write": return await handleAgentInboxWrite(args);
            default: throw new Error(`Unknown tool: ${name}`);
        }
    } catch (err) {
        return { content: [{ type: "text", text: `ERROR: ${err.message}` }], isError: true };
    }
});

async function main() {
    const transport = new StdioServerTransport();
    await server.connect(transport);
    process.stderr.write("aria-bridge MCP server v1.1.0 started (stdio)\n");
}

main().catch((err) => {
    process.stderr.write(`Fatal: ${err.message}\n`);
    process.exit(1);
});
