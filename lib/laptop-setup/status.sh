show_status() {
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
    "$HOME/.config/starship.toml" \
    "$HOME/.config/bat/config" \
    "$HOME/.config/fastfetch/config.jsonc"; do
    if [[ -L "$target" && "$(readlink -f -- "$target")" == "$REPO_ROOT"/* ]]; then
      printf '  [linked]  %s\n' "$target"
    else
      printf '  [local]   %s\n' "$target"
    fi
  done
}
