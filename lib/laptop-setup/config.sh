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

install_config() {
  link_config "$REPO_ROOT/config/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
  link_config "$REPO_ROOT/config/alacritty/themes/vesper.toml" "$HOME/.config/alacritty/themes/vesper.toml"
  link_config "$REPO_ROOT/config/zsh/zshenv" "$HOME/.zshenv"
  link_config "$REPO_ROOT/config/zsh/zshrc" "$HOME/.config/zsh/.zshrc"
  local module
  for module in aliases completion integrations options plugins; do
    link_config "$REPO_ROOT/config/zsh/$module.zsh" "$HOME/.config/zsh/$module.zsh"
  done
  link_config "$REPO_ROOT/config/atuin/config.toml" "$HOME/.config/atuin/config.toml"
  link_config "$REPO_ROOT/config/starship.toml" "$HOME/.config/starship.toml"
  link_config "$REPO_ROOT/config/bat/config" "$HOME/.config/bat/config"
  link_config "$REPO_ROOT/config/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
}
