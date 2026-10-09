ensure_backup_dir() {
  if [[ -z "$BACKUP_DIR" ]]; then
    BACKUP_DIR="$BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)"
    run mkdir -p "$BACKUP_DIR"
  fi
}

link_config() {
  local source="$1"
  local target="$2"

  if [[ -L "$target" && "$(readlink -f -- "$target" 2>/dev/null || true)" == "$(readlink -f -- "$source" 2>/dev/null || true)" ]]; then
    report linked "$target"
    return
  fi

  run mkdir -p "$(dirname -- "$target")"
  if [[ -e "$target" || -L "$target" ]]; then
    ensure_backup_dir
    local backup="$BACKUP_DIR/${target#"$HOME"/}"
    run mkdir -p "$(dirname -- "$backup")"
    run mv -- "$target" "$backup"
    report backup "$target -> $backup"
  fi
  run ln -s "$source" "$target"
  report linked "$target"
}

# The opencode TUI plugin at ~/.config/opencode/herdr-tui-session.js is
# herdr's own integration artifact: herdr installs it and overwrites it on
# integration updates (see its "managed by herdr" header). Earlier config
# phases symlinked it into this repo, which no longer ships the file,
# leaving a dangling link in herdr's way. Remove the link only when it
# points into this checkout; never touch a real file herdr has written.
remove_managed_herdr_plugin_link() {
  local target="$HOME/.config/opencode/herdr-tui-session.js"
  local link_target=''
  if [[ -L "$target" ]]; then
    link_target="$(readlink -- "$target")"
  fi
  if [[ "$link_target" == "$REPO_ROOT"/* ]]; then
    run rm -- "$target"
    log "removed repo-managed link $target; herdr owns its opencode integration"
  fi
}

reload_tmux_config() {
  local config="$HOME/.config/tmux/tmux.conf"

  if ! command -v tmux >/dev/null 2>&1; then
    log 'tmux is unavailable; skipping configuration reload'
    return
  fi

  if ! tmux list-sessions >/dev/null 2>&1; then
    log 'tmux server is not running; configuration will load on next start'
    return
  fi

  if $DRY_RUN; then
    run tmux source-file "$config"
  elif tmux source-file "$config"; then
    log 'reloaded tmux configuration'
  elif ! tmux list-sessions >/dev/null 2>&1; then
    log 'tmux server stopped before configuration could be reloaded'
  else
    die "failed to reload tmux configuration from $config"
  fi
}

validate_niri_config() {
  local config="$REPO_ROOT/config/niri/config.kdl"

  if ! command -v niri >/dev/null 2>&1; then
    log 'niri is unavailable; skipping managed configuration validation'
    return
  fi

  niri validate --config "$config"
  log 'validated managed niri configuration'
}

attach_niri_service() {
  local service="$1"
  local wants="$HOME/.config/systemd/user/niri.service.wants/$service"

  if [[ -L "$wants" ]]; then
    log "$service already attached to the niri session"
  else
    run systemctl --user add-wants niri.service "$service"
  fi
}

configure_niri_services() {
  link_config \
    "$REPO_ROOT/config/systemd/user/swaybg.service" \
    "$HOME/.config/systemd/user/swaybg.service"
  link_config \
    "$REPO_ROOT/config/systemd/user/swayidle.service" \
    "$HOME/.config/systemd/user/swayidle.service"
  link_config \
    "$REPO_ROOT/config/systemd/user/lxqt-policykit-agent.service" \
    "$HOME/.config/systemd/user/lxqt-policykit-agent.service"
  link_config \
    "$REPO_ROOT/config/systemd/user/quickshell.service" \
    "$HOME/.config/systemd/user/quickshell.service"
  link_config \
    "$REPO_ROOT/config/systemd/user/voxtype.service" \
    "$HOME/.config/systemd/user/voxtype.service"
  run systemctl --user daemon-reload

  local service
  for service in swaync.service swaybg.service swayidle.service lxqt-policykit-agent.service quickshell.service; do
    if ! $DRY_RUN && ! systemctl --user cat "$service" >/dev/null 2>&1; then
      die "$service is unavailable; run the desktop-foundation phase first"
    fi
    attach_niri_service "$service"
  done
  if $DRY_RUN || systemctl --user cat voxtype.service >/dev/null 2>&1; then
    attach_niri_service voxtype.service
  else
    log 'voxtype.service is unavailable; run the voxtype phase to install the daemon'
  fi
  if $DRY_RUN || systemctl --user cat vicinae.service >/dev/null 2>&1; then
    attach_niri_service vicinae.service
  else
    log 'vicinae.service is unavailable; run the vicinae phase to install the daemon'
  fi
  if $DRY_RUN || systemctl --user is-active graphical-session.target >/dev/null 2>&1; then
    run systemctl --user restart swaybg.service
  else
    log 'graphical session is inactive; swaybg will start with the next niri session'
  fi
  if $DRY_RUN || systemctl --user is-active graphical-session.target >/dev/null 2>&1; then
    run systemctl --user restart swaync.service
  else
    log 'graphical session is inactive; swaync will start with the next niri session'
  fi
  run systemctl --user try-restart swayidle.service
  if $DRY_RUN || systemctl --user is-active graphical-session.target >/dev/null 2>&1; then
    run systemctl --user restart quickshell.service
  else
    log 'graphical session is inactive; quickshell will start with the next niri session'
  fi
  run systemctl --user try-restart voxtype.service
  run systemctl --user try-restart vicinae.service
}

repo_hook_path() {
  [[ -e "$REPO_ROOT/.git" ]] || return 1
  local hook_path
  hook_path="$(git -C "$REPO_ROOT" rev-parse --git-path hooks/pre-commit)" || return 1
  if [[ "$hook_path" != /* ]]; then
    hook_path="$REPO_ROOT/$hook_path"
  fi
  printf '%s\n' "$hook_path"
}

install_repo_hook() {
  local hook_path
  if ! hook_path="$(repo_hook_path)"; then
    report local 'skipping pre-commit hook; this checkout has no Git metadata'
    return
  fi
  link_config "$REPO_ROOT/hooks/pre-commit" "$hook_path"
}

install_config() {
  section Config
  if ! $DRY_RUN; then
    sync_packaged_wallpapers "$REPO_ROOT/assets/wallpapers"
    initialize_wallpapers
  fi
  link_config "$REPO_ROOT/bin/fedora-update" "$HOME/.local/bin/fedora-update"
  link_config "$REPO_ROOT/bin/fedora-sync" "$HOME/.local/bin/fedora-sync"
  link_config "$REPO_ROOT/bin/lock-screen" "$HOME/.local/bin/lock-screen"
  link_config "$REPO_ROOT/bin/preview-lock-screen" "$HOME/.local/bin/preview-lock-screen"
  link_config "$REPO_ROOT/bin/session-wallpaper" "$HOME/.local/bin/session-wallpaper"
  link_config "$REPO_ROOT/bin/wallpaper-picker" "$HOME/.local/bin/wallpaper-picker"
  link_config "$REPO_ROOT/bin/take-screenshot" "$HOME/.local/bin/take-screenshot"
  link_config "$REPO_ROOT/bin/fuzzel-toggle" "$HOME/.local/bin/fuzzel-toggle"
  link_config "$REPO_ROOT/bin/control-panel" "$HOME/.local/bin/control-panel"
  link_config "$REPO_ROOT/bin/island-power" "$HOME/.local/bin/island-power"
  link_config "$REPO_ROOT/config/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
  link_config "$REPO_ROOT/config/alacritty/themes/vesper.toml" "$HOME/.config/alacritty/themes/vesper.toml"
  link_config "$REPO_ROOT/config/zsh/zshenv" "$HOME/.zshenv"
  link_config "$REPO_ROOT/config/zsh/zshenv" "$HOME/.config/zsh/.zshenv"
  link_config "$REPO_ROOT/config/zsh/zshrc" "$HOME/.config/zsh/.zshrc"
  local module
  for module in aliases completion cursor integrations options plugins; do
    link_config "$REPO_ROOT/config/zsh/$module.zsh" "$HOME/.config/zsh/$module.zsh"
  done
  link_config "$REPO_ROOT/config/atuin/config.toml" "$HOME/.config/atuin/config.toml"
  link_config "$REPO_ROOT/config/mise/config.toml" "$HOME/.config/mise/config.toml"
  link_config "$REPO_ROOT/config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
  link_config "$REPO_ROOT/config/tmux/status.conf" "$HOME/.config/tmux/status.conf"
  reload_tmux_config
  link_config "$REPO_ROOT/config/sesh/sesh.toml" "$HOME/.config/sesh/sesh.toml"
  link_config "$REPO_ROOT/config/sesh/scripts/control-panel.sh" "$HOME/.config/sesh/scripts/control-panel.sh"
  install_pi_settings
  link_config "$REPO_ROOT/config/pi/extensions/statusline.ts" "$HOME/.pi/agent/extensions/statusline.ts"
  link_config "$REPO_ROOT/config/codex/dotfiles.config.toml" "$HOME/.codex/dotfiles.config.toml"
  link_config "$REPO_ROOT/config/opencode/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"
  link_config "$REPO_ROOT/config/opencode/tui.jsonc" "$HOME/.config/opencode/tui.jsonc"
  remove_managed_herdr_plugin_link
  link_config "$REPO_ROOT/config/starship.toml" "$HOME/.config/starship.toml"
  link_config "$REPO_ROOT/config/bat/config" "$HOME/.config/bat/config"
  link_config "$REPO_ROOT/config/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
  link_config "$REPO_ROOT/config/herdr/config.toml" "$HOME/.config/herdr/config.toml"
  link_config "$REPO_ROOT/config/voxtype/config.toml" "$HOME/.config/voxtype/config.toml"
  link_config "$REPO_ROOT/config/vicinae/settings.json" "$HOME/.config/vicinae/settings.json"
  link_zed_config
  link_vscode_config
  link_nvim_config
  link_config "$REPO_ROOT/config/swaync/config.json" "$HOME/.config/swaync/config.json"
  link_config "$REPO_ROOT/config/swaync/style.css" "$HOME/.config/swaync/style.css"
  link_config "$REPO_ROOT/config/tensaku/config.toml" "$HOME/.config/tensaku/config.toml"
  link_config "$REPO_ROOT/config/fontconfig/fonts.conf" "$HOME/.config/fontconfig/fonts.conf"
  link_config "$REPO_ROOT/config/quickshell" "$HOME/.config/quickshell"
  link_config "$REPO_ROOT/config/gtklock/config.ini" "$HOME/.config/gtklock/config.ini"
  link_config "$REPO_ROOT/config/gtklock/layout.ui" "$HOME/.config/gtklock/layout.ui"
  link_config "$REPO_ROOT/config/gtklock/style.css" "$HOME/.config/gtklock/style.css"
  validate_niri_config
  link_config "$REPO_ROOT/config/niri/config.kdl" "$HOME/.config/niri/config.kdl"
  configure_niri_services
  install_repo_hook
}

pi_node_path() {
  if command -v node >/dev/null 2>&1; then
    command -v node
  elif command -v mise >/dev/null 2>&1; then
    mise which node@latest 2>/dev/null
  else
    return 1
  fi
}

install_pi_settings() {
  local node_bin
  node_bin="$(pi_node_path || true)"
  if [[ -z "$node_bin" ]]; then
    if $DRY_RUN; then
      node_bin=node
    else
      die 'Node is missing; run the setup runtime phase before deploying Pi settings'
    fi
  fi
  run "$node_bin" "$REPO_ROOT/lib/pi-settings.mjs" deploy \
    "$REPO_ROOT/config/pi/settings.json" "$HOME/.pi/agent/settings.json" "$BACKUP_ROOT"
}

show_pi_settings_status() {
  local target="$HOME/.pi/agent/settings.json"
  local node_bin
  if [[ -L "$target" ]]; then
    report wrong "$target (legacy symlink; run the config phase)"
  elif [[ ! -e "$target" ]]; then
    report missing "$target"
  else
    node_bin="$(pi_node_path || true)"
    if [[ -n "$node_bin" ]] && "$node_bin" "$REPO_ROOT/lib/pi-settings.mjs" check \
      "$REPO_ROOT/config/pi/settings.json" "$target" >/dev/null 2>&1; then
      report ok "$target (managed preferences, local runtime state)"
    else
      report local "$target (preferences unverified or changed; run the config phase)"
    fi
  fi
}
