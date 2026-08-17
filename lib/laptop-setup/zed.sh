readonly ZED_FLATPAK_ID="dev.zed.Zed"
readonly ZED_FLATPAK_CONFIG="$HOME/.var/app/${ZED_FLATPAK_ID}/config/zed"
readonly ZED_SETTINGS_SOURCE="$REPO_ROOT/config/zed/settings.json"
readonly ZED_SETTINGS_TARGET="$ZED_FLATPAK_CONFIG/settings.json"
readonly ZED_THEME_SOURCE="$REPO_ROOT/config/zed/themes/vesper.json"
readonly ZED_THEME_TARGET="$ZED_FLATPAK_CONFIG/themes/vesper.json"
readonly ZED_KEYMAP_SOURCE="$REPO_ROOT/config/zed/keymap.json"
readonly ZED_KEYMAP_TARGET="$ZED_FLATPAK_CONFIG/keymap.json"

# Reviewed allowlist (empty for now). Rationale for future entries lives in docs/zed.md.
readonly ZED_EXTENSIONS=()

zed_app_installed() {
  command -v flatpak >/dev/null 2>&1 && flatpak info "$ZED_FLATPAK_ID" >/dev/null 2>&1
}

link_zed_config() {
  link_config "$ZED_SETTINGS_SOURCE" "$ZED_SETTINGS_TARGET"
  link_config "$ZED_THEME_SOURCE" "$ZED_THEME_TARGET"
  link_config "$ZED_KEYMAP_SOURCE" "$ZED_KEYMAP_TARGET"
}

install_zed() {
  if ! zed_app_installed && ! $DRY_RUN; then
    die "Zed Flatpak ($ZED_FLATPAK_ID) is missing; run the flatpaks phase first"
  fi
  if ! zed_app_installed && $DRY_RUN; then
    log "Zed Flatpak ($ZED_FLATPAK_ID) is not installed; would still link managed configuration"
  fi

  link_zed_config

  local ext
  for ext in "${ZED_EXTENSIONS[@]}"; do
    log "Zed extension allowlist entry $ext is not installed automatically yet"
  done
}

show_zed_status() {
  printf 'Zed:\n'
  if zed_app_installed; then
    printf '  [ok]      %s\n' "$ZED_FLATPAK_ID"
  else
    printf '  [missing] %s\n' "$ZED_FLATPAK_ID"
  fi

  local target source resolved
  for target in "$ZED_SETTINGS_TARGET" "$ZED_THEME_TARGET" "$ZED_KEYMAP_TARGET"; do
    source=""
    case "$target" in
      "$ZED_SETTINGS_TARGET") source="$ZED_SETTINGS_SOURCE" ;;
      "$ZED_THEME_TARGET") source="$ZED_THEME_SOURCE" ;;
      "$ZED_KEYMAP_TARGET") source="$ZED_KEYMAP_SOURCE" ;;
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
  if grep -Eq "^alias zed=" "$REPO_ROOT/config/zsh/aliases.zsh" 2>/dev/null; then
    printf '  [alias]   zed -> flatpak run %s\n' "$ZED_FLATPAK_ID"
  else
    printf '  [missing] zed alias in managed zsh aliases\n'
  fi

  if ((${#ZED_EXTENSIONS[@]})); then
    local ext
    for ext in "${ZED_EXTENSIONS[@]}"; do
      printf '  [allow]   extension %s (install path not wired)\n' "$ext"
    done
  else
    printf '  [ok]      extension allowlist empty\n'
  fi
}
