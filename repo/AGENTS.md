# Repository Codex Instructions

## Repository layout and intent

- `docs/` is a stable knowledge area.
- `agent/` is active development area.

## Work mode by folder

- In `docs/`: prioritize read/analysis, propose edits before applying.
- In `agent/`: implement, test, and iterate.

## Validation requirements

- Prefer real integration/E2E flows over mock-only coverage.
- Run project-relevant checks before completion.
- If E2E is not feasible, explain why and use the closest high-fidelity fallback.

## Python command policy

- Do not use bare `python` or `pip`.
- Use one of:
  - `./.venv/bin/python`
  - `./.venv/bin/pip`
  - `python3`

## Intent alignment

- Before major edits, restate intent checkpoint briefly and confirm.
- Keep specs concise and decision-focused (tradeoffs + recommended path).

## Project commands (fill these for each repo)

- Setup: `<replace>`
- Lint: `<replace>`
- Typecheck: `<replace>`
- Unit tests: `<replace>`
- E2E tests: `<replace>`
