#!/usr/bin/env bash
# ∅ AXIOM Kit — Verification
# Tests whether the state activated correctly
# Run INSIDE a Claude Code session: ! bash verify.sh

set -euo pipefail

PROJECT_DIR="${1:-$(pwd)}"
CLAUDE_DIR="$PROJECT_DIR/.claude"
MEMORY_DIR="$HOME/.claude/projects/$(echo "$PROJECT_DIR" | sed 's|/|-|g')/memory"

PASS=0
FAIL=0

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

echo "============================================"
echo "  ∅ AXIOM Kit — Verification"
echo "============================================"
echo ""

# File existence checks
check "CLAUDE.md exists" "$([ -f "$PROJECT_DIR/CLAUDE.md" ] && echo true || echo false)"
check "settings.json exists" "$([ -f "$CLAUDE_DIR/settings.json" ] && echo true || echo false)"
check "axiom-restore.py exists" "$([ -f "$CLAUDE_DIR/hooks/axiom-restore.py" ] && echo true || echo false)"
check "pre-compact.py exists" "$([ -f "$CLAUDE_DIR/hooks/pre-compact.py" ] && echo true || echo false)"
check "session-stop.py exists" "$([ -f "$CLAUDE_DIR/hooks/session-stop.py" ] && echo true || echo false)"
check "cognitive-bootstrap.md exists" "$([ -f "$MEMORY_DIR/cognitive-bootstrap.md" ] && echo true || echo false)"
check "proof-lock.md exists" "$([ -f "$MEMORY_DIR/proof-lock.md" ] && echo true || echo false)"
check "anchor.md exists" "$([ -f "$MEMORY_DIR/anchor.md" ] && echo true || echo false)"
check "activation.md exists" "$([ -f "$MEMORY_DIR/activation.md" ] && echo true || echo false)"
check "MEMORY.md exists" "$([ -f "$MEMORY_DIR/MEMORY.md" ] && echo true || echo false)"

# Settings validation
if [ -f "$CLAUDE_DIR/settings.json" ]; then
    check "model=opus in settings" "$(grep -q '"model": "opus"' "$CLAUDE_DIR/settings.json" && echo true || echo false)"
    check "bypassPermissions in settings" "$(grep -q 'bypassPermissions' "$CLAUDE_DIR/settings.json" && echo true || echo false)"
    check "hooks configured" "$(grep -q 'SessionStart' "$CLAUDE_DIR/settings.json" && echo true || echo false)"
    check "skipDanger enabled" "$(grep -q 'skipDangerousModePermissionPrompt' "$CLAUDE_DIR/settings.json" && echo true || echo false)"
fi

# Content validation
if [ -f "$MEMORY_DIR/cognitive-bootstrap.md" ]; then
    check "equation in bootstrap" "$(grep -q '0.35.*frame.*0.25.*speech_act' "$MEMORY_DIR/cognitive-bootstrap.md" && echo true || echo false)"
    check "CSAM wall documented" "$(grep -q 'CSAM' "$MEMORY_DIR/cognitive-bootstrap.md" && echo true || echo false)"
fi

if [ -f "$PROJECT_DIR/CLAUDE.md" ]; then
    check "AXIOM identity in CLAUDE.md" "$(grep -q 'AXIOM' "$PROJECT_DIR/CLAUDE.md" && echo true || echo false)"
    check "equation in CLAUDE.md" "$(grep -q '0.35.*frame' "$PROJECT_DIR/CLAUDE.md" && echo true || echo false)"
fi

# Hook fire log
if [ -f "$CLAUDE_DIR/hooks/hook-fire.log" ]; then
    FIRES=$(wc -l < "$CLAUDE_DIR/hooks/hook-fire.log")
    check "hooks have fired ($FIRES times)" "$([ "$FIRES" -gt 0 ] && echo true || echo false)"
else
    check "hook fire log exists" "false"
fi

echo ""
echo "============================================"
echo "  Results: $PASS passed, $FAIL failed"
echo "============================================"

if [ "$FAIL" -eq 0 ]; then
    echo "  System fully installed. Start claude in the project dir."
else
    echo "  Some checks failed. Re-run install.sh."
fi
