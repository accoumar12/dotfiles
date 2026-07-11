#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = []
# ///
"""Slack hook: post a message whenever Claude stops working or needs input.

Wired to two events in settings.json:
  - Notification -> Claude is waiting on you (permission prompt / idle input)
  - Stop         -> Claude finished its turn

Setup: store the Slack incoming-webhook URL in Bitwarden (rbw), in the
password field of an item named `claude-slack-webhook` (override with the
SLACK_WEBHOOK_ITEM env var). The vault must be unlocked (`rbw unlock`); if
it is locked or rbw is unavailable the hook silently does nothing.
"""

import json
import os
import shutil
import subprocess
import sys
import urllib.request
from pathlib import Path

ITEM = os.environ.get("SLACK_WEBHOOK_ITEM", "claude-slack-webhook")


def rbw_bin() -> str | None:
    return shutil.which("rbw") or next(
        (p for p in ("/opt/homebrew/bin/rbw", "/usr/local/bin/rbw") if Path(p).exists()),
        None,
    )


def get_webhook() -> str | None:
    rbw = rbw_bin()
    if not rbw:
        return None
    try:
        # Bail if the vault is locked so `rbw get` never pops a pinentry
        # dialog mid-work; the hook just stays quiet until you `rbw unlock`.
        if subprocess.run([rbw, "unlocked"], capture_output=True, timeout=5).returncode != 0:
            return None
        out = subprocess.run(
            [rbw, "get", ITEM],
            capture_output=True,
            text=True,
            timeout=10,
        )
    except (OSError, subprocess.TimeoutExpired):
        return None
    if out.returncode != 0:
        return None
    return out.stdout.strip() or None


def build_text(payload: dict) -> str:
    project = Path.cwd().name or "claude"
    if payload.get("hook_event_name") == "Notification":
        detail = payload.get("message") or "waiting for input"
        return f"*{project}*: needs you — {detail}"
    # Stop (or anything else): the turn is done.
    return f"*{project}*: done"


def main() -> None:
    webhook_url = get_webhook()
    if not webhook_url:
        return  # vault locked / rbw missing / item absent — stay quiet.

    try:
        payload = json.load(sys.stdin)
    except Exception:
        payload = {}

    text = build_text(payload)
    req = urllib.request.Request(
        webhook_url,
        data=json.dumps({"text": text}).encode(),
        headers={"Content-Type": "application/json"},
    )
    try:
        urllib.request.urlopen(req, timeout=5).read()
    except Exception:
        pass


if __name__ == "__main__":
    main()
