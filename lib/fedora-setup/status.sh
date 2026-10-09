show_status() {
  section Machine
  local os_name login_shell
  os_name="$(grep -m1 '^PRETTY_NAME=' /etc/os-release 2>/dev/null | cut -d= -f2- | tr -d '"')"
  report ok "${os_name:-Fedora} ($(uname -m))"
  report local "checkout $REPO_ROOT"
  login_shell="$(getent passwd "$(id -un)" | cut -d: -f7)"
  if [[ -n "$login_shell" ]]; then
    report ok "login shell $login_shell"
  else
    report missing 'unable to read the login shell'
  fi

  section "Default browser"
  local default_browser
  default_browser="$(xdg-settings get default-web-browser 2>/dev/null || true)"
  if [[ -n "$default_browser" ]]; then
    report ok "$default_browser"
  else
    report missing 'no default browser configured'
  fi
  if [[ -r "$CHROMIUM_POLICY_TARGET" ]] &&
    cmp -s "$CHROMIUM_POLICY_SOURCE" "$CHROMIUM_POLICY_TARGET"; then
    report ok "$CHROMIUM_POLICY_TARGET"
  elif [[ -e "$CHROMIUM_POLICY_TARGET" ]]; then
    report local "$CHROMIUM_POLICY_TARGET"
  else
    report missing "$CHROMIUM_POLICY_TARGET"
  fi

  section "Graphical login"
  local boot_target display_manager display_manager_fragment display_manager_state
  boot_target="$(systemctl get-default 2>/dev/null || true)"
  display_manager_state="$(systemctl show display-manager.service -p LoadState --value 2>/dev/null || true)"
  if [[ "$display_manager_state" == loaded ]]; then
    display_manager_fragment="$(systemctl show display-manager.service -p FragmentPath --value 2>/dev/null || true)"
    display_manager="$(basename -- "$display_manager_fragment")"
  else
    display_manager=""
  fi
  report local "boot target ${boot_target:-unknown}"
  if [[ -n "$display_manager" ]]; then
    report ok "$display_manager"
  else
    report missing 'display-manager.service'
  fi
  if [[ -r "$NIRI_SESSION_FILE" ]] && grep -Eq '^Exec=niri-session$' "$NIRI_SESSION_FILE"; then
    report ok 'niri-session'
  else
    report missing "$NIRI_SESSION_FILE"
  fi
  if package_installed sddm; then
    report ok sddm
  else
    report missing sddm
  fi
  if [[ -r "$SDDM_CONFIG_TARGET" && -r "$SDDM_THEME_TARGET/Main.qml" ]]; then
    report ok "managed SDDM theme ($SDDM_THEME_NAME)"
  else
    report missing 'managed SDDM theme'
  fi

  section Packages
  local item
  for item in "${DNF_PACKAGES[@]}"; do
    if package_installed "$item"; then
      report ok "$item"
    else
      report missing "$item"
    fi
  done

  section Development
  for item in "${DEVELOPMENT_PACKAGES[@]}"; do
    if package_installed "$item"; then
      report ok "$item"
    else
      report missing "$item"
    fi
  done
  for item in "${NPM_GLOBAL_PACKAGES[@]}"; do
    if npm_global_package_installed "$item"; then
      report ok "$item"
    else
      report missing "$item"
    fi
  done

  section OpenCode
  if [[ -x "$OPENCODE_BINARY" ]]; then
    report ok "$OPENCODE_BINARY"
  else
    report missing "$OPENCODE_BINARY"
  fi

  show_herdr_status

  show_ollama_status

  section Docker
  for item in "${DOCKER_PACKAGES[@]}"; do
    if package_installed "$item"; then
      report ok "$item"
    else
      report missing "$item"
    fi
  done

  section "Desktop foundation"
  for item in "${DESKTOP_GRAPHICS_PACKAGES[@]}"; do
    if package_installed "$item"; then
      report ok "$item"
    else
      report missing "$item"
    fi
  done
  for item in "${DESKTOP_AUDIO_PACKAGES[@]}"; do
    if package_installed "$item"; then
      report ok "$item"
    else
      report missing "$item"
    fi
  done
  for item in "${DESKTOP_BLUETOOTH_PACKAGES[@]}"; do
    if package_installed "$item"; then
      report ok "$item"
    else
      report missing "$item"
    fi
  done
  if systemctl is-enabled bluetooth.service >/dev/null 2>&1; then
    report ok 'bluetooth.service'
  else
    report missing 'bluetooth.service (disabled)'
  fi
  for item in "${DESKTOP_SECURITY_PACKAGES[@]}"; do
    if package_installed "$item"; then
      report ok "$item"
    else
      report missing "$item"
    fi
  done
  for item in "${DESKTOP_PORTAL_PACKAGES[@]}"; do
    if package_installed "$item"; then
      report ok "$item"
    else
      report missing "$item"
    fi
  done
  for item in "${DESKTOP_UTILITY_PACKAGES[@]}"; do
    if package_installed "$item"; then
      report ok "$item"
    else
      report missing "$item"
    fi
  done
  for item in "${DESKTOP_APPLICATION_PACKAGES[@]}"; do
    if package_installed "$item"; then
      report ok "$item"
    else
      report missing "$item"
    fi
  done
  for item in "${DESKTOP_COMPATIBILITY_PACKAGES[@]}"; do
    if package_installed "$item"; then
      report ok "$item"
    else
      report missing "$item"
    fi
  done

  section "Niri session"
  for item in "${DESKTOP_SESSION_PACKAGES[@]}"; do
    if package_installed "$item"; then
      report ok "$item"
    else
      report missing "$item"
    fi
  done
  for item in swaync.service swaybg.service swayidle.service lxqt-policykit-agent.service; do
    if [[ -L "$HOME/.config/systemd/user/niri.service.wants/$item" ]]; then
      report ok "$item attached"
    else
      report missing "$item detached"
    fi
  done

  show_device_controls_status

  show_system_tools_status

  show_voxtype_status

  show_vicinae_status

  section "Desktop shell"
  if package_installed niri; then
    report ok niri
  else
    report missing niri
  fi

  section Screenshots
  for item in "${SCREENSHOT_PACKAGES[@]}"; do
    if package_installed "$item"; then
      report ok "$item"
    else
      report missing "$item"
    fi
  done
  if tensaku_installed; then
    report pinned "Tensaku $TENSAKU_VERSION"
  else
    report missing "Tensaku $TENSAKU_VERSION"
  fi
  if tensaku_bundle_valid; then
    report ok "$TENSAKU_BUNDLE"
  else
    report missing "$TENSAKU_BUNDLE (invalid)"
  fi

  section Quickshell
  for item in "${QUICKSHELL_PACKAGES[@]}"; do
    if package_installed "$item"; then
      report ok "$item"
    else
      report missing "$item"
    fi
  done
  local quickshell_target="$HOME/.config/quickshell"
  local quickshell_source="$REPO_ROOT/config/quickshell"
  local quickshell_resolved=''
  if [[ -L "$quickshell_target" ]]; then
    quickshell_resolved="$(readlink -f -- "$quickshell_target" 2>/dev/null || true)"
  fi
  if [[ "$quickshell_resolved" == "$quickshell_source" && -r "$quickshell_target/shell.qml" ]]; then
    report linked "$quickshell_target"
  elif [[ -L "$quickshell_target" && -z "$quickshell_resolved" ]]; then
    report broken "$quickshell_target"
  elif [[ -L "$quickshell_target" ]]; then
    report wrong "$quickshell_target -> $quickshell_resolved"
  elif [[ -e "$quickshell_target" ]]; then
    report local "$quickshell_target"
  else
    report missing "$quickshell_target"
  fi
  if [[ -L "$HOME/.config/systemd/user/niri.service.wants/quickshell.service" ]]; then
    report ok 'quickshell.service attached'
  else
    report missing 'quickshell.service detached'
  fi
  if systemctl --user is-active quickshell.service >/dev/null 2>&1; then
    report ok 'quickshell.service active'
  else
    report local 'quickshell.service (inactive)'
  fi

  section Keyd
  if package_installed keyd; then
    report ok keyd
  else
    report missing keyd
  fi
  if [[ -r "$KEYD_CONFIG_TARGET" ]] && cmp -s "$KEYD_CONFIG_SOURCE" "$KEYD_CONFIG_TARGET"; then
    report ok "$KEYD_CONFIG_TARGET"
  else
    report local "$KEYD_CONFIG_TARGET"
  fi

  show_font_status

  section Flatpaks
  for item in "${FLATPAK_APPS[@]}"; do
    if command -v flatpak >/dev/null 2>&1 && flatpak info "$item" >/dev/null 2>&1; then
      report ok "$item"
    else
      report missing "$item"
    fi
  done

  show_zed_status

  show_vscode_status

  show_nvim_status

  section Homebrew
  local brew
  brew="$(brew_path || true)"
  for item in "${BREW_FORMULAE[@]}"; do
    if [[ -n "$brew" ]] && "$brew" list --formula "$item" >/dev/null 2>&1; then
      report ok "$item"
    else
      report missing "$item"
    fi
  done

  section "Zsh plugins"
  local plugin revision destination
  while read -r plugin revision; do
    destination="$ZSH_PLUGIN_ROOT/$plugin"
    if [[ -d "$destination/.git" ]] &&
      [[ "$(git -C "$destination" rev-parse HEAD 2>/dev/null || true)" == "$revision" ]]; then
      report pinned "$plugin @ ${revision:0:7}"
    else
      report missing "$plugin @ ${revision:0:7}"
    fi
  done <<EOF
zsh-autosuggestions $AUTOSUGGESTIONS_REVISION
fast-syntax-highlighting $SYNTAX_HIGHLIGHTING_REVISION
fzf-tab $FZF_TAB_REVISION
zsh-history-substring-search $HISTORY_SUBSTRING_SEARCH_REVISION
EOF

  section Configuration
  show_pi_settings_status
  local hook_path
  if hook_path="$(repo_hook_path)"; then
    if [[ -L "$hook_path" && "$(readlink -f -- "$hook_path" 2>/dev/null || true)" == "$REPO_ROOT/hooks/pre-commit" ]]; then
      report linked "$hook_path"
    else
      report missing "$hook_path (managed pre-commit hook)"
    fi
  fi
  local source target
  local -a config_links=(
    "$REPO_ROOT/config/zsh/zshenv" "$HOME/.zshenv"
    "$REPO_ROOT/config/zsh/zshenv" "$HOME/.config/zsh/.zshenv"
    "$REPO_ROOT/config/zsh/zshrc" "$HOME/.config/zsh/.zshrc"
    "$REPO_ROOT/config/zsh/aliases.zsh" "$HOME/.config/zsh/aliases.zsh"
    "$REPO_ROOT/config/zsh/completion.zsh" "$HOME/.config/zsh/completion.zsh"
    "$REPO_ROOT/config/zsh/cursor.zsh" "$HOME/.config/zsh/cursor.zsh"
    "$REPO_ROOT/config/zsh/integrations.zsh" "$HOME/.config/zsh/integrations.zsh"
    "$REPO_ROOT/config/zsh/options.zsh" "$HOME/.config/zsh/options.zsh"
    "$REPO_ROOT/config/zsh/plugins.zsh" "$HOME/.config/zsh/plugins.zsh"
    "$REPO_ROOT/config/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
    "$REPO_ROOT/config/alacritty/themes/vesper.toml" "$HOME/.config/alacritty/themes/vesper.toml"
    "$REPO_ROOT/config/atuin/config.toml" "$HOME/.config/atuin/config.toml"
    "$REPO_ROOT/config/mise/config.toml" "$HOME/.config/mise/config.toml"
    "$REPO_ROOT/config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
    "$REPO_ROOT/config/tmux/status.conf" "$HOME/.config/tmux/status.conf"
    "$REPO_ROOT/config/sesh/sesh.toml" "$HOME/.config/sesh/sesh.toml"
    "$REPO_ROOT/config/sesh/scripts/control-panel.sh" "$HOME/.config/sesh/scripts/control-panel.sh"
    "$REPO_ROOT/config/starship.toml" "$HOME/.config/starship.toml"
    "$REPO_ROOT/config/bat/config" "$HOME/.config/bat/config"
    "$REPO_ROOT/config/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
    "$REPO_ROOT/config/fontconfig/fonts.conf" "$HOME/.config/fontconfig/fonts.conf"
    "$REPO_ROOT/config/swaync/config.json" "$HOME/.config/swaync/config.json"
    "$REPO_ROOT/config/swaync/style.css" "$HOME/.config/swaync/style.css"
    "$REPO_ROOT/config/tensaku/config.toml" "$HOME/.config/tensaku/config.toml"
    "$REPO_ROOT/config/gtklock/config.ini" "$HOME/.config/gtklock/config.ini"
    "$REPO_ROOT/config/gtklock/layout.ui" "$HOME/.config/gtklock/layout.ui"
    "$REPO_ROOT/config/gtklock/style.css" "$HOME/.config/gtklock/style.css"
    "$REPO_ROOT/config/niri/config.kdl" "$HOME/.config/niri/config.kdl"
    "$REPO_ROOT/config/systemd/user/swaybg.service" "$HOME/.config/systemd/user/swaybg.service"
    "$REPO_ROOT/config/systemd/user/swayidle.service" "$HOME/.config/systemd/user/swayidle.service"
    "$REPO_ROOT/config/systemd/user/lxqt-policykit-agent.service" "$HOME/.config/systemd/user/lxqt-policykit-agent.service"
    "$REPO_ROOT/config/systemd/user/quickshell.service" "$HOME/.config/systemd/user/quickshell.service"
    "$REPO_ROOT/bin/fedora-update" "$HOME/.local/bin/fedora-update"
    "$REPO_ROOT/bin/fedora-sync" "$HOME/.local/bin/fedora-sync"
    "$REPO_ROOT/bin/lock-screen" "$HOME/.local/bin/lock-screen"
    "$REPO_ROOT/bin/preview-lock-screen" "$HOME/.local/bin/preview-lock-screen"
    "$REPO_ROOT/bin/session-wallpaper" "$HOME/.local/bin/session-wallpaper"
    "$REPO_ROOT/bin/wallpaper-picker" "$HOME/.local/bin/wallpaper-picker"
    "$REPO_ROOT/bin/take-screenshot" "$HOME/.local/bin/take-screenshot"
    "$REPO_ROOT/bin/fuzzel-toggle" "$HOME/.local/bin/fuzzel-toggle"
    "$REPO_ROOT/bin/control-panel" "$HOME/.local/bin/control-panel"
    "$REPO_ROOT/bin/island-power" "$HOME/.local/bin/island-power"
    "$REPO_ROOT/config/pi/extensions/statusline.ts" "$HOME/.pi/agent/extensions/statusline.ts"
    "$REPO_ROOT/config/codex/dotfiles.config.toml" "$HOME/.codex/dotfiles.config.toml"
    "$REPO_ROOT/config/opencode/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"
    "$REPO_ROOT/config/opencode/tui.jsonc" "$HOME/.config/opencode/tui.jsonc"
  )
  local index
  for ((index = 0; index < ${#config_links[@]}; index += 2)); do
    source="${config_links[index]}"
    target="${config_links[index + 1]}"
    show_config_link_status "$source" "$target"
  done
}
