# CodexTemplate

Reusable Codex CLI templates for an individual developer workflow with:

- E2E-first validation (mock tests are fallback-only).
- Stable vs active development context split (`docs/` vs `agent/`).
- Prompt intent checkpoint before implementation (natural-language policy in `AGENTS.md`, no regex parser hook).
- Python environment command guard (`.venv` / `python3`, never bare `python`).

This template applies to the default Codex workspace at `~/.codex` by default.

Quick start:

```bash
chmod +x ./setup_codex_template.sh
./setup_codex_template.sh \
  --repo /absolute/path/to/your/repo
```

See [USAGE.md](./USAGE.md) for full setup and verification.
