install_zsh_plugin() {
  local name="$1"
  local repository="$2"
  local revision="$3"
  local destination="$ZSH_PLUGIN_ROOT/$name"

  if [[ -d "$destination/.git" ]] &&
    [[ "$(git -C "$destination" rev-parse HEAD 2>/dev/null || true)" == "$revision" ]]; then
    log "$name already pinned at $revision"
    return
  fi

  if $DRY_RUN; then
    if [[ -d "$destination/.git" ]]; then
      printf '+ git -C %q fetch --quiet origin %q\n' "$destination" "$revision"
    else
      printf '+ git clone %q %q\n' "$repository" "$destination"
    fi
    printf '+ git -C %q checkout --detach %q\n' "$destination" "$revision"
    return
  fi

  install -d "$ZSH_PLUGIN_ROOT"
  if [[ -d "$destination/.git" ]]; then
    git -C "$destination" fetch --quiet origin "$revision"
  elif [[ -e "$destination" ]]; then
    die "$destination exists but is not a Git checkout; move it aside and rerun the shell-tools phase"
  else
    git clone "$repository" "$destination"
  fi
  git -C "$destination" checkout --detach "$revision"
}

install_shell_tools() {
  command -v git >/dev/null 2>&1 || die 'Git is missing; run the packages phase first'
  log 'installing directly sourced Zsh plugins without a plugin manager'
  install_zsh_plugin zsh-autosuggestions "$AUTOSUGGESTIONS_REPOSITORY" "$AUTOSUGGESTIONS_REVISION"
  install_zsh_plugin fast-syntax-highlighting "$SYNTAX_HIGHLIGHTING_REPOSITORY" "$SYNTAX_HIGHLIGHTING_REVISION"
  install_zsh_plugin fzf-tab "$FZF_TAB_REPOSITORY" "$FZF_TAB_REVISION"
}
