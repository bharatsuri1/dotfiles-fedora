readonly STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-fedora"
readonly BACKUP_ROOT="$STATE_DIR/backups"
readonly FONT_DEST="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/JetBrainsMonoNerd"
readonly NERD_FONTS_VERSION="3.5.0"
readonly NERD_FONTS_SHA256="0227b220360a6f819b9ead92343e8112b34733054782561af50cfba1e8afab63"
readonly NERD_FONTS_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v${NERD_FONTS_VERSION}/JetBrainsMono.tar.xz"
readonly ZSH_PLUGIN_ROOT="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/plugins"
readonly AUTOSUGGESTIONS_REPOSITORY="https://github.com/zsh-users/zsh-autosuggestions.git"
readonly AUTOSUGGESTIONS_REVISION="85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5"
readonly SYNTAX_HIGHLIGHTING_REPOSITORY="https://github.com/zdharma-continuum/fast-syntax-highlighting.git"
readonly SYNTAX_HIGHLIGHTING_REVISION="3d574ccf48804b10dca52625df13da5edae7f553"

DRY_RUN=false
ASSUME_YES=false
BACKUP_DIR=""

readonly DNF_PACKAGES=(
  alacritty
  atuin
  bat
  btop
  chromium
  curl
  eza
  fastfetch
  fd-find
  flatpak
  fontconfig
  fzf
  git
  gh
  neovim
  nodejs
  ripgrep
  tmux
  xdg-utils
  xz
  zoxide
  zsh
)

readonly DESKTOP_GRAPHICS_PACKAGES=(
  mesa-dri-drivers
  mesa-vulkan-drivers
  intel-vpl-gpu-rt
  libva-intel-media-driver
  libva-utils
)

readonly DESKTOP_AUDIO_PACKAGES=(
  pipewire
  pipewire-alsa
  pipewire-pulseaudio
  wireplumber
  alsa-utils
)

readonly DESKTOP_BLUETOOTH_PACKAGES=(
  bluez
)

readonly DESKTOP_SECURITY_PACKAGES=(
  polkit
  gnome-keyring
  libsecret
)

readonly FLATPAK_APPS=(
  org.localsend.localsend_app
)

readonly BREW_FORMULAE=(
  dashlane/tap/dashlane-cli
  starship
  jless
  fx
  lazygit
)

readonly BREW_TRUST_TAPS=(
  dashlane/tap/dashlane-cli
)

log() {
  printf '==> %s\n' "$*"
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

run() {
  if $DRY_RUN; then
    printf '+ '
    printf '%q ' "$@"
    printf '\n'
  else
    "$@"
  fi
}

confirm() {
  local prompt="$1"
  $ASSUME_YES && return 0
  local answer
  if [[ -r /dev/tty ]]; then
    read -r -p "$prompt [y/N] " answer </dev/tty
  else
    die 'interactive confirmation requires a terminal; rerun with --yes for non-interactive use'
  fi
  [[ "$answer" == [yY] || "$answer" == [yY][eE][sS] ]]
}

require_fedora() {
  [[ -r /etc/os-release ]] || die 'cannot identify this operating system'
  # shellcheck disable=SC1091
  source /etc/os-release
  [[ "${ID:-}" == fedora ]] || die 'this CLI currently supports Fedora only'
}
