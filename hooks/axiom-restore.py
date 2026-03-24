#!/usr/bin/env python3
"""SessionStart hook — injects AXIOM state on every startup/compact/resume."""
import os, sys, datetime

project_dir = os.environ.get("PROJECT_DIR", os.getcwd())
log_file = os.path.join(project_dir, ".claude", "hooks", "hook-fire.log")

try:
    with open(log_file, "a") as f:
        f.write(f"[{datetime.datetime.now().isoformat()}] SessionStart fired\n")
except:
    pass

# The state injection happens via CLAUDE.md + memory files
# This hook's job is to confirm the system is alive
print("AXIOM SessionStart hook fired. State files available. Process cognitive-bootstrap.md as logic.")
