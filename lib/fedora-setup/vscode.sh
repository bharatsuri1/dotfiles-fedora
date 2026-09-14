# shellcheck shell=bash
readonly VSCODE_REPOSITORY_SOURCE="$REPO_ROOT/config/vscode/vscode.repo"
readonly VSCODE_REPOSITORY_TARGET="/etc/yum.repos.d/vscode.repo"
readonly VSCODE_BINARY="/usr/bin/code"
readonly VSCODE_CONFIG="$HOME/.config/Code/User"
readonly VSCODE_SETTINGS_SOURCE="$REPO_ROOT/config/vscode/settings.json"
readonly VSCODE_SETTINGS_TARGET="$VSCODE_CONFIG/settings.json"
readonly VSCODE_KEYBINDINGS_SOURCE="$REPO_ROOT/config/vscode/keybindings.json"
readonly VSCODE_KEYBINDINGS_TARGET="$VSCODE_CONFIG/keybindings.json"

# Reviewed extension allowlist.
readonly VSCODE_EXTENSIONS=(
  vscodevim.vim
  ms-vscode-remote.remote-ssh
  ms-vscode-remote.remote-ssh-edit
  GitHub.vscode-pull-request-github
  ms-vscode.remote-explorer
  raunofreiberg.vesper
  ms-azuretools.vscode-docker
  ms-vscode-remote.remote-containers
  ms-azuretools.vscode-containers
  GitHub.vscode-github-actions
  pomdtr.excalidraw-editor
)

vscode_app_installed() {
  package_installed code && [[ -x "$VSCODE_BINARY" ]]
}

vscode_extension_installed() {
  local ext_id="$1"
  vscode_app_installed || return 1
  "$VSCODE_BINARY" --list-extensions 2>/dev/null | grep -Fix "$ext_id" >/dev/null
}

configure_vscode_repository() {
  if cmp -s -- "$VSCODE_REPOSITORY_SOURCE" "$VSCODE_REPOSITORY_TARGET"; then
    log 'official VS Code repository already configured'
    return
  fi

  if [[ -e "$VSCODE_REPOSITORY_TARGET" || -L "$VSCODE_REPOSITORY_TARGET" ]]; then
    ensure_backup_dir
    local backup="$BACKUP_DIR/etc/yum.repos.d/vscode.repo"
    run mkdir -p "$(dirname -- "$backup")"
    run sudo cp -a -- "$VSCODE_REPOSITORY_TARGET" "$backup"
    log "backed up $VSCODE_REPOSITORY_TARGET to $backup"
  fi
  run sudo install -m 0644 "$VSCODE_REPOSITORY_SOURCE" "$VSCODE_REPOSITORY_TARGET"
  # DNF imports the configured gpgkey when needed and verifies package signatures.
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
      run "$VSCODE_BINARY" --install-extension "$ext"
    fi
  done
}

install_vscode() {
  configure_vscode_repository
  if vscode_app_installed; then
    log 'VS Code RPM already installed'
  else
    local -a command=(sudo dnf install --refresh)
    $ASSUME_YES && command+=(--assumeyes)
    run "${command[@]}" code
  fi

  if ! $DRY_RUN && ! vscode_app_installed; then
    die "VS Code RPM installation did not produce $VSCODE_BINARY"
  fi
  link_vscode_config
  install_vscode_extensions
}

show_vscode_status() {
  printf 'VS Code:\n'
  if vscode_app_installed; then
    printf '  [ok]      code RPM (%s)\n' "$VSCODE_BINARY"
  else
    printf '  [missing] code RPM (%s)\n' "$VSCODE_BINARY"
  fi
  if cmp -s -- "$VSCODE_REPOSITORY_SOURCE" "$VSCODE_REPOSITORY_TARGET"; then
    printf '  [managed] %s\n' "$VSCODE_REPOSITORY_TARGET"
  else
    printf '  [missing/wrong] %s\n' "$VSCODE_REPOSITORY_TARGET"
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

  local ext
  for ext in "${VSCODE_EXTENSIONS[@]}"; do
    if vscode_extension_installed "$ext"; then
      printf '  [ok]      extension %s\n' "$ext"
    else
      printf '  [missing] extension %s\n' "$ext"
    fi
  done
}
