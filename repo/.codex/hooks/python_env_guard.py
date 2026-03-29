#!/usr/bin/env python3
"""PreToolUse hook: deny bare python/pip shell commands.

Allows:
- ./.venv/bin/python ...
- ./.venv/bin/pip ...
- python3 ...
"""

from __future__ import annotations

import json
import re
import sys


BARE_PYTHON = re.compile(r"(^|[\s;&|()])python(\s|$)")
BARE_PIP = re.compile(r"(^|[\s;&|()])pip(\s|$)")


def allowed(command: str) -> bool:
    lowered = command.strip()
    if not lowered:
        return True
    if "./.venv/bin/python" in lowered or ".venv/bin/python" in lowered:
        return True
    if "./.venv/bin/pip" in lowered or ".venv/bin/pip" in lowered:
        return True
    if BARE_PYTHON.search(lowered):
        return False
    if BARE_PIP.search(lowered):
        return False
    return True


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        payload = {}

    command = (
        payload.get("tool_input", {}).get("command")
        or payload.get("command")
        or payload.get("input", {}).get("command")
        or ""
    )

    if allowed(command):
        print(
            json.dumps(
                {
                    "hookSpecificOutput": {
                        "hookEventName": "PreToolUse",
                        "permissionDecision": "allow",
                    }
                }
            )
        )
        return 0

    reason = (
        "Denied by Python environment guard: use './.venv/bin/python' or 'python3' "
        "instead of bare 'python'; use './.venv/bin/pip' instead of bare 'pip'."
    )
    print(
        json.dumps(
            {
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "deny",
                    "permissionDecisionReason": reason,
                }
            }
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
