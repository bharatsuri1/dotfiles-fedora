readonly SDDM_THEME_NAME="vesper"
readonly SDDM_THEME_SOURCE="$REPO_ROOT/config/sddm/themes/$SDDM_THEME_NAME"
readonly SDDM_THEME_TARGET="/usr/share/sddm/themes/$SDDM_THEME_NAME"
readonly SDDM_CONFIG_SOURCE="$REPO_ROOT/config/sddm/10-dotfiles-fedora.conf"
readonly SDDM_CONFIG_TARGET="/etc/sddm.conf.d/10-dotfiles-fedora.conf"
readonly SDDM_AVATAR_SOURCE="$REPO_ROOT/assets/user-pictures/user_compress.jpeg"
readonly SDDM_AVATAR_TARGET="/usr/share/sddm/faces/$(id -un).face.icon"
readonly SDDM_THEME_AVATAR_TARGET="$SDDM_THEME_TARGET/avatar.jpg"
readonly SDDM_BACKGROUND_TARGET="$SDDM_THEME_TARGET/background.png"
readonly SDDM_PACKAGES=(sddm sddm-wayland-generic)
# shellcheck source=/dev/null
source "$REPO_ROOT/lib/wallpaper.sh"

install_sddm_file() {
  local mode="$1"
  local source="$2"
  local target="$3"

  if [[ -r "$target" ]] && cmp -s "$source" "$target"; then
    log "$target already managed"
  else
    run sudo install -D -m "$mode" "$source" "$target"
  fi
}

validate_sddm() {
  [[ -r "$NIRI_SESSION_FILE" ]] || die "missing niri session: $NIRI_SESSION_FILE"
  grep -Eq '^Exec=niri-session$' "$NIRI_SESSION_FILE" ||
    die "$NIRI_SESSION_FILE does not launch niri-session"
  [[ -r "$SDDM_CONFIG_TARGET" ]] || die "missing managed SDDM configuration: $SDDM_CONFIG_TARGET"
  [[ -r "$SDDM_THEME_TARGET/Main.qml" ]] || die "missing managed SDDM theme"
  [[ -r "$SDDM_AVATAR_TARGET" ]] || die "missing managed SDDM user picture"
  log 'validated SDDM theme, user picture, and niri session'
}

install_sddm() {
  if ! $DRY_RUN && ! font_family_installed "$UI_FONT_FAMILY"; then
    die "$UI_FONT_FAMILY is missing; run the fonts phase before sddm"
  fi

  local -a missing=()
  local package
  for package in "${SDDM_PACKAGES[@]}"; do
    package_installed "$package" || missing+=("$package")
  done
  if ((${#missing[@]} == 0)); then
    log 'SDDM packages already installed'
  else
    log "installing SDDM packages: ${missing[*]}"
    local -a command=(sudo dnf install)
    $ASSUME_YES && command+=(--assumeyes)
    run "${command[@]}" "${missing[@]}"
  fi
  install_sddm_file 0644 "$SDDM_CONFIG_SOURCE" "$SDDM_CONFIG_TARGET"

  local source relative_path
  while IFS= read -r -d '' source; do
    relative_path="${source#"$SDDM_THEME_SOURCE"/}"
    install_sddm_file 0644 "$source" "$SDDM_THEME_TARGET/$relative_path"
  done < <(find "$SDDM_THEME_SOURCE" -type f -print0)
  local wallpaper_source="$REPO_ROOT/assets/wallpapers/wallhaven-836yl2_2560x1600.png"
  if ! $DRY_RUN; then
    sync_packaged_wallpapers "$REPO_ROOT/assets/wallpapers"
    initialize_wallpapers
    wallpaper_source="$(current_wallpaper)"
  fi
  install_sddm_file 0644 "$wallpaper_source" "$SDDM_BACKGROUND_TARGET"
  install_sddm_file 0644 "$SDDM_AVATAR_SOURCE" "$SDDM_AVATAR_TARGET"
  install_sddm_file 0644 "$SDDM_AVATAR_SOURCE" "$SDDM_THEME_AVATAR_TARGET"

  if $DRY_RUN; then
    log 'SDDM validation will run after installation'
  else
    validate_sddm
  fi
  log 'SDDM is installed and configured but has not been enabled'
}

enable_sddm() {
  $DRY_RUN || validate_sddm

  local display_manager_fragment
  display_manager_fragment="$(systemctl show display-manager.service -p FragmentPath --value 2>/dev/null || true)"
  if [[ -n "$display_manager_fragment" && "$(basename -- "$display_manager_fragment")" != sddm.service ]]; then
    die "another display manager is enabled: $display_manager_fragment"
  fi

  if ! confirm 'Is a second TTY open and logged in as your tested recovery path?'; then
    log 'SDDM activation cancelled'
    return
  fi
  if ! confirm 'Enable SDDM and graphical.target for the next boot?'; then
    log 'SDDM activation cancelled'
    return
  fi

  run sudo systemctl enable sddm.service
  run sudo systemctl set-default graphical.target
  log 'SDDM will start on the next boot; the current session was not stopped'
  log 'Recovery: Ctrl+Alt+F3, log in, then run sudo systemctl set-default multi-user.target'
}
