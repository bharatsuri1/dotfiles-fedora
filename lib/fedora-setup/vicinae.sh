readonly VICINAE_INSTALLER_URL="https://vicinae.com/install.sh"
readonly VICINAE_BINARY="$HOME/.local/bin/vicinae"
readonly VICINAE_PREFIX="$HOME/.local"
readonly VICINAE_SERVICE_NAME="vicinae.service"
readonly VICINAE_SERVICE_INSTALLED="$VICINAE_PREFIX/lib/systemd/user/$VICINAE_SERVICE_NAME"
readonly VICINAE_SERVICE_TARGET="$HOME/.config/systemd/user/$VICINAE_SERVICE_NAME"

vicinae_installed() {
  [[ -x "$VICINAE_BINARY" ]]
}

vicinae_service_linked() {
  [[ -L "$VICINAE_SERVICE_TARGET" ]]
}

install_vicinae() {
  section Vicinae
  if vicinae_installed; then
    log "Vicinae already installed at $VICINAE_BINARY"
  else
    if $DRY_RUN; then
      log 'would download, inspect, and run the official Vicinae installer'
      printf '+ curl -fsSLo <temporary-installer> %q\n' "$VICINAE_INSTALLER_URL"
      printf '+ sh <temporary-installer> --prefix %q\n' "$VICINAE_PREFIX"
      return
    fi

    local installer checksum
    installer="$(mktemp)"
    curl -fsSLo "$installer" "$VICINAE_INSTALLER_URL"
    checksum="$(sha256sum "$installer" | cut -d' ' -f1)"
    log "Vicinae installer downloaded to $installer (SHA-256: $checksum)"

    if ! confirm 'Run the official Vicinae installer now?'; then
      die "Vicinae installation declined; inspect $installer and rerun this phase"
    fi

    sh "$installer" --prefix "$VICINAE_PREFIX"
    rm -f -- "$installer"
    vicinae_installed || die 'Vicinae installer did not produce ~/.local/bin/vicinae'
  fi

  install_vicinae_service
}

# The Vicinae installer places the systemd unit at ~/.local/lib/systemd/user/
# which is not in systemd's user-unit search path.  Symlink it into
# ~/.config/systemd/user/ so the daemon can be enabled and attached to the
# niri session, matching how the other managed services are wired.
install_vicinae_service() {
  if [[ ! -f "$VICINAE_SERVICE_INSTALLED" ]]; then
    log 'Vicinae systemd unit not found; skipping service wiring'
    return
  fi

  if vicinae_service_linked; then
    log "$VICINAE_SERVICE_NAME already linked into ~/.config/systemd/user/"
  else
    run mkdir -p "$(dirname -- "$VICINAE_SERVICE_TARGET")"
    run ln -s "$VICINAE_SERVICE_INSTALLED" "$VICINAE_SERVICE_TARGET"
  fi

  run systemctl --user daemon-reload

  if ! $DRY_RUN && ! systemctl --user cat "$VICINAE_SERVICE_NAME" >/dev/null 2>&1; then
    die "$VICINAE_SERVICE_NAME is unavailable after linking the unit"
  fi

  attach_niri_service "$VICINAE_SERVICE_NAME"

  if $DRY_RUN || systemctl --user is-active graphical-session.target >/dev/null 2>&1; then
    run systemctl --user restart "$VICINAE_SERVICE_NAME"
  else
    log 'graphical session is inactive; Vicinae will start with the next niri session'
  fi
}

show_vicinae_status() {
  section Vicinae

  if vicinae_installed; then
    report ok "$VICINAE_BINARY"
  else
    report missing "$VICINAE_BINARY"
  fi

  if vicinae_service_linked; then
    report linked "$VICINAE_SERVICE_NAME"
  elif [[ -f "$VICINAE_SERVICE_INSTALLED" ]]; then
    report local "$VICINAE_SERVICE_INSTALLED (installer path, not linked to systemd user dir)"
  else
    report missing "$VICINAE_SERVICE_NAME"
  fi

  local vicinae_settings_target="$HOME/.config/vicinae/settings.json"
  local vicinae_settings_source="$REPO_ROOT/config/vicinae/settings.json"
  local vicinae_settings_resolved=""
  if [[ -L "$vicinae_settings_target" ]]; then
    vicinae_settings_resolved="$(readlink -f -- "$vicinae_settings_target" 2>/dev/null || true)"
  fi
  if [[ "$vicinae_settings_resolved" == "$(readlink -f -- "$vicinae_settings_source" 2>/dev/null || true)" ]]; then
    report linked "$vicinae_settings_target"
  elif [[ -e "$vicinae_settings_target" ]]; then
    report local "$vicinae_settings_target"
  else
    report missing "$vicinae_settings_target"
  fi

  if [[ -L "$HOME/.config/systemd/user/niri.service.wants/$VICINAE_SERVICE_NAME" ]]; then
    report ok "$VICINAE_SERVICE_NAME attached to the niri session"
  else
    report missing "$VICINAE_SERVICE_NAME detached from the niri session"
  fi

  if systemctl --user is-active "$VICINAE_SERVICE_NAME" >/dev/null 2>&1; then
    report ok "$VICINAE_SERVICE_NAME"
  else
    report local "$VICINAE_SERVICE_NAME (inactive)"
  fi
}