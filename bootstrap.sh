#!/usr/bin/env bash

set -Eeuo pipefail

readonly REPOSITORY_URL="${DOTFILES_FEDORA_REPOSITORY_URL:-https://github.com/bharatsuri1/dotfiles-fedora.git}"
readonly INSTALL_ROOT="${DOTFILES_FEDORA_INSTALL_ROOT:-$HOME/.local/share/dotfiles-fedora}"

readonly GIT_NAME="${DOTFILES_GIT_NAME:-Bharat Suri}"
readonly GIT_EMAIL="${DOTFILES_GIT_EMAIL:-bharatsuri.us@gmail.com}"

# Prefer the managed output helpers when the bootstrap runs from inside a
# checkout. The piped `curl | bash` flow has no repository yet, so define
# plain equivalents instead.
_bootstrap_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)" || _bootstrap_dir=""
if [[ -n "${_bootstrap_dir:-}" && -r "${_bootstrap_dir}/lib/fedora-setup/output.sh" ]]; then
  # shellcheck source=/dev/null
  source "${_bootstrap_dir}/lib/fedora-setup/output.sh"
else
  log() { printf '==> %s\n' "$*"; }
  die() { printf 'error: %s\n' "$*" >&2; exit 1; }
  run() { "$@"; }
  section() { printf '── %s ──────────────────────────\n' "$*"; }
  output_summary() { :; }
fi
unset _bootstrap_dir

[[ -r /etc/os-release ]] || die 'cannot identify this operating system'
# shellcheck disable=SC1091
source /etc/os-release
[[ "${ID:-}" == fedora ]] || die 'this bootstrap currently supports Fedora only'

bootstrap_packages=(
  git
  curl
  tar
  gzip
  xz
  unzip
)

section "Bootstrap prerequisites"
log 'ensuring bootstrap prerequisites are installed'
run sudo dnf install --assumeyes "${bootstrap_packages[@]}"

section Checkout
if [[ -d "$INSTALL_ROOT/.git" ]]; then
  log "updating existing checkout at $INSTALL_ROOT"
  current_branch="$(git -C "$INSTALL_ROOT" symbolic-ref --quiet --short HEAD)" ||
    die "$INSTALL_ROOT has a detached HEAD; check out main or run ./bin/fedora-setup to use it unchanged"
  [[ "$current_branch" == main ]] ||
    die "$INSTALL_ROOT is on branch $current_branch; check out main or run ./bin/fedora-setup to use it unchanged"
  run git -C "$INSTALL_ROOT" pull --ff-only origin main
elif [[ -e "$INSTALL_ROOT" ]]; then
  die "$INSTALL_ROOT exists but is not a Git checkout; move it aside or set DOTFILES_FEDORA_INSTALL_ROOT"
else
  log "cloning dotfiles-fedora into $INSTALL_ROOT"
  run mkdir -p "$(dirname -- "$INSTALL_ROOT")"
  run git clone "$REPOSITORY_URL" "$INSTALL_ROOT"
fi

section "Git defaults"
log 'configuring Git defaults'

run git config --global user.name "$GIT_NAME"
run git config --global user.email "$GIT_EMAIL"
run git config --global init.defaultBranch main
run git config --global pull.rebase false
run git config --global push.autoSetupRemote true
run git config --global core.editor nvim

section Setup
log 'starting the guided Fedora setup'
if (($#)); then
  exec "$INSTALL_ROOT/bin/fedora-setup" "$@"
else
  exec "$INSTALL_ROOT/bin/fedora-setup" apply
fi