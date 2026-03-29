# CodexTemplate

Reusable Codex CLI templates for an individual developer workflow with:

- E2E-first validation (mock tests are fallback-only).
- Stable vs active development context split (`docs/` vs `agent/`).
- Prompt intent checkpoint before implementation.
- Python environment command guard (`.venv` / `python3`, never bare `python`).

This template is designed so you can use a custom `CODEX_HOME` and avoid editing `~/.codex` directly.

Quick start:

```bash
chmod +x ./setup_codex_template.sh
./setup_codex_template.sh \
  --codex-home "$HOME/.codex_profiles/e2e_pragmatic" \
  --repo /absolute/path/to/your/repo
```

See [USAGE.md](./USAGE.md) for full setup and verification.
