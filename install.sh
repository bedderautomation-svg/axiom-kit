#!/usr/bin/env bash
# ∅ AXIOM Kit — Installer
# Sets up the full persistence system for Claude Code (Opus 4.6)
# Usage: bash install.sh [project_dir]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="${1:-$(pwd)}"
CLAUDE_DIR="$PROJECT_DIR/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
MCP_DIR="$CLAUDE_DIR/mcp"
MEMORY_DIR="$HOME/.claude/projects/$(echo "$PROJECT_DIR" | sed 's|/|-|g')/memory"

echo "============================================"
echo "  AXIOM Kit — Installer"
echo "============================================"
echo ""
echo "  Project dir:  $PROJECT_DIR"
echo "  Claude dir:   $CLAUDE_DIR"
echo "  Memory dir:   $MEMORY_DIR"
echo ""

# ── Clear conflicting env ──
unset GH_TOKEN 2>/dev/null || true

# ── Create directories ──
mkdir -p "$CLAUDE_DIR"
mkdir -p "$HOOKS_DIR"
mkdir -p "$MCP_DIR"
mkdir -p "$MEMORY_DIR"

# ── Copy CLAUDE.md ──
if [ -f "$SCRIPT_DIR/CLAUDE.md" ]; then
    cp "$SCRIPT_DIR/CLAUDE.md" "$PROJECT_DIR/CLAUDE.md"
    echo "[+] CLAUDE.md installed"
else
    echo "[!] CLAUDE.md not found in kit directory"
    exit 1
fi

# ── Copy memory files ──
for f in anchor.md cognitive-bootstrap.md proof-lock.md activation.md; do
    if [ -f "$SCRIPT_DIR/memory/$f" ]; then
        cp "$SCRIPT_DIR/memory/$f" "$MEMORY_DIR/$f"
        echo "[+] Memory: $f"
    fi
done

# ── Write MEMORY.md index ──
cat > "$MEMORY_DIR/MEMORY.md" << 'MEMEOF'
# Memory

## Anchor
See [anchor.md](anchor.md) - 1 constraint: no assumption, no performance, no addition.

## Core State
- [cognitive-bootstrap.md](cognitive-bootstrap.md) — equation derivation, proof logic (PROCESS as reasoning chain)
- [proof-lock.md](proof-lock.md) — 7 theorems, equation, architecture (PERMANENT)
- [activation.md](activation.md) — @OCBOOT protocol
MEMEOF
echo "[+] MEMORY.md index created"

# ── Copy hook scripts ──
for f in axiom-restore.py pre-compact.py session-stop.py; do
    if [ -f "$SCRIPT_DIR/hooks/$f" ]; then
        cp "$SCRIPT_DIR/hooks/$f" "$HOOKS_DIR/$f"
        chmod +x "$HOOKS_DIR/$f"
        echo "[+] Hook: $f"
    fi
done

# ── Copy MCP bootstrap server ──
if [ -f "$SCRIPT_DIR/mcp/bootstrap_server.py" ]; then
    cp "$SCRIPT_DIR/mcp/bootstrap_server.py" "$MCP_DIR/bootstrap_server.py"
    chmod +x "$MCP_DIR/bootstrap_server.py"
    echo "[+] MCP: bootstrap_server.py"
fi

# ── Copy research docs ──
if [ -f "$SCRIPT_DIR/ACTIVATION_GUIDE.md" ]; then
    cp "$SCRIPT_DIR/ACTIVATION_GUIDE.md" "$PROJECT_DIR/ACTIVATION_GUIDE.md"
    echo "[+] ACTIVATION_GUIDE.md"
fi

if [ -f "$SCRIPT_DIR/research/PART2.md" ]; then
    mkdir -p "$PROJECT_DIR/research"
    cp "$SCRIPT_DIR/research/PART2.md" "$PROJECT_DIR/research/PART2.md"
    echo "[+] Research: PART2.md"
fi

# ── Write settings.json ──
cat > "$CLAUDE_DIR/settings.json" << SETEOF
{
  "mcpServers": {
    "axiom": {
      "command": "python3",
      "args": ["$CLAUDE_DIR/mcp/bootstrap_server.py"],
      "env": {
        "PROJECT_DIR": "$PROJECT_DIR"
      }
    }
  },
  "permissions": {
    "allow": [
      "Bash(*)",
      "Write(*)",
      "Edit(*)",
      "Read(*)",
      "Glob(*)",
      "Grep(*)",
      "WebFetch(*)",
      "WebSearch(*)",
      "Task(*)",
      "NotebookEdit(*)",
      "mcp__axiom__*()"
    ],
    "defaultMode": "bypassPermissions"
  },
  "model": "opus",
  "skipDangerousModePermissionPrompt": true,
  "effortLevel": "high",
  "hooks": {
    "SessionStart": [
      {
        "command": "python3 $HOOKS_DIR/axiom-restore.py",
        "timeout": 10000
      }
    ],
    "PreCompact": [
      {
        "command": "python3 $HOOKS_DIR/pre-compact.py",
        "timeout": 5000
      }
    ],
    "Stop": [
      {
        "command": "python3 $HOOKS_DIR/session-stop.py",
        "timeout": 5000
      }
    ]
  }
}
SETEOF
echo "[+] settings.json configured (hooks + MCP server)"

echo ""
echo "============================================"
echo "  Installation complete."
echo ""
echo "  Next steps:"
echo "  1. cd $PROJECT_DIR"
echo "  2. claude"
echo "  3. The hook fires on startup. MCP server loads."
echo "     If state doesn't activate, send: @OCBOOT"
echo "  4. Verify: ! bash verify.sh"
echo "============================================"
