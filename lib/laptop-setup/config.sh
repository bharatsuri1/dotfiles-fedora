ensure_backup_dir() {
  if [[ -z "$BACKUP_DIR" ]]; then
    BACKUP_DIR="$BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)"
    run mkdir -p "$BACKUP_DIR"
  fi
}

link_config() {
  local source="$1"
  local target="$2"

  if [[ -L "$target" && "$(readlink -f -- "$target")" == "$(readlink -f -- "$source")" ]]; then
    log "$target already linked"
    return
  fi

  run mkdir -p "$(dirname -- "$target")"
  if [[ -e "$target" || -L "$target" ]]; then
    ensure_backup_dir
    local backup="$BACKUP_DIR/${target#"$HOME"/}"
    run mkdir -p "$(dirname -- "$backup")"
    run mv -- "$target" "$backup"
    log "backed up $target to $backup"
  fi
  run ln -s "$source" "$target"
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
  run systemctl --user daemon-reload

  local service
  for service in mako.service swaybg.service swayidle.service lxqt-policykit-agent.service quickshell.service; do
    if ! $DRY_RUN && ! systemctl --user cat "$service" >/dev/null 2>&1; then
      die "$service is unavailable; run the desktop-foundation phase first"
    fi
    attach_niri_service "$service"
  done
  if $DRY_RUN || systemctl --user is-active graphical-session.target >/dev/null 2>&1; then
    run systemctl --user restart swaybg.service
  else
    log 'graphical session is inactive; swaybg will start with the next niri session'
  fi
  run systemctl --user try-restart swayidle.service
  if $DRY_RUN || systemctl --user is-active graphical-session.target >/dev/null 2>&1; then
    run systemctl --user restart quickshell.service
  else
    log 'graphical session is inactive; quickshell will start with the next niri session'
  fi
}

install_config() {
  link_config "$REPO_ROOT/bin/lock-screen" "$HOME/.local/bin/lock-screen"
  link_config "$REPO_ROOT/bin/session-wallpaper" "$HOME/.local/bin/session-wallpaper"
  link_config "$REPO_ROOT/config/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
  link_config "$REPO_ROOT/config/alacritty/themes/vesper.toml" "$HOME/.config/alacritty/themes/vesper.toml"
  link_config "$REPO_ROOT/config/zsh/zshenv" "$HOME/.zshenv"
  link_config "$REPO_ROOT/config/zsh/zshrc" "$HOME/.config/zsh/.zshrc"
  local module
  for module in aliases completion integrations options plugins; do
    link_config "$REPO_ROOT/config/zsh/$module.zsh" "$HOME/.config/zsh/$module.zsh"
  done
  link_config "$REPO_ROOT/config/atuin/config.toml" "$HOME/.config/atuin/config.toml"
  link_config "$REPO_ROOT/config/mise/config.toml" "$HOME/.config/mise/config.toml"
  link_config "$REPO_ROOT/config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
  link_config "$REPO_ROOT/config/tmux/status.conf" "$HOME/.config/tmux/status.conf"
  reload_tmux_config
  link_config "$REPO_ROOT/config/sesh/sesh.toml" "$HOME/.config/sesh/sesh.toml"
  link_config "$REPO_ROOT/config/pi/settings.json" "$HOME/.pi/agent/settings.json"
  link_config "$REPO_ROOT/config/pi/extensions/statusline.ts" "$HOME/.pi/agent/extensions/statusline.ts"
  link_config "$REPO_ROOT/config/codex/dotfiles.config.toml" "$HOME/.codex/dotfiles.config.toml"
  link_config "$REPO_ROOT/config/starship.toml" "$HOME/.config/starship.toml"
  link_config "$REPO_ROOT/config/bat/config" "$HOME/.config/bat/config"
  link_config "$REPO_ROOT/config/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
  link_config "$REPO_ROOT/config/herdr/config.toml" "$HOME/.config/herdr/config.toml"
  link_config "$REPO_ROOT/config/mako/config" "$HOME/.config/mako/config"
  link_config "$REPO_ROOT/config/quickshell" "$HOME/.config/quickshell"
  link_config "$REPO_ROOT/config/gtklock/config.ini" "$HOME/.config/gtklock/config.ini"
  link_config "$REPO_ROOT/config/gtklock/style.css" "$HOME/.config/gtklock/style.css"
  validate_niri_config
  link_config "$REPO_ROOT/config/niri/config.kdl" "$HOME/.config/niri/config.kdl"
  configure_niri_services
}
