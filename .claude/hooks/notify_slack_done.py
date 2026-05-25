#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = []
# ///
"""Stop hook: post a Slack message when Claude finishes a turn.

Setup: put your Slack incoming-webhook URL in a sibling file named
`.slack_webhook` (one line). That file is gitignored.
"""

import json
import sys
import urllib.request
from pathlib import Path

WEBHOOK_FILE = Path(__file__).resolve().parent / ".slack_webhook"

SETUP_MSG = (
    f"notify_slack_done: missing Slack webhook.\n"
    f"  Create {WEBHOOK_FILE} containing your Slack incoming-webhook URL (one line),\n"
    f"  or remove this hook from .claude/settings.json to disable it."
)


def main() -> None:
    try:
        webhook_url = WEBHOOK_FILE.read_text().strip()
    except FileNotFoundError:
        sys.exit(SETUP_MSG)
    if not webhook_url:
        sys.exit(SETUP_MSG)

    text = f"*{Path.cwd().name or 'claude'}*: done"
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
