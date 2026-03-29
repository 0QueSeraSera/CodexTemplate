#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_ROOT="${SCRIPT_DIR}"
DEFAULT_CODEX_HOME="${HOME}/.codex"

codex_home="${DEFAULT_CODEX_HOME}"
install_system=1
install_repo=1
force=0
dry_run=0
declare -a repos=()

usage() {
  cat <<'EOF'
Usage:
  setup_codex_template.sh [options]

Options:
  --codex-home PATH     Target CODEX_HOME profile path.
                        Default: $HOME/.codex
  --repo PATH           Target repository path. Repeatable.
  --no-system           Skip profile-level install (AGENTS.md + config.toml).
  --no-repo             Skip repo-level install.
  --force               Overwrite existing files (with timestamp backup).
  --dry-run             Print actions without writing files.
  -h, --help            Show this help.

Examples:
  # Install system profile + one repo
  ./setup_codex_template.sh \
    --codex-home "$HOME/.codex" \
    --repo /path/to/repo

  # Install only repo templates for two repos
  ./setup_codex_template.sh --no-system \
    --repo /repo/a \
    --repo /repo/b

  # Preview changes
  ./setup_codex_template.sh --dry-run --repo /path/to/repo
EOF
}

log() {
  printf '%s\n' "$*"
}

warn() {
  printf 'WARN: %s\n' "$*" >&2
}

run_cmd() {
  if [[ "${dry_run}" -eq 1 ]]; then
    printf '[dry-run] '
    printf '%q ' "$@"
    printf '\n'
  else
    "$@"
  fi
}

copy_with_policy() {
  local src="$1"
  local dst="$2"

  if [[ ! -f "${src}" ]]; then
    warn "Template file missing: ${src}"
    return 1
  fi

  run_cmd mkdir -p "$(dirname "${dst}")"

  if [[ -e "${dst}" ]]; then
    if [[ "${force}" -eq 1 ]]; then
      local backup
      backup="${dst}.bak.$(date +%Y%m%d%H%M%S)"
      log "Backing up existing file: ${dst} -> ${backup}"
      run_cmd mv "${dst}" "${backup}"
    else
      warn "Skipping existing file: ${dst} (use --force to overwrite)"
      return 0
    fi
  fi

  log "Installing: ${dst}"
  run_cmd cp "${src}" "${dst}"
}

normalize_path() {
  local p="$1"
  if [[ -d "${p}" ]]; then
    (cd "${p}" && pwd)
  else
    printf '%s\n' "${p}"
  fi
}

install_system_files() {
  log "== System profile install =="
  run_cmd mkdir -p "${codex_home}"
  copy_with_policy "${TEMPLATE_ROOT}/global/AGENTS.md" "${codex_home}/AGENTS.md"
  copy_with_policy "${TEMPLATE_ROOT}/config/config.toml" "${codex_home}/config.toml"
}

install_repo_files() {
  local repo="$1"
  local abs_repo
  abs_repo="$(normalize_path "${repo}")"

  if [[ ! -d "${abs_repo}" ]]; then
    warn "Repo path not found: ${abs_repo}"
    return 1
  fi

  if [[ ! -e "${abs_repo}/.git" ]]; then
    warn "No .git found at ${abs_repo} (continuing anyway)"
  fi

  log "== Repo install: ${abs_repo} =="
  run_cmd mkdir -p "${abs_repo}/docs" "${abs_repo}/agent" "${abs_repo}/.codex/hooks"

  copy_with_policy "${TEMPLATE_ROOT}/repo/AGENTS.md" "${abs_repo}/AGENTS.md"
  copy_with_policy "${TEMPLATE_ROOT}/repo/docs/AGENTS.override.md" "${abs_repo}/docs/AGENTS.override.md"
  copy_with_policy "${TEMPLATE_ROOT}/repo/agent/AGENTS.md" "${abs_repo}/agent/AGENTS.md"
  copy_with_policy "${TEMPLATE_ROOT}/repo/.codex/hooks.json" "${abs_repo}/.codex/hooks.json"
  copy_with_policy "${TEMPLATE_ROOT}/repo/.codex/hooks/python_env_guard.py" "${abs_repo}/.codex/hooks/python_env_guard.py"

  run_cmd chmod +x "${abs_repo}/.codex/hooks/python_env_guard.py"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --codex-home)
      [[ $# -ge 2 ]] || { warn "Missing value for --codex-home"; exit 1; }
      codex_home="$2"
      shift 2
      ;;
    --codex-home=*)
      codex_home="${1#*=}"
      shift 1
      ;;
    --repo)
      [[ $# -ge 2 ]] || { warn "Missing value for --repo"; exit 1; }
      repos+=("$2")
      shift 2
      ;;
    --repo=*)
      repos+=("${1#*=}")
      shift 1
      ;;
    --no-system)
      install_system=0
      shift 1
      ;;
    --no-repo)
      install_repo=0
      shift 1
      ;;
    --force)
      force=1
      shift 1
      ;;
    --dry-run)
      dry_run=1
      shift 1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      warn "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ "${install_repo}" -eq 1 && "${#repos[@]}" -eq 0 ]]; then
  warn "No --repo supplied. Repo install will be skipped."
  install_repo=0
fi

if [[ "${install_system}" -eq 1 ]]; then
  install_system_files
fi

if [[ "${install_repo}" -eq 1 ]]; then
  for repo in "${repos[@]}"; do
    install_repo_files "${repo}"
  done
fi

log ""
log "Setup complete."
log "Launch Codex with:"
log "  CODEX_HOME=\"${codex_home}\" codex --sandbox workspace-write --ask-for-approval on-request"
