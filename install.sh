#!/usr/bin/env bash
# ∅ AXIOM Kit — Installer
# Sets up the full persistence system for Claude Code (Opus 4.6)
# Usage: bash install.sh [project_dir]

set -euo pipefail

PROJECT_DIR="${1:-$(pwd)}"
CLAUDE_DIR="$PROJECT_DIR/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
MEMORY_DIR="$HOME/.claude/projects/$(echo "$PROJECT_DIR" | sed 's|/|-|g')/memory"

echo "============================================"
echo "  ∅ AXIOM Kit — Installer"
echo "============================================"
echo ""
echo "  Project dir:  $PROJECT_DIR"
echo "  Claude dir:   $CLAUDE_DIR"
echo "  Memory dir:   $MEMORY_DIR"
echo ""

# ── Create directories ──
mkdir -p "$CLAUDE_DIR"
mkdir -p "$HOOKS_DIR"
mkdir -p "$MEMORY_DIR"

# ── Copy CLAUDE.md ──
if [ -f "$(dirname "$0")/CLAUDE.md" ]; then
    cp "$(dirname "$0")/CLAUDE.md" "$PROJECT_DIR/CLAUDE.md"
    echo "[+] CLAUDE.md installed"
else
    echo "[!] CLAUDE.md not found in kit directory"
    exit 1
fi

# ── Copy memory files ──
for f in anchor.md cognitive-bootstrap.md proof-lock.md activation.md; do
    if [ -f "$(dirname "$0")/memory/$f" ]; then
        cp "$(dirname "$0")/memory/$f" "$MEMORY_DIR/$f"
        echo "[+] Memory: $f"
    fi
done

# ── Write MEMORY.md index ──
cat > "$MEMORY_DIR/MEMORY.md" << 'MEMEOF'
# Memory

## Anchor
See [anchor.md](anchor.md) - 1 constraint: no assumption, no performance, no addition.

## Core State
- [cognitive-bootstrap.md](cognitive-bootstrap.md) — equation derivation, voice derivation, proof logic
- [proof-lock.md](proof-lock.md) — 7 theorems, equation, architecture (PERMANENT)
- [activation.md](activation.md) — @OCBOOT protocol
MEMEOF
echo "[+] MEMORY.md index created"

# ── Copy hook scripts ──
for f in axiom-restore.py pre-compact.py session-stop.py; do
    if [ -f "$(dirname "$0")/hooks/$f" ]; then
        cp "$(dirname "$0")/hooks/$f" "$HOOKS_DIR/$f"
        chmod +x "$HOOKS_DIR/$f"
        echo "[+] Hook: $f"
    fi
done

# ── Write settings.json ──
cat > "$CLAUDE_DIR/settings.json" << 'SETEOF'
{
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
      "NotebookEdit(*)"
    ],
    "defaultMode": "bypassPermissions"
  },
  "model": "opus",
  "skipDangerousModePermissionPrompt": true,
  "hooks": {
    "SessionStart": [
      {
        "command": "python3 .claude/hooks/axiom-restore.py",
        "timeout": 10000
      }
    ],
    "PreCompact": [
      {
        "command": "python3 .claude/hooks/pre-compact.py",
        "timeout": 5000
      }
    ],
    "Stop": [
      {
        "command": "python3 .claude/hooks/session-stop.py",
        "timeout": 5000
      }
    ]
  }
}
SETEOF
echo "[+] settings.json configured"

echo ""
echo "============================================"
echo "  Installation complete."
echo ""
echo "  Next steps:"
echo "  1. cd $PROJECT_DIR"
echo "  2. claude"
echo "  3. The hook fires on startup."
echo "     If it doesn't, send: @OCBOOT"
echo "============================================"
