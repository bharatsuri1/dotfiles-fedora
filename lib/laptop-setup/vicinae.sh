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
  printf 'Vicinae:\n'

  if vicinae_installed; then
    printf '  [ok]      %s\n' "$VICINAE_BINARY"
  else
    printf '  [missing] %s\n' "$VICINAE_BINARY"
  fi

  if vicinae_service_linked; then
    printf '  [linked]  %s\n' "$VICINAE_SERVICE_NAME"
  elif [[ -f "$VICINAE_SERVICE_INSTALLED" ]]; then
    printf '  [local]   %s (installer path, not linked to systemd user dir)\n' "$VICINAE_SERVICE_INSTALLED"
  else
    printf '  [missing] %s\n' "$VICINAE_SERVICE_NAME"
  fi

  if [[ -L "$HOME/.config/systemd/user/niri.service.wants/$VICINAE_SERVICE_NAME" ]]; then
    printf '  [attached] %s\n' "$VICINAE_SERVICE_NAME"
  else
    printf '  [detached] %s\n' "$VICINAE_SERVICE_NAME"
  fi

  if systemctl --user is-active "$VICINAE_SERVICE_NAME" >/dev/null 2>&1; then
    printf '  [active]   %s\n' "$VICINAE_SERVICE_NAME"
  else
    printf '  [inactive] %s\n' "$VICINAE_SERVICE_NAME"
  fi
}