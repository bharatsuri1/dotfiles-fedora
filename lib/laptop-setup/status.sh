show_status() {
  printf 'Login shell:\n'
  local login_shell
  login_shell="$(getent passwd "$(id -un)" | cut -d: -f7)"
  if [[ -n "$login_shell" ]]; then
    printf '  [configured] %s\n' "$login_shell"
  else
    printf '  [unknown] unable to read the login shell\n'
  fi

  printf 'Default browser:\n'
  local default_browser
  default_browser="$(xdg-settings get default-web-browser 2>/dev/null || true)"
  if [[ -n "$default_browser" ]]; then
    printf '  [configured] %s\n' "$default_browser"
  else
    printf '  [unknown] no default browser configured\n'
  fi

  printf 'Chromium policy:\n'
  if [[ -r "$CHROMIUM_POLICY_TARGET" ]] &&
    cmp -s "$CHROMIUM_POLICY_SOURCE" "$CHROMIUM_POLICY_TARGET"; then
    printf '  [managed] %s\n' "$CHROMIUM_POLICY_TARGET"
  elif [[ -e "$CHROMIUM_POLICY_TARGET" ]]; then
    printf '  [local]   %s\n' "$CHROMIUM_POLICY_TARGET"
  else
    printf '  [missing] %s\n' "$CHROMIUM_POLICY_TARGET"
  fi

  printf 'Graphical login:\n'
  local boot_target display_manager display_manager_fragment display_manager_state
  boot_target="$(systemctl get-default 2>/dev/null || true)"
  display_manager_state="$(systemctl show display-manager.service -p LoadState --value 2>/dev/null || true)"
  if [[ "$display_manager_state" == loaded ]]; then
    display_manager_fragment="$(systemctl show display-manager.service -p FragmentPath --value 2>/dev/null || true)"
    display_manager="$(basename -- "$display_manager_fragment")"
  else
    display_manager=""
  fi
  printf '  [target]   %s\n' "${boot_target:-unknown}"
  if [[ -n "$display_manager" ]]; then
    printf '  [enabled]  %s\n' "$display_manager"
  else
    printf '  [missing]  display-manager.service\n'
  fi
  if package_installed dms-greeter; then
    printf '  [ok]       dms-greeter\n'
  else
    printf '  [missing]  dms-greeter\n'
  fi
  if [[ -r "$NIRI_SESSION_FILE" ]] && grep -Eq '^Exec=niri-session$' "$NIRI_SESSION_FILE"; then
    printf '  [ok]       niri-session\n'
  else
    printf '  [invalid]  %s\n' "$NIRI_SESSION_FILE"
  fi

  printf 'Fedora packages:\n'
  local item
  for item in "${DNF_PACKAGES[@]}"; do
    if package_installed "$item"; then
      printf '  [ok]      %s\n' "$item"
    else
      printf '  [missing] %s\n' "$item"
    fi
  done

  printf 'Development runtime tools:\n'
  for item in "${DEVELOPMENT_PACKAGES[@]}"; do
    if package_installed "$item"; then
      printf '  [ok]      %s\n' "$item"
    else
      printf '  [missing] %s\n' "$item"
    fi
  done

  printf 'Mise-managed npm tools:\n'
  for item in "${NPM_GLOBAL_PACKAGES[@]}"; do
    if npm_global_package_installed "$item"; then
      printf '  [ok]      %s\n' "$item"
    else
      printf '  [missing] %s\n' "$item"
    fi
  done

  printf 'Herdr:\n'
  if [[ -x "$HERDR_BINARY" ]]; then
    printf '  [ok]      %s\n' "$HERDR_BINARY"
  else
    printf '  [missing] %s\n' "$HERDR_BINARY"
  fi

  printf 'Docker:\n'
  for item in "${DOCKER_PACKAGES[@]}"; do
    if package_installed "$item"; then
      printf '  [ok]      %s\n' "$item"
    else
      printf '  [missing] %s\n' "$item"
    fi
  done

  printf 'Desktop graphics and media:\n'
  for item in "${DESKTOP_GRAPHICS_PACKAGES[@]}"; do
    if package_installed "$item"; then
      printf '  [ok]      %s\n' "$item"
    else
      printf '  [missing] %s\n' "$item"
    fi
  done

  printf 'Desktop audio:\n'
  for item in "${DESKTOP_AUDIO_PACKAGES[@]}"; do
    if package_installed "$item"; then
      printf '  [ok]      %s\n' "$item"
    else
      printf '  [missing] %s\n' "$item"
    fi
  done

  printf 'Desktop Bluetooth:\n'
  for item in "${DESKTOP_BLUETOOTH_PACKAGES[@]}"; do
    if package_installed "$item"; then
      printf '  [ok]      %s\n' "$item"
    else
      printf '  [missing] %s\n' "$item"
    fi
  done
  if systemctl is-enabled bluetooth.service >/dev/null 2>&1; then
    printf '  [enabled] bluetooth.service\n'
  else
    printf '  [disabled] bluetooth.service\n'
  fi

  printf 'Desktop authorization and secrets:\n'
  for item in "${DESKTOP_SECURITY_PACKAGES[@]}"; do
    if package_installed "$item"; then
      printf '  [ok]      %s\n' "$item"
    else
      printf '  [missing] %s\n' "$item"
    fi
  done

  printf 'Desktop portals:\n'
  for item in "${DESKTOP_PORTAL_PACKAGES[@]}"; do
    if package_installed "$item"; then
      printf '  [ok]      %s\n' "$item"
    else
      printf '  [missing] %s\n' "$item"
    fi
  done

  printf 'Desktop utilities:\n'
  for item in "${DESKTOP_UTILITY_PACKAGES[@]}"; do
    if package_installed "$item"; then
      printf '  [ok]      %s\n' "$item"
    else
      printf '  [missing] %s\n' "$item"
    fi
  done

  printf 'Desktop applications:\n'
  for item in "${DESKTOP_APPLICATION_PACKAGES[@]}"; do
    if package_installed "$item"; then
      printf '  [ok]      %s\n' "$item"
    else
      printf '  [missing] %s\n' "$item"
    fi
  done

  printf 'Desktop compatibility:\n'
  for item in "${DESKTOP_COMPATIBILITY_PACKAGES[@]}"; do
    if package_installed "$item"; then
      printf '  [ok]      %s\n' "$item"
    else
      printf '  [missing] %s\n' "$item"
    fi
  done

  printf 'Desktop shell:\n'
  for item in niri dms; do
    if package_installed "$item"; then
      printf '  [ok]      %s\n' "$item"
    else
      printf '  [missing] %s\n' "$item"
    fi
  done

  printf 'Keyboard remapping:\n'
  if package_installed keyd; then
    printf '  [ok]      keyd\n'
  else
    printf '  [missing] keyd\n'
  fi
  if [[ -r "$KEYD_CONFIG_TARGET" ]] && cmp -s "$KEYD_CONFIG_SOURCE" "$KEYD_CONFIG_TARGET"; then
    printf '  [managed] %s\n' "$KEYD_CONFIG_TARGET"
  else
    printf '  [local]   %s\n' "$KEYD_CONFIG_TARGET"
  fi

  show_font_status

  printf 'Flatpak applications:\n'
  for item in "${FLATPAK_APPS[@]}"; do
    if command -v flatpak >/dev/null 2>&1 && flatpak info "$item" >/dev/null 2>&1; then
      printf '  [ok]      %s\n' "$item"
    else
      printf '  [missing] %s\n' "$item"
    fi
  done

  printf 'Homebrew formulae:\n'
  local brew
  brew="$(brew_path || true)"

  for item in "${BREW_FORMULAE[@]}"; do
    if [[ -n "$brew" ]] && "$brew" list --formula "$item" >/dev/null 2>&1; then
      printf '  [ok]      %s\n' "$item"
    else
      printf '  [missing] %s\n' "$item"
    fi
  done

  printf 'Zsh plugins:\n'
  local plugin revision destination
  while read -r plugin revision; do
    destination="$ZSH_PLUGIN_ROOT/$plugin"
    if [[ -d "$destination/.git" ]] &&
      [[ "$(git -C "$destination" rev-parse HEAD 2>/dev/null || true)" == "$revision" ]]; then
      printf '  [pinned]  %s @ %s\n' "$plugin" "${revision:0:7}"
    else
      printf '  [missing] %s @ %s\n' "$plugin" "${revision:0:7}"
    fi
  done <<EOF
zsh-autosuggestions $AUTOSUGGESTIONS_REVISION
fast-syntax-highlighting $SYNTAX_HIGHLIGHTING_REVISION
EOF

  printf 'Configuration:\n'
  local target
  for target in \
    "$HOME/.config/alacritty/alacritty.toml" \
    "$HOME/.zshenv" \
    "$HOME/.config/zsh/.zshrc" \
    "$HOME/.config/zsh/aliases.zsh" \
    "$HOME/.config/zsh/completion.zsh" \
    "$HOME/.config/zsh/integrations.zsh" \
    "$HOME/.config/zsh/options.zsh" \
    "$HOME/.config/zsh/plugins.zsh" \
    "$HOME/.config/atuin/config.toml" \
    "$HOME/.config/mise/config.toml" \
    "$HOME/.config/tmux/tmux.conf" \
    "$HOME/.config/tmux/status.conf" \
    "$HOME/.config/sesh/sesh.toml" \
    "$HOME/.pi/agent/settings.json" \
    "$HOME/.pi/agent/extensions/statusline.ts" \
    "$HOME/.config/starship.toml" \
    "$HOME/.config/bat/config" \
    "$HOME/.config/fastfetch/config.jsonc" \
    "$HOME/.config/herdr/config.toml" \
    "$HOME/.config/niri/config.kdl"; do
    if [[ -L "$target" && "$(readlink -f -- "$target")" == "$REPO_ROOT"/* ]]; then
      printf '  [linked]  %s\n' "$target"
    else
      printf '  [local]   %s\n' "$target"
    fi
  done
}
