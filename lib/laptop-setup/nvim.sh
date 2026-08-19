readonly NVIM_CONFIG_SOURCE="$REPO_ROOT/config/nvim"
readonly NVIM_CONFIG_TARGET="$HOME/.config/nvim"

nvim_installed() {
  command -v nvim >/dev/null 2>&1
}

link_nvim_config() {
  link_config "$NVIM_CONFIG_SOURCE" "$NVIM_CONFIG_TARGET"
}

install_nvim() {
  if ! nvim_installed && ! $DRY_RUN; then
    die "Neovim is missing; run the packages phase first"
  fi
  if ! nvim_installed && $DRY_RUN; then
    log "Neovim is not installed; would still link managed configuration"
  fi

  link_nvim_config
}

show_nvim_status() {
  printf 'Neovim:\n'
  if nvim_installed; then
    printf '  [ok]      %s\n' "$(command -v nvim)"
  else
    printf '  [missing] nvim\n'
  fi

  local resolved=""
  if [[ -L "$NVIM_CONFIG_TARGET" ]]; then
    resolved="$(readlink -f -- "$NVIM_CONFIG_TARGET" 2>/dev/null || true)"
  fi
  if [[ "$resolved" == "$(readlink -f -- "$NVIM_CONFIG_SOURCE" 2>/dev/null || true)" ]]; then
    printf '  [linked]  %s\n' "$NVIM_CONFIG_TARGET"
  elif [[ -L "$NVIM_CONFIG_TARGET" && -z "$resolved" ]]; then
    printf '  [broken]  %s\n' "$NVIM_CONFIG_TARGET"
  elif [[ -L "$NVIM_CONFIG_TARGET" ]]; then
    printf '  [wrong]   %s -> %s\n' "$NVIM_CONFIG_TARGET" "$resolved"
  elif [[ -e "$NVIM_CONFIG_TARGET" ]]; then
    printf '  [local]   %s\n' "$NVIM_CONFIG_TARGET"
  else
    printf '  [missing] %s\n' "$NVIM_CONFIG_TARGET"
  fi

  # Alias is shell-config owned; report whether the managed alias file defines it.
  if grep -q "alias vim='nvim'" "$REPO_ROOT/config/zsh/aliases.zsh" 2>/dev/null; then
    printf '  [alias]   vim -> nvim\n'
  else
    printf '  [missing] vim alias in managed zsh aliases\n'
  fi
}
