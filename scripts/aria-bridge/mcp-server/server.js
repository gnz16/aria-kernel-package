#!/usr/bin/env node
/**
 * aria-bridge-mcp — MCP server for the ARIA Constellation Bridge
 *
 * Exposes Bridge shell operations as structured MCP tools:
 *   bridge_status       — runs aria-status.sh
 *   bridge_assign       — wraps aria-assign.sh (writes a task to an agent inbox)
 *   bridge_collect      — runs aria-collect.sh
 *   bridge_sync         — runs aria-sync.sh with a summary string
 *   agent_inbox_read    — reads a named agent's inbox.md
 *   agent_inbox_write   — appends a message to a named agent's inbox.md
 *
 * Transport: stdio (Claude Code spawns this process and talks over stdin/stdout)
 *
 * Usage: node /root/.aria-bridge/mcp-server/server.js
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { readFile, appendFile, access } from "node:fs/promises";
import { writeFile } from "node:fs/promises";
import path from "node:path";

const execFileAsync = promisify(execFile);

// ── Constants ──────────────────────────────────────────────────────────────────
const BRIDGE_DIR = "/root/.aria-bridge";
const VALID_AGENTS = ["logician", "oracle", "auditor", "craftsman", "archivist"];
const VALID_PRIORITIES = ["HIGH", "MEDIUM", "LOW"];

// ── Helper: run a bridge shell script ──────────────────────────────────────────
async function runScript(scriptPath, args = [], timeoutMs = 15000) {
  try {
    const { stdout, stderr } = await execFileAsync("bash", [scriptPath, ...args], {
      timeout: timeoutMs,
      env: { ...process.env, PATH: process.env.PATH || "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" },
    });
    return {
      success: true,
      output: stdout,
      stderr: stderr || "",
    };
  } catch (err) {
    return {
      success: false,
      output: err.stdout || "",
      stderr: err.stderr || err.message,
      exitCode: err.code ?? -1,
    };
  }
}

// ── Helper: validate agent name ────────────────────────────────────────────────
function validateAgent(agent) {
  if (!VALID_AGENTS.includes(agent)) {
    throw new Error(
      `Invalid agent "${agent}". Valid agents: ${VALID_AGENTS.join(", ")}`
    );
  }
}

// ── Helper: build structured text result ──────────────────────────────────────
function textResult(content) {
  return { content: [{ type: "text", text: content }] };
}

// ── Tool handlers ──────────────────────────────────────────────────────────────

async function handleBridgeStatus() {
  const result = await runScript(`${BRIDGE_DIR}/aria-status.sh`);
  const body = result.success
    ? result.output
    : `ERROR (exit ${result.exitCode}):\n${result.stderr}\n${result.output}`;
  return textResult(body);
}

async function handleBridgeAssign(args) {
  const { agent, task_id, priority = "MEDIUM", task_content } = args;

  validateAgent(agent);

  if (!task_id || typeof task_id !== "string" || task_id.trim() === "") {
    throw new Error("task_id is required and must be a non-empty string.");
  }
  if (!VALID_PRIORITIES.includes(priority)) {
    throw new Error(
      `Invalid priority "${priority}". Valid priorities: ${VALID_PRIORITIES.join(", ")}`
    );
  }
  if (!task_content || typeof task_content !== "string" || task_content.trim() === "") {
    throw new Error("task_content is required and must be a non-empty string.");
  }

  // Write task content to a temp file so aria-assign.sh can read it
  const tmpTaskFile = `/tmp/aria-mcp-task-${Date.now()}.md`;
  await writeFile(tmpTaskFile, task_content, "utf8");

  const result = await runScript(`${BRIDGE_DIR}/aria-assign.sh`, [
    agent,
    task_id.trim(),
    priority,
    tmpTaskFile,
  ]);

  // Clean up temp file (best-effort)
  import("node:fs").then((fs) => fs.promises.unlink(tmpTaskFile).catch(() => {}));

  if (!result.success) {
    return textResult(
      `ASSIGN FAILED (exit ${result.exitCode}):\n${result.stderr}\n${result.output}`
    );
  }
  return textResult(result.output || `Task ${task_id} assigned to ${agent} (${priority}).`);
}

async function handleBridgeCollect(args) {
  const { agent } = args || {};
  const scriptArgs = agent ? [agent] : [];

  if (agent) validateAgent(agent);

  const result = await runScript(`${BRIDGE_DIR}/aria-collect.sh`, scriptArgs, 30000);
  const body = result.success
    ? result.output
    : `ERROR (exit ${result.exitCode}):\n${result.stderr}\n${result.output}`;
  return textResult(body);
}

async function handleBridgeSync(args) {
  const { summary } = args;
  if (!summary || typeof summary !== "string" || summary.trim() === "") {
    throw new Error("summary is required and must be a non-empty string.");
  }

  const result = await runScript(`${BRIDGE_DIR}/aria-sync.sh`, [summary.trim()]);
  if (!result.success) {
    return textResult(
      `SYNC FAILED (exit ${result.exitCode}):\n${result.stderr}\n${result.output}`
    );
  }
  return textResult(result.output || `Sync complete: ${summary}`);
}

async function handleAgentInboxRead(args) {
  const { agent } = args;
  validateAgent(agent);

  const inboxPath = `${BRIDGE_DIR}/agents/${agent}/inbox.md`;
  try {
    await access(inboxPath);
  } catch {
    return textResult(`No inbox found for agent "${agent}" at ${inboxPath}`);
  }

  const content = await readFile(inboxPath, "utf8");
  return textResult(content || `(${agent} inbox is empty)`);
}

async function handleAgentInboxWrite(args) {
  const { agent, message } = args;
  validateAgent(agent);

  if (!message || typeof message !== "string" || message.trim() === "") {
    throw new Error("message is required and must be a non-empty string.");
  }

  const inboxPath = `${BRIDGE_DIR}/agents/${agent}/inbox.md`;
  const timestamp = new Date().toISOString();
  const entry = `\n---\n<!-- MCP append @ ${timestamp} -->\n${message.trim()}\n`;

  await appendFile(inboxPath, entry, "utf8");
  return textResult(`Message appended to ${agent} inbox at ${timestamp}`);
}

// ── Tool definitions ───────────────────────────────────────────────────────────
const TOOLS = [
  {
    name: "bridge_status",
    description:
      "Run aria-status.sh and return the full ARIA Constellation agent status dashboard. Shows agent inbox states, shared context info, and active tmux session.",
    inputSchema: {
      type: "object",
      properties: {},
      required: [],
    },
  },
  {
    name: "bridge_assign",
    description:
      "Assign a task to a named Constellation agent by writing to their inbox via aria-assign.sh. Creates a properly formatted inbox entry with header, task content, and handoff instructions.",
    inputSchema: {
      type: "object",
      properties: {
        agent: {
          type: "string",
          description: `Target agent name. Must be one of: ${VALID_AGENTS.join(", ")}`,
          enum: VALID_AGENTS,
        },
        task_id: {
          type: "string",
          description: "Unique task identifier, e.g. BRIDGE-C001 or MCP-L002",
        },
        priority: {
          type: "string",
          description: "Task priority level",
          enum: VALID_PRIORITIES,
          default: "MEDIUM",
        },
        task_content: {
          type: "string",
          description:
            "Full markdown task content. Should include ## Task, ## Context, and ## Expected Output sections for best results.",
        },
      },
      required: ["agent", "task_id", "task_content"],
    },
  },
  {
    name: "bridge_collect",
    description:
      "Run aria-collect.sh and return all agent outbox results. Optionally collect from a single named agent only. DONE results are also fed to the Archivist inbox automatically by the script.",
    inputSchema: {
      type: "object",
      properties: {
        agent: {
          type: "string",
          description: `Optional: collect from a single agent. Must be one of: ${VALID_AGENTS.join(", ")}`,
          enum: VALID_AGENTS,
        },
      },
      required: [],
    },
  },
  {
    name: "bridge_sync",
    description:
      "Run aria-sync.sh to update shared context after agents complete tasks. Recomputes project-state hash, writes delta.md, and marks all agents stale.",
    inputSchema: {
      type: "object",
      properties: {
        summary: {
          type: "string",
          description: "Human-readable summary of what changed in this sync cycle.",
        },
      },
      required: ["summary"],
    },
  },
  {
    name: "agent_inbox_read",
    description:
      "Read the full contents of a named agent's inbox.md file. Returns the raw markdown including the task header block.",
    inputSchema: {
      type: "object",
      properties: {
        agent: {
          type: "string",
          description: `Agent name to read inbox for. Must be one of: ${VALID_AGENTS.join(", ")}`,
          enum: VALID_AGENTS,
        },
      },
      required: ["agent"],
    },
  },
  {
    name: "agent_inbox_write",
    description:
      "Append a message to a named agent's inbox.md. Useful for sending follow-up instructions or additional context to an agent that already has a task assigned.",
    inputSchema: {
      type: "object",
      properties: {
        agent: {
          type: "string",
          description: `Target agent name. Must be one of: ${VALID_AGENTS.join(", ")}`,
          enum: VALID_AGENTS,
        },
        message: {
          type: "string",
          description: "Markdown-formatted message to append to the inbox.",
        },
      },
      required: ["agent", "message"],
    },
  },
];

// ── Server setup ───────────────────────────────────────────────────────────────
const server = new Server(
  {
    name: "aria-bridge",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

server.setRequestHandler(ListToolsRequestSchema, async () => {
  return { tools: TOOLS };
});

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args = {} } = request.params;

  try {
    switch (name) {
      case "bridge_status":
        return await handleBridgeStatus();
      case "bridge_assign":
        return await handleBridgeAssign(args);
      case "bridge_collect":
        return await handleBridgeCollect(args);
      case "bridge_sync":
        return await handleBridgeSync(args);
      case "agent_inbox_read":
        return await handleAgentInboxRead(args);
      case "agent_inbox_write":
        return await handleAgentInboxWrite(args);
      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  } catch (err) {
    return {
      content: [{ type: "text", text: `ERROR: ${err.message}` }],
      isError: true,
    };
  }
});

// ── Start ──────────────────────────────────────────────────────────────────────
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  // MCP servers must not write to stdout (it's the protocol channel)
  // Status goes to stderr only
  process.stderr.write("aria-bridge MCP server started (stdio transport)\n");
}

main().catch((err) => {
  process.stderr.write(`Fatal: ${err.message}\n`);
  process.exit(1);
});
