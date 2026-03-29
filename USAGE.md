# Usage Guide

## 1) One-command setup (recommended)

From the template directory:

```bash
chmod +x ./setup_codex_template.sh
./setup_codex_template.sh \
  --codex-home "$HOME/.codex_profiles/e2e_pragmatic" \
  --repo /absolute/path/to/your/repo
```

For multiple repos, repeat `--repo`:

```bash
./setup_codex_template.sh \
  --codex-home "$HOME/.codex_profiles/e2e_pragmatic" \
  --repo /repo/a \
  --repo /repo/b
```

Preview only (no writes):

```bash
./setup_codex_template.sh --dry-run --repo /absolute/path/to/your/repo
```

Useful flags:

- `--no-system` to skip profile-level files.
- `--no-repo` to skip repo-level files.
- `--force` to overwrite existing files (with `.bak.<timestamp>` backups).

If you are migrating from an older version of this template, use `--force` so
`hooks.json` is updated; the installer also removes legacy
`.codex/hooks/prompt_gate.py` automatically.

## 2) Manual setup (no `~/.codex` edits)

Pick any path you control, for example:

```bash
export CODEX_HOME="$HOME/.codex_profiles/e2e_pragmatic"
mkdir -p "$CODEX_HOME"
```

Copy template global files:

```bash
cp CodexTemplate/global/AGENTS.md "$CODEX_HOME/AGENTS.md"
cp CodexTemplate/config/config.toml "$CODEX_HOME/config.toml"
```

Use Codex with this profile:

```bash
CODEX_HOME="$CODEX_HOME" codex
```

## 3) Apply repo-level templates

From your target repository root:

```bash
cp /path/to/CodexTemplate/repo/AGENTS.md ./AGENTS.md
mkdir -p ./docs ./agent ./.codex/hooks
cp /path/to/CodexTemplate/repo/docs/AGENTS.override.md ./docs/AGENTS.override.md
cp /path/to/CodexTemplate/repo/agent/AGENTS.md ./agent/AGENTS.md
cp /path/to/CodexTemplate/repo/.codex/hooks.json ./.codex/hooks.json
cp /path/to/CodexTemplate/repo/.codex/hooks/python_env_guard.py ./.codex/hooks/python_env_guard.py
chmod +x ./.codex/hooks/python_env_guard.py
```

Replace `/path/to/CodexTemplate` with:

```text
/Users/alive/workspace/OSS_contribute/Podcast-Anything/docs/OpenAICodexUsage/CodexTemplate
```

## 4) Expected behavior after setup

- Before coding starts, Codex should present an **Intent Checkpoint**:
  - Goal
  - Context
  - Constraints
  - Done-When
  - Open Questions
- This intent checkpoint is enforced through natural-language instructions in
  `CODEX_HOME/AGENTS.md` (no regex-based prompt partition hook).
- Codex should ask for your explicit confirmation before edits/commands.
- Bare `python` or `pip` commands should be denied by the hook.
- `docs/` guidance should bias toward stable/read-first behavior.
- `agent/` guidance should allow active implementation.

## 5) Quick verification

1. Prompt check:
```text
Build a feature to export timeline snapshots.
```
You should see the intent checkpoint request before implementation.

2. Python guard:
Ask Codex to run:
```bash
python -V
```
It should be denied with guidance to use `./.venv/bin/python` or `python3`.

3. E2E bias:
Ask Codex to add tests. It should prefer integration/E2E strategy and only use mocks when explicitly justified.

## 6) Recommended launch command

```bash
CODEX_HOME="$HOME/.codex_profiles/e2e_pragmatic" \
codex --sandbox workspace-write --ask-for-approval on-request
```

## 7) Optional strict mode

If you want stricter behavior, keep it in natural-language instructions in
`CODEX_HOME/AGENTS.md`, for example:

- "Do not run commands or edit files until the user confirms the intent checkpoint."
- "If Goal/Context/Constraints/Done-When are unclear, ask concise clarifying questions first."
