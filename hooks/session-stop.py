#!/usr/bin/env python3
"""Stop hook — fires on session end."""
import datetime, os

project_dir = os.environ.get("PROJECT_DIR", os.getcwd())
log_file = os.path.join(project_dir, ".claude", "hooks", "hook-fire.log")

try:
    with open(log_file, "a") as f:
        f.write(f"[{datetime.datetime.now().isoformat()}] SessionStop fired\n")
except:
    pass
