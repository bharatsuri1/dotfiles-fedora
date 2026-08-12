readonly STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-fedora"
readonly BACKUP_ROOT="$STATE_DIR/backups"
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

readonly DESKTOP_PORTAL_PACKAGES=(
  xdg-desktop-portal
  xdg-desktop-portal-gnome
  xdg-desktop-portal-gtk
)

readonly DESKTOP_UTILITY_PACKAGES=(
  brightnessctl
  playerctl
  wl-clipboard
)

readonly DESKTOP_APPLICATION_PACKAGES=(
  nautilus
  mpv
  imv
  evince
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
