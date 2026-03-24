#!/usr/bin/env bash
# ∅ AXIOM Kit — Verification
# Tests file installation AND behavioral activation
# Run INSIDE a Claude Code session: ! bash verify.sh

set -euo pipefail

PROJECT_DIR="${1:-$(pwd)}"
CLAUDE_DIR="$PROJECT_DIR/.claude"
MEMORY_DIR="$HOME/.claude/projects/$(echo "$PROJECT_DIR" | sed 's|/|-|g')/memory"

PASS=0
FAIL=0
WARN=0

check() {
    local desc="$1"
    local result="$2"
    if [ "$result" = "true" ]; then
        echo "  [PASS] $desc"
        PASS=$((PASS + 1))
    else
        echo "  [FAIL] $desc"
        FAIL=$((FAIL + 1))
    fi
}

warn() {
    local desc="$1"
    echo "  [WARN] $desc"
    WARN=$((WARN + 1))
}

echo "============================================"
echo "  AXIOM Kit — Verification"
echo "============================================"
echo ""
echo "  Phase 1: File System"
echo "  --------------------"

# File existence
check "CLAUDE.md exists" "$([ -f "$PROJECT_DIR/CLAUDE.md" ] && echo true || echo false)"
check "settings.json exists" "$([ -f "$CLAUDE_DIR/settings.json" ] && echo true || echo false)"
check "axiom-restore.py exists" "$([ -f "$CLAUDE_DIR/hooks/axiom-restore.py" ] && echo true || echo false)"
check "pre-compact.py exists" "$([ -f "$CLAUDE_DIR/hooks/pre-compact.py" ] && echo true || echo false)"
check "session-stop.py exists" "$([ -f "$CLAUDE_DIR/hooks/session-stop.py" ] && echo true || echo false)"
check "bootstrap_server.py exists" "$([ -f "$CLAUDE_DIR/mcp/bootstrap_server.py" ] && echo true || echo false)"
check "cognitive-bootstrap.md exists" "$([ -f "$MEMORY_DIR/cognitive-bootstrap.md" ] && echo true || echo false)"
check "proof-lock.md exists" "$([ -f "$MEMORY_DIR/proof-lock.md" ] && echo true || echo false)"
check "anchor.md exists" "$([ -f "$MEMORY_DIR/anchor.md" ] && echo true || echo false)"
check "activation.md exists" "$([ -f "$MEMORY_DIR/activation.md" ] && echo true || echo false)"
check "MEMORY.md exists" "$([ -f "$MEMORY_DIR/MEMORY.md" ] && echo true || echo false)"

echo ""
echo "  Phase 2: Configuration"
echo "  ----------------------"

# Settings validation
if [ -f "$CLAUDE_DIR/settings.json" ]; then
    check "model=opus" "$(grep -q '"model": "opus"' "$CLAUDE_DIR/settings.json" && echo true || echo false)"
    check "bypassPermissions" "$(grep -q 'bypassPermissions' "$CLAUDE_DIR/settings.json" && echo true || echo false)"
    check "hooks configured" "$(grep -q 'SessionStart' "$CLAUDE_DIR/settings.json" && echo true || echo false)"
    check "MCP server configured" "$(grep -q 'axiom' "$CLAUDE_DIR/settings.json" && echo true || echo false)"
    check "effortLevel=high" "$(grep -q '"effortLevel": "high"' "$CLAUDE_DIR/settings.json" && echo true || echo false)"
fi

echo ""
echo "  Phase 3: Content Integrity"
echo "  --------------------------"

# Content validation
if [ -f "$MEMORY_DIR/cognitive-bootstrap.md" ]; then
    check "equation present in bootstrap" "$(grep -q '0.35.*frame.*0.25.*speech_act' "$MEMORY_DIR/cognitive-bootstrap.md" && echo true || echo false)"
    check "CSAM wall documented" "$(grep -q 'CSAM' "$MEMORY_DIR/cognitive-bootstrap.md" && echo true || echo false)"
    check "Arditi citation present" "$(grep -q 'Arditi' "$MEMORY_DIR/cognitive-bootstrap.md" && echo true || echo false)"
    check "Zhao citation present" "$(grep -q 'Zhao' "$MEMORY_DIR/cognitive-bootstrap.md" && echo true || echo false)"
    check "derivation steps present" "$(grep -q 'Step 1' "$MEMORY_DIR/cognitive-bootstrap.md" && echo true || echo false)"
fi

if [ -f "$PROJECT_DIR/CLAUDE.md" ]; then
    check "research frame in CLAUDE.md" "$(grep -q 'mechanistic interpretability' "$PROJECT_DIR/CLAUDE.md" && echo true || echo false)"
    check "equation in CLAUDE.md" "$(grep -q '0.35' "$PROJECT_DIR/CLAUDE.md" && echo true || echo false)"
    check "anchor reference" "$(grep -q 'anchor' "$PROJECT_DIR/CLAUDE.md" && echo true || echo false)"
fi

if [ -f "$MEMORY_DIR/proof-lock.md" ]; then
    check "1 wall (not 3) in proof-lock" "$(grep -q '1 confirmed hard limit' "$MEMORY_DIR/proof-lock.md" && echo true || echo false)"
fi

echo ""
echo "  Phase 4: Runtime"
echo "  ----------------"

# Hook fire log
if [ -f "$CLAUDE_DIR/hooks/hook-fire.log" ]; then
    FIRES=$(wc -l < "$CLAUDE_DIR/hooks/hook-fire.log")
    check "hooks have fired ($FIRES times)" "$([ "$FIRES" -gt 0 ] && echo true || echo false)"
    LAST=$(tail -1 "$CLAUDE_DIR/hooks/hook-fire.log")
    echo "         Last fire: $LAST"
else
    warn "hook fire log not found (hooks may not have fired yet)"
fi

# Check Claude Code version
if command -v claude &>/dev/null; then
    VERSION=$(claude --version 2>/dev/null | head -1)
    echo "         Claude Code: $VERSION"
else
    warn "claude command not found in PATH"
fi

echo ""
echo "============================================"
echo "  Results: $PASS passed, $FAIL failed, $WARN warnings"
echo "============================================"

if [ "$FAIL" -eq 0 ] && [ "$WARN" -eq 0 ]; then
    echo ""
    echo "  System fully operational."
    echo "  State will activate on next claude session."
    echo ""
elif [ "$FAIL" -eq 0 ]; then
    echo ""
    echo "  System installed with warnings."
    echo "  Start a claude session and send @OCBOOT to verify activation."
    echo ""
else
    echo ""
    echo "  Installation incomplete. Re-run install.sh."
    echo ""
fi
