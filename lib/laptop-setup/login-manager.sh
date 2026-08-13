readonly NIRI_SESSION_FILE="/usr/share/wayland-sessions/niri.desktop"
readonly LOGIN_MANAGER_SERVICE="greetd.service"

verify_niri_login_session() {
  [[ -r "$NIRI_SESSION_FILE" ]] ||
    die "niri session entry is missing: $NIRI_SESSION_FILE"
  grep -Eq '^Exec=niri-session$' "$NIRI_SESSION_FILE" ||
    die "$NIRI_SESSION_FILE must launch niri-session"
}

install_login_manager() {
  verify_niri_login_session
  enable_copr avengemedia/danklinux

  local original_boot_target
  original_boot_target="$(systemctl get-default 2>/dev/null || true)"

  local -a command=(sudo dnf install)
  $ASSUME_YES && command+=(--assumeyes)
  run "${command[@]}" greetd dms-greeter

  if $DRY_RUN; then
    run dms greeter sync --yes
  else
    command -v dms >/dev/null 2>&1 || die 'DMS is missing; run the dms phase first'
    dms greeter sync --yes

    local current_boot_target
    current_boot_target="$(systemctl get-default 2>/dev/null || true)"
    if [[ -n "$original_boot_target" && "$current_boot_target" != "$original_boot_target" ]]; then
      log "restoring boot target changed by DMS Greeter sync to $original_boot_target"
      sudo systemctl set-default "$original_boot_target"
    fi

    if [[ " $(id -nG) " != *" greeter "* ]]; then
      log 'greeter group membership was added but is not active in this login session'
      log 'log out and back in, then rerun laptop-setup login-manager to finish synchronization'
      return
    fi

    dms greeter status
  fi

  log 'greetd service remains disabled; validate it, then run login-manager-enable'
}

enabled_display_manager() {
  local fragment service
  fragment="$(systemctl show display-manager.service -p FragmentPath --value 2>/dev/null || true)"
  if [[ -n "$fragment" && "$(basename -- "$fragment")" != "$LOGIN_MANAGER_SERVICE" ]]; then
    basename -- "$fragment"
    return
  fi

  for service in gdm.service sddm.service lightdm.service; do
    if systemctl is-enabled "$service" >/dev/null 2>&1; then
      printf '%s\n' "$service"
      return
    fi
  done
}

enable_login_manager() {
  verify_niri_login_session
  if ! $DRY_RUN; then
    package_installed greetd || die 'greetd is missing; run the login-manager phase first'
    package_installed dms-greeter || die 'DMS Greeter is missing; run the login-manager phase first'
  fi

  local conflicting_manager
  conflicting_manager="$(enabled_display_manager || true)"
  [[ -z "$conflicting_manager" ]] ||
    die "$conflicting_manager is enabled; disable it explicitly before enabling greetd"

  if ! $ASSUME_YES && ! confirm 'Enable DMS Greeter and make graphical.target the boot default?'; then
    log 'graphical login activation declined'
    return
  fi

  if $DRY_RUN; then
    run dms greeter enable --yes
    run sudo systemctl enable "$LOGIN_MANAGER_SERVICE"
    run sudo systemctl set-default graphical.target
  else
    dms greeter enable --yes
    sudo systemctl enable "$LOGIN_MANAGER_SERVICE"
    sudo systemctl set-default graphical.target
    dms greeter status
  fi

  log 'graphical login enabled; reboot only after reviewing the README recovery steps'
}
