readonly OPENCODE_INSTALLER_URL="https://opencode.ai/v2/install"
readonly OPENCODE_BINARY="$HOME/.opencode/bin/opencode"

install_opencode() {
  if [[ -x "$OPENCODE_BINARY" ]]; then
    log "OpenCode already installed at $OPENCODE_BINARY"
    return
  fi

  if $DRY_RUN; then
    log 'would download and run the official OpenCode v2 installer'
    printf '+ curl -fsSLo <temporary-installer> %q\n' "$OPENCODE_INSTALLER_URL"
    printf '+ bash <temporary-installer> --no-modify-path\n'
    return
  fi

  local installer checksum
  installer="$(mktemp)"
  run curl -fsSLo "$installer" "$OPENCODE_INSTALLER_URL"
  checksum="$(sha256sum "$installer" | cut -d' ' -f1)"
  log "OpenCode installer downloaded to $installer (SHA-256: $checksum)"

  run bash "$installer" --no-modify-path
  run rm -f -- "$installer"
  [[ -x "$OPENCODE_BINARY" ]] || die 'OpenCode installer did not produce ~/.opencode/bin/opencode'
}
