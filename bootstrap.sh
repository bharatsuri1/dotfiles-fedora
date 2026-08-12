#!/usr/bin/env bash

set -Eeuo pipefail

readonly REPOSITORY_URL="${DOTFILES_FEDORA_REPOSITORY_URL:-https://github.com/bharatsuri1/dotfiles-fedora.git}"
readonly INSTALL_ROOT="${DOTFILES_FEDORA_INSTALL_ROOT:-$HOME/.local/share/dotfiles-fedora}"
readonly BOOTSTRAP_URL="https://raw.githubusercontent.com/bharatsuri1/dotfiles-fedora/main/bootstrap.sh"
readonly LOCAL_BIN="$HOME/.local/bin"

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

bootstrap_packages=(
  git
  curl
  tar
  gzip
  xz
  unzip
)

log 'ensuring bootstrap prerequisites are installed'
sudo dnf install --assumeyes "${bootstrap_packages[@]}"

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

log 'installing laptop-setup command'
mkdir -p "$LOCAL_BIN"

cat > "$LOCAL_BIN/laptop-setup" <<EOF
#!/usr/bin/env bash
set -Eeuo pipefail

curl -fsSL "$BOOTSTRAP_URL" | bash -s -- "\$@"
EOF

chmod +x "$LOCAL_BIN/laptop-setup"


log 'starting the guided Fedora laptop setup'
if (($#)); then
  exec "$INSTALL_ROOT/bin/laptop-setup" "$@"
else
  exec "$INSTALL_ROOT/bin/laptop-setup" apply
fi
