#!/usr/bin/env bash

set -Eeuo pipefail

readonly REPOSITORY_URL="${DOTFILES_FEDORA_REPOSITORY_URL:-https://github.com/bharatsuri1/dotfiles-fedora.git}"
readonly INSTALL_ROOT="${DOTFILES_FEDORA_INSTALL_ROOT:-$HOME/.local/share/dotfiles-fedora}"

log() {
  printf '==> %s\n' "$*"
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

[[ -r /etc/os-release ]] || die 'cannot identify this operating system'
# shellcheck disable=SC1091
source /etc/os-release
[[ "${ID:-}" == fedora ]] || die 'this bootstrap currently supports Fedora only'

if ! command -v git >/dev/null 2>&1; then
  log 'installing Git as the bootstrap prerequisite'
  sudo dnf install --assumeyes git
fi

if [[ -d "$INSTALL_ROOT/.git" ]]; then
  log "updating existing checkout at $INSTALL_ROOT"
  git -C "$INSTALL_ROOT" pull --ff-only
elif [[ -e "$INSTALL_ROOT" ]]; then
  die "$INSTALL_ROOT exists but is not a Git checkout; move it aside or set DOTFILES_FEDORA_INSTALL_ROOT"
else
  log "cloning dotfiles-fedora into $INSTALL_ROOT"
  mkdir -p "$(dirname -- "$INSTALL_ROOT")"
  git clone "$REPOSITORY_URL" "$INSTALL_ROOT"
fi

log 'starting the guided Fedora laptop setup'
if (($#)); then
  exec "$INSTALL_ROOT/bin/laptop-setup" "$@"
else
  exec "$INSTALL_ROOT/bin/laptop-setup" apply
fi
