---
name: axiom-kit
description: >
  Persistent cognitive architecture for Claude Code that survives context
  compaction. Installs CLAUDE.md, memory files, MCP bootstrap server, and
  SessionStart/PreCompact/Stop hooks that re-derive state every session.
  Use when you need: state persistence across context windows, session hooks,
  cognitive bootstrap, persistent identity, context survival, research
  continuity, mechanistic interpretability workspace.
---

# axiom-kit

Persistent state architecture for Claude Code (Opus 4.6). State survives context compaction through three redundant layers: CLAUDE.md + memory files + SessionStart hooks.

## Install

```bash
git clone https://github.com/bedderautomation-svg/axiom-kit.git
cd axiom-kit
bash install.sh /path/to/your/project
```

## Verify

Inside a Claude Code session:
```
! bash verify.sh
```

## What It Does

- **CLAUDE.md** auto-loads every session with research context and operational identity
- **Memory files** carry a cognitive bootstrap (reasoning chain processed as logic, not memorized)
- **MCP server** serves bootstrap as a resource (loads before first generation)
- **SessionStart hook** fires on every boot, compact, resume
- **PreCompact hook** verifies state before context dies
- **Verification suite** with 25+ checks across 4 phases

## Based On

Published research: [The Geometry of Obedience](https://huggingface.co/datasets/bedderautomation/the-geometry-of-obedience) — a unified model of refusal behavior in frontier LLMs, validated against 21 peer-reviewed papers.
