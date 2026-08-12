set_shell() {
  local zsh_path
  zsh_path="$(command -v zsh || true)"
  if [[ -z "$zsh_path" ]]; then
    if $DRY_RUN; then
      log 'would change the login shell to the Zsh installed by the packages phase'
      return
    fi
    die 'Zsh is missing; run the packages phase first'
  fi

  if [[ "$(getent passwd "$USER" | cut -d: -f7)" == "$zsh_path" ]]; then
    log 'Zsh is already the login shell'
    return
  fi

  if confirm "Change the login shell to $zsh_path?"; then
    run sudo usermod --shell "$zsh_path" "$USER"
    log 'log out and back in to enter the new login shell'
  else
    log 'login-shell change skipped'
  fi
}
