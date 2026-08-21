readonly VSCODE_FLATPAK_ID="com.visualstudio.code"
readonly VSCODE_FLATPAK_CONFIG="$HOME/.var/app/${VSCODE_FLATPAK_ID}/config/Code/User"
readonly VSCODE_SETTINGS_SOURCE="$REPO_ROOT/config/vscode/settings.json"
readonly VSCODE_SETTINGS_TARGET="$VSCODE_FLATPAK_CONFIG/settings.json"
readonly VSCODE_KEYBINDINGS_SOURCE="$REPO_ROOT/config/vscode/keybindings.json"
readonly VSCODE_KEYBINDINGS_TARGET="$VSCODE_FLATPAK_CONFIG/keybindings.json"

# Reviewed extension allowlist.
# Rationale for each entry lives in docs/vscode.md.
readonly VSCODE_EXTENSIONS=(
  vscodevim.vim
  ms-vscode-remote.remote-ssh
  ms-vscode-remote.remote-ssh-edit
  GitHub.vscode-pull-request-github
  ms-vscode.remote-explorer
  openai.chatgpt
  raunofreiberg.vesper
  ms-azuretools.vscode-docker
  ms-vscode-remote.remote-containers
  ms-azuretools.vscode-containers
  GitHub.vscode-github-actions
  sst-dev.opencode
)

vscode_app_installed() {
  command -v flatpak >/dev/null 2>&1 && flatpak info "$VSCODE_FLATPAK_ID" >/dev/null 2>&1
}

vscode_extension_installed() {
  local ext_id="$1"
  flatpak run --command=code "$VSCODE_FLATPAK_ID" --list-extensions 2>/dev/null \
    | grep -Fxq "$ext_id"
}

link_vscode_config() {
  link_config "$VSCODE_SETTINGS_SOURCE" "$VSCODE_SETTINGS_TARGET"
  link_config "$VSCODE_KEYBINDINGS_SOURCE" "$VSCODE_KEYBINDINGS_TARGET"
}

install_vscode_extensions() {
  local ext
  for ext in "${VSCODE_EXTENSIONS[@]}"; do
    if vscode_extension_installed "$ext"; then
      log "VS Code extension $ext already installed"
    else
      run flatpak run --command=code "$VSCODE_FLATPAK_ID" --install-extension "$ext"
    fi
  done
}

install_vscode() {
  if ! vscode_app_installed && ! $DRY_RUN; then
    die "VS Code Flatpak ($VSCODE_FLATPAK_ID) is missing; run the flatpaks phase first"
  fi
  if ! vscode_app_installed && $DRY_RUN; then
    log "VS Code Flatpak ($VSCODE_FLATPAK_ID) is not installed; would still link managed configuration"
  fi

  link_vscode_config
  install_vscode_extensions
}

show_vscode_status() {
  printf 'VS Code:\n'
  if vscode_app_installed; then
    printf '  [ok]      %s\n' "$VSCODE_FLATPAK_ID"
  else
    printf '  [missing] %s\n' "$VSCODE_FLATPAK_ID"
  fi

  local target source resolved
  for target in "$VSCODE_SETTINGS_TARGET" "$VSCODE_KEYBINDINGS_TARGET"; do
    source=""
    case "$target" in
      "$VSCODE_SETTINGS_TARGET") source="$VSCODE_SETTINGS_SOURCE" ;;
      "$VSCODE_KEYBINDINGS_TARGET") source="$VSCODE_KEYBINDINGS_SOURCE" ;;
    esac
    resolved=""
    if [[ -L "$target" ]]; then
      resolved="$(readlink -f -- "$target" 2>/dev/null || true)"
    fi
    if [[ -n "$source" && "$resolved" == "$(readlink -f -- "$source" 2>/dev/null || true)" ]]; then
      printf '  [linked]  %s\n' "$target"
    elif [[ -L "$target" && -z "$resolved" ]]; then
      printf '  [broken]  %s\n' "$target"
    elif [[ -L "$target" ]]; then
      printf '  [wrong]   %s -> %s\n' "$target" "$resolved"
    elif [[ -e "$target" ]]; then
      printf '  [local]   %s\n' "$target"
    else
      printf '  [missing] %s\n' "$target"
    fi
  done

  # Alias is shell-config owned; report whether the managed alias file defines it.
  if grep -Eq "^alias code=" "$REPO_ROOT/config/zsh/aliases.zsh" 2>/dev/null; then
    printf '  [alias]   code -> flatpak run %s\n' "$VSCODE_FLATPAK_ID"
  else
    printf '  [missing] code alias in managed zsh aliases\n'
  fi

  if ((${#VSCODE_EXTENSIONS[@]})); then
    local ext
    for ext in "${VSCODE_EXTENSIONS[@]}"; do
      if vscode_extension_installed "$ext"; then
        printf '  [ok]      extension %s\n' "$ext"
      else
        printf '  [missing] extension %s\n' "$ext"
      fi
    done
  else
    printf '  [ok]      extension allowlist empty\n'
  fi
}