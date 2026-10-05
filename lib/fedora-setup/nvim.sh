readonly NVIM_CONFIG_SOURCE="$REPO_ROOT/config/nvim"
readonly NVIM_CONFIG_TARGET="$HOME/.config/nvim"

nvim_installed() {
  command -v nvim >/dev/null 2>&1
}

link_nvim_config() {
  link_config "$NVIM_CONFIG_SOURCE" "$NVIM_CONFIG_TARGET"
}

install_nvim() {
  section Neovim
  if ! nvim_installed && ! $DRY_RUN; then
    die "Neovim is missing; run the packages phase first"
  fi
  if ! nvim_installed && $DRY_RUN; then
    log "Neovim is not installed; would still link managed configuration"
  fi

  link_nvim_config
}

show_nvim_status() {
  section Neovim
  if nvim_installed; then
    report ok "$(command -v nvim)"
  else
    report missing nvim
  fi

  local resolved=""
  if [[ -L "$NVIM_CONFIG_TARGET" ]]; then
    resolved="$(readlink -f -- "$NVIM_CONFIG_TARGET" 2>/dev/null || true)"
  fi
  if [[ "$resolved" == "$(readlink -f -- "$NVIM_CONFIG_SOURCE" 2>/dev/null || true)" ]]; then
    report linked "$NVIM_CONFIG_TARGET"
  elif [[ -L "$NVIM_CONFIG_TARGET" && -z "$resolved" ]]; then
    report broken "$NVIM_CONFIG_TARGET"
  elif [[ -L "$NVIM_CONFIG_TARGET" ]]; then
    report wrong "$NVIM_CONFIG_TARGET -> $resolved"
  elif [[ -e "$NVIM_CONFIG_TARGET" ]]; then
    report local "$NVIM_CONFIG_TARGET"
  else
    report missing "$NVIM_CONFIG_TARGET"
  fi

  # Aliases are shell-config owned; report whether the managed alias file defines them.
  if grep -q "alias vim='nvim'" "$REPO_ROOT/config/zsh/aliases.zsh" 2>/dev/null; then
    report alias 'v, vi, vim -> nvim'
  else
    report missing 'v/vi/vim aliases in managed zsh aliases'
  fi
}
