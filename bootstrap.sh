#!/usr/bin/env bash

set -Eeuo pipefail

readonly REPOSITORY_URL="${DOTFILES_FEDORA_REPOSITORY_URL:-https://github.com/bharatsuri1/dotfiles-fedora.git}"
readonly INSTALL_ROOT="${DOTFILES_FEDORA_INSTALL_ROOT:-$HOME/.local/share/dotfiles-fedora}"
readonly LOCAL_BIN="$HOME/.local/bin"

readonly GIT_NAME="${DOTFILES_GIT_NAME:-Bharat Suri}"
readonly GIT_EMAIL="${DOTFILES_GIT_EMAIL:-bharatsuri.us@gmail.com}"

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

exec "$INSTALL_ROOT/bin/laptop-setup" "\$@"
EOF

chmod +x "$LOCAL_BIN/laptop-setup"

log 'configuring Git defaults'

git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global push.autoSetupRemote true
git config --global core.editor nvim


log 'starting the guided Fedora laptop setup'
if (($#)); then
  exec "$INSTALL_ROOT/bin/laptop-setup" "$@"
else
  exec "$INSTALL_ROOT/bin/laptop-setup" apply
fi
