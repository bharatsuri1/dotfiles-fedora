readonly VSCODE_FLATPAK_ID="com.visualstudio.code"
readonly VSCODE_FLATPAK_CONFIG="$HOME/.var/app/${VSCODE_FLATPAK_ID}/config/Code/User"
readonly VSCODE_SETTINGS_SOURCE="$REPO_ROOT/config/vscode/settings.json"
readonly VSCODE_SETTINGS_TARGET="$VSCODE_FLATPAK_CONFIG/settings.json"
readonly VSCODE_KEYBINDINGS_SOURCE="$REPO_ROOT/config/vscode/keybindings.json"
readonly VSCODE_KEYBINDINGS_TARGET="$VSCODE_FLATPAK_CONFIG/keybindings.json"

# Flatpak user overrides required so the integrated terminal runs the host login
# shell with a usable environment. The profile in settings.json launches
# `flatpak-spawn --host zsh`; these overrides let the sandbox forward the host
# terminal's TERM/COLORTERM and allow richer host-spawn negotiation. ZDOTDIR is
# not forwarded into host spawns on Development apps, so the host zsh resolves
# the managed ~/.config/zsh startup normally.
readonly VSCODE_TERMINAL_ENV_OVERRIDES=(
  "TERM=xterm-256color"
  "COLORTERM=truecolor"
)
readonly VSCODE_HOST_SPAWN_TALK_NAME="org.freedesktop.Flatpak"

# Docker socket visible inside the sandbox so the container extensions
# (ms-azuretools.vscode-docker, ms-azuretools.vscode-containers,
# ms-vscode-remote.remote-containers) can reach the host Docker daemon.
# /var/run is a symlink to /run, and bwrap refuses to bind paths through it,
# so the override must reference /run/docker.sock.
readonly VSCODE_DOCKER_SOCKET="/run/docker.sock"

# Reviewed extension allowlist.
# Reviewed extension allowlist.
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
  pomdtr.excalidraw-editor
)

vscode_app_installed() {
  command -v flatpak >/dev/null 2>&1 && flatpak info "$VSCODE_FLATPAK_ID" >/dev/null 2>&1
}

vscode_extension_installed() {
  local ext_id="$1"
  flatpak run --command=code "$VSCODE_FLATPAK_ID" --list-extensions 2>/dev/null \
    | grep -Fixq "$ext_id"
}

link_vscode_config() {
  link_config "$VSCODE_SETTINGS_SOURCE" "$VSCODE_SETTINGS_TARGET"
  link_config "$VSCODE_KEYBINDINGS_SOURCE" "$VSCODE_KEYBINDINGS_TARGET"
}

vscode_flatpak_override_show() {
  flatpak override --user --show "$VSCODE_FLATPAK_ID" 2>/dev/null || true
}

vscode_overrides_expected() {
  local overrides
  overrides="$(vscode_flatpak_override_show)"

  local setting
  local -a actual=()
  mapfile -t actual < <(sed -n '/^\[Environment\]$/,/^\[/p' <<<"$overrides" | tail -n +2)
  while [[ ${#actual[@]} -gt 0 && -z "${actual[$((${#actual[@]} - 1))]}" ]]; do
    unset 'actual[$((${#actual[@]} - 1))]'
  done

  ((${#actual[@]} == ${#VSCODE_TERMINAL_ENV_OVERRIDES[@]})) || return 1
  local index
  for index in "${!VSCODE_TERMINAL_ENV_OVERRIDES[@]}"; do
    [[ "${actual[index]}" == "${VSCODE_TERMINAL_ENV_OVERRIDES[index]}" ]] || return 1
  done

  sed -n '/^\[Session Bus Policy\]$/,/^\[/p' <<<"$overrides" | grep -Fxq "${VSCODE_HOST_SPAWN_TALK_NAME}=talk"
}

vscode_docker_socket_override_expected() {
  local filesystems
  filesystems="$(sed -n 's/^filesystems=//p' <<<"$(vscode_flatpak_override_show)")"
  [[ ";${filesystems};" == *";${VSCODE_DOCKER_SOCKET};"* ]]
}

apply_vscode_flatpak_overrides() {
  if vscode_overrides_expected; then
    log "VS Code flatpak terminal overrides already applied"
  else
    local -a flags=("--talk-name=$VSCODE_HOST_SPAWN_TALK_NAME")
    local setting
    for setting in "${VSCODE_TERMINAL_ENV_OVERRIDES[@]}"; do
      flags+=("--env=$setting")
    done
    run flatpak override --user "${flags[@]}" "$VSCODE_FLATPAK_ID"
  fi

  if vscode_docker_socket_override_expected; then
    log "VS Code flatpak Docker socket override already applied"
  else
    run flatpak override --user --filesystem="$VSCODE_DOCKER_SOCKET" "$VSCODE_FLATPAK_ID"
  fi
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
  apply_vscode_flatpak_overrides
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

  # Host-terminal flatpak overrides required by the integrated terminal profile.
  if vscode_overrides_expected; then
    printf '  [applied] flatpak overrides (host zsh terminal env)\n'
  else
    printf '  [missing] flatpak overrides (host zsh terminal env)\n'
  fi

  # Docker socket override required by the container extensions.
  if vscode_docker_socket_override_expected; then
    printf '  [applied] flatpak Docker socket (%s)\n' "$VSCODE_DOCKER_SOCKET"
  else
    printf '  [missing] flatpak Docker socket (%s)\n' "$VSCODE_DOCKER_SOCKET"
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
