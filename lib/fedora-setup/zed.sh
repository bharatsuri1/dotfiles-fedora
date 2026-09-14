# shellcheck shell=bash
readonly ZED_VERSION="1.19.2"
readonly ZED_APP_ROOT="$HOME/.local/zed.app"
readonly ZED_BINARY="$ZED_APP_ROOT/bin/zed"
readonly ZED_BIN_LINK="$HOME/.local/bin/zed"
readonly ZED_DESKTOP_FILE="$HOME/.local/share/applications/dev.zed.Zed.desktop"
readonly ZED_MANAGED_MARKER="$STATE_DIR/zed/managed-install"
readonly ZED_CONFIG_ROOT="$HOME/.config/zed"
readonly ZED_SETTINGS_SOURCE="$REPO_ROOT/config/zed/settings.json"
readonly ZED_SETTINGS_TARGET="$ZED_CONFIG_ROOT/settings.json"
readonly ZED_THEME_SOURCE="$REPO_ROOT/config/zed/themes/vesper.json"
readonly ZED_THEME_TARGET="$ZED_CONFIG_ROOT/themes/vesper.json"
readonly ZED_KEYMAP_SOURCE="$REPO_ROOT/config/zed/keymap.json"
readonly ZED_KEYMAP_TARGET="$ZED_CONFIG_ROOT/keymap.json"

zed_asset_name() {
  case "$(uname -m)" in
    x86_64) printf '%s\n' 'zed-linux-x86_64.tar.gz' ;;
    aarch64) printf '%s\n' 'zed-linux-aarch64.tar.gz' ;;
    *) die "Zed official archives support x86_64 and aarch64 only (found $(uname -m))" ;;
  esac
}

zed_expected_sha256() {
  case "$(uname -m)" in
    x86_64) printf '%s\n' 'c5acff2e52ac3c64890cce85250734cf7279c1de56d5926e4f4e1d4cf676359c' ;;
    aarch64) printf '%s\n' '6a7b9dac4c17b3901fda30d07e35f85f7eeb06bb96e1a348ff012aa2abed8af9' ;;
    *) die "Zed official archives support x86_64 and aarch64 only (found $(uname -m))" ;;
  esac
}

zed_archive_url() {
  local asset_name
  asset_name="$(zed_asset_name)"
  printf 'https://github.com/zed-industries/zed/releases/download/v%s/%s\n' "$ZED_VERSION" "$asset_name"
}

zed_managed_install() {
  [[ -L "$ZED_MANAGED_MARKER" ]] &&
    [[ "$(readlink -f -- "$ZED_MANAGED_MARKER" 2>/dev/null || true)" == "$ZED_APP_ROOT" ]] &&
    [[ -x "$ZED_BINARY" ]]
}

zed_path_is_managed() {
  local path="$1"
  [[ -L "$path" ]] &&
    [[ "$(readlink -f -- "$path" 2>/dev/null || true)" == "$ZED_BINARY" ]]
}

zed_desktop_is_managed() {
  [[ -f "$ZED_DESKTOP_FILE" ]] && grep -Fxq 'X-Dotfiles-Fedora-Managed=true' "$ZED_DESKTOP_FILE"
}

assert_zed_install_is_safe() {
  if [[ -e "$ZED_APP_ROOT" || -L "$ZED_APP_ROOT" ]] && ! zed_managed_install; then
    die "refusing to replace unrecognized Zed installation at $ZED_APP_ROOT"
  fi
  if [[ -e "$ZED_BIN_LINK" || -L "$ZED_BIN_LINK" ]] && ! zed_path_is_managed "$ZED_BIN_LINK"; then
    die "refusing to replace unrecognized zed executable at $ZED_BIN_LINK"
  fi
  if [[ -e "$ZED_DESKTOP_FILE" || -L "$ZED_DESKTOP_FILE" ]] && ! zed_desktop_is_managed; then
    die "refusing to replace unrecognized Zed desktop entry at $ZED_DESKTOP_FILE"
  fi
}

link_zed_config() {
  link_config "$ZED_SETTINGS_SOURCE" "$ZED_SETTINGS_TARGET"
  link_config "$ZED_THEME_SOURCE" "$ZED_THEME_TARGET"
  link_config "$ZED_KEYMAP_SOURCE" "$ZED_KEYMAP_TARGET"
}

install_zed_desktop_entry() {
  local source="$ZED_APP_ROOT/share/applications/dev.zed.Zed.desktop"
  local icon="$ZED_APP_ROOT/share/icons/hicolor/512x512/apps/zed.png"
  [[ -f "$source" ]] || die "Zed archive is missing desktop entry: $source"
  [[ -f "$icon" ]] || die "Zed archive is missing icon: $icon"

  local desktop_tmp
  desktop_tmp="$(mktemp)"
  sed \
    -e "s|^Exec=zed|Exec=$ZED_BINARY|" \
    -e "s|^Icon=zed$|Icon=$icon|" \
    -e '/^\[Desktop Entry\]/aX-Dotfiles-Fedora-Managed=true' \
    "$source" >"$desktop_tmp"
  run install -Dm0644 "$desktop_tmp" "$ZED_DESKTOP_FILE"
  rm -f -- "$desktop_tmp"
  command -v update-desktop-database >/dev/null 2>&1 &&
    run update-desktop-database "$(dirname -- "$ZED_DESKTOP_FILE")"
}

install_zed_launchers() {
  assert_zed_install_is_safe
  run mkdir -p "$(dirname -- "$ZED_BIN_LINK")"
  if ! zed_path_is_managed "$ZED_BIN_LINK"; then
    run ln -s "$ZED_BINARY" "$ZED_BIN_LINK"
  fi
  install_zed_desktop_entry
}

install_zed_archive() {
  local archive_url expected_sha256 download staging
  archive_url="$(zed_archive_url)"
  expected_sha256="$(zed_expected_sha256)"

  if $DRY_RUN; then
    log "would download, verify, stage, and atomically install Zed $ZED_VERSION for $(uname -m)"
    printf '+ curl -fsSLo <temporary-zed-archive> %q\n' "$archive_url"
    printf '+ verify SHA-256 %s for <temporary-zed-archive>\n' "$expected_sha256"
    printf '+ tar -xzf <temporary-zed-archive> -C <temporary-zed-stage>\n'
    printf '+ mv <temporary-zed-stage>/zed.app %q\n' "$ZED_APP_ROOT"
    return
  fi

  download="$(mktemp)"
  staging="$(mktemp -d)"
  curl -fsSLo "$download" "$archive_url"
  if ! printf '%s  %s\n' "$expected_sha256" "$download" | sha256sum --check --status; then
    die "Zed $ZED_VERSION failed SHA-256 verification; downloaded archive retained at $download"
  fi
  tar -xzf "$download" -C "$staging"
  [[ -x "$staging/zed.app/bin/zed" ]] || die "Zed $ZED_VERSION archive has an unexpected layout; staging retained at $staging"
  [[ ! -e "$ZED_APP_ROOT" && ! -L "$ZED_APP_ROOT" ]] || die "Zed destination appeared during install: $ZED_APP_ROOT"
  run mv -- "$staging/zed.app" "$ZED_APP_ROOT"
  run mkdir -p "$(dirname -- "$ZED_MANAGED_MARKER")"
  run ln -s "$ZED_APP_ROOT" "$ZED_MANAGED_MARKER"
  run rm -f -- "$download"
  run rmdir -- "$staging"
}

install_zed() {
  assert_zed_install_is_safe
  if zed_managed_install; then
    log "managed Zed already installed at $ZED_APP_ROOT; preserving its current version and upstream updates"
  else
    install_zed_archive
    if $DRY_RUN; then
      log 'would create the managed executable link and desktop entry after archive staging'
      link_zed_config
      return
    fi
  fi
  install_zed_launchers
  link_zed_config
}

show_zed_status() {
  printf 'Zed:\n'
  if zed_managed_install; then
    printf '  [ok]      managed native install (%s)\n' "$ZED_BINARY"
  elif [[ -e "$ZED_APP_ROOT" || -L "$ZED_APP_ROOT" ]]; then
    printf '  [local]   unrecognized install at %s\n' "$ZED_APP_ROOT"
  else
    printf '  [missing] %s\n' "$ZED_APP_ROOT"
  fi
  zed_path_is_managed "$ZED_BIN_LINK" &&
    printf '  [linked]  %s\n' "$ZED_BIN_LINK" ||
    printf '  [missing/wrong] %s\n' "$ZED_BIN_LINK"
  zed_desktop_is_managed &&
    printf '  [managed] %s\n' "$ZED_DESKTOP_FILE" ||
    printf '  [missing/wrong] %s\n' "$ZED_DESKTOP_FILE"
}
