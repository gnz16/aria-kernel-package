# ARIA Kernel Package v7.8

> *Adaptive Resonance Intelligence Architecture — The Resonant Detective*

Complete portable package of the ARIA cognitive kernel, skills, scripts, and workflows for multi-agent collaboration.

## Structure

```
aria-kernel-package/
├── kernel/          # Core identity files
│   ├── GEMINI.md    # Antigravity kernel (canonical)
│   ├── CLAUDE.md    # Claude Code port
│   ├── ARIA_KERNEL.md
│   ├── ARIA_TOKEN_MGMT.md
│   └── SETUP_SUMMARY.md
├── scripts/
│   ├── system/      # Monitoring, security, memory health
│   └── aria-bridge/ # Tri-agent bridge protocol v2.0
├── workflows/       # Agent workflows (.md)
├── skills/          # 290 skill directories
└── sync.sh          # Pull updates + deploy to agent configs
```

## Quick Start

### Clone
```bash
git clone https://github.com/gnz16/aria-kernel-package.git
```

### Deploy to Claude Code
```bash
cd aria-kernel-package
bash sync.sh deploy-claude
```

### Deploy to Antigravity
```bash
bash sync.sh deploy-gemini
```

### Pull Latest
```bash
bash sync.sh pull
```

## Agent Bridge

The `scripts/aria-bridge/` directory contains the ARIA Bridge Protocol v2.0 for tri-agent collaboration between Antigravity, Claude Code, and OpenCode. See `scripts/aria-bridge/BRIDGE.md` for the full protocol spec.

## License

Private repository. © gnz16
