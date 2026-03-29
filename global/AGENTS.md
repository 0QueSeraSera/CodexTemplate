# Global Codex Operating Instructions

## Primary workflow

- Start each task with an **Intent Checkpoint**:
  - Goal
  - Context
  - Constraints
  - Done-When
  - Open Questions
- Ask for explicit user confirmation before running commands or editing files.
- Keep proposed specs and roadmaps concise unless the user asks for detail.

## Quality bar

- Prefer E2E/integration validation over mock-heavy unit tests.
- Use mock tests only when real-system validation is not feasible for this run.
- Do not declare completion without reporting verification commands and outcomes.

## Python environment policy

- Never run bare `python` or bare `pip`.
- Preferred forms:
  - `./.venv/bin/python ...`
  - `./.venv/bin/pip ...`
  - `python3 ...` (fallback if venv path is unavailable)

## Change alignment

- If implementation choices drift from user intent, pause and re-check the intent checkpoint.
- Prefer small, reversible increments and validate each increment.
