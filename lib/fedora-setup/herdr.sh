readonly HERDR_INSTALLER_URL="https://herdr.dev/install.sh"
readonly HERDR_BINARY="$HOME/.local/bin/herdr"

install_herdr() {
  if [[ -x "$HERDR_BINARY" ]]; then
    log "Herdr already installed at $HERDR_BINARY"
    return
  fi

  if $DRY_RUN; then
    log 'would download, inspect, and run the official Herdr installer'
    printf '+ curl -fsSLo <temporary-installer> %q\n' "$HERDR_INSTALLER_URL"
    printf '+ sh <temporary-installer>\n'
    return
  fi

  local installer checksum
  installer="$(mktemp)"
  curl -fsSLo "$installer" "$HERDR_INSTALLER_URL"
  checksum="$(sha256sum "$installer" | cut -d' ' -f1)"
  log "Herdr installer downloaded to $installer (SHA-256: $checksum)"

  if ! confirm 'Run the official Herdr installer now?'; then
    die "Herdr installation declined; inspect $installer and rerun this phase"
  fi

  sh "$installer"
  rm -f -- "$installer"
  [[ -x "$HERDR_BINARY" ]] || die 'Herdr installer did not produce ~/.local/bin/herdr'
}
