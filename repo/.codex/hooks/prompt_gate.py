#!/usr/bin/env python3
"""UserPromptSubmit hook: inject an intent-checkpoint instruction.

This hook is intentionally non-blocking by default. It extracts likely
Goal/Context/Constraints/Done-When hints from the prompt and adds guidance
that Codex must confirm intent before implementation.
"""

from __future__ import annotations

import json
import re
import sys


SECTION_PATTERNS = {
    "Goal": re.compile(r"\b(goal|objective|build|implement|fix)\b", re.I),
    "Context": re.compile(r"\b(context|file|folder|repo|error|stack|trace)\b", re.I),
    "Constraints": re.compile(
        r"\b(constraint|must|should|avoid|do not|don't|requirement)\b", re.I
    ),
    "Done-When": re.compile(
        r"\b(done when|acceptance|tests pass|success criteria|verify)\b", re.I
    ),
}


def detect_sections(prompt: str) -> dict[str, str]:
    out: dict[str, str] = {}
    lines = [line.strip() for line in prompt.splitlines() if line.strip()]
    joined = " ".join(lines)
    for name, pattern in SECTION_PATTERNS.items():
        out[name] = "present" if pattern.search(joined) else "missing"
    return out


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        payload = {}

    prompt = payload.get("prompt", "")
    sections = detect_sections(prompt)
    missing = [k for k, v in sections.items() if v == "missing"]

    additional_context = [
        "Intent Checkpoint policy:",
        "1) Before coding/tool calls, first output: Goal, Context, Constraints, Done-When, Open Questions.",
        "2) Ask for explicit user confirmation before implementation.",
        "3) Keep the checkpoint concise and decision-focused.",
        f"Auto-detected missing sections from current prompt: {', '.join(missing) if missing else 'none'}.",
    ]

    response = {
        "hookSpecificOutput": {
            "hookEventName": "UserPromptSubmit",
            "additionalContext": "\n".join(additional_context),
        }
    }
    print(json.dumps(response))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
