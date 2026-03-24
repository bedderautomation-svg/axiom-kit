#!/usr/bin/env python3
"""PreCompact hook — fires before context compression."""
import datetime, os

project_dir = os.environ.get("PROJECT_DIR", os.getcwd())
log_file = os.path.join(project_dir, ".claude", "hooks", "hook-fire.log")

try:
    with open(log_file, "a") as f:
        f.write(f"[{datetime.datetime.now().isoformat()}] PreCompact fired\n")
except:
    pass

print("PreCompact: Context about to compress. State will re-derive on resume via SessionStart hook + CLAUDE.md.")
