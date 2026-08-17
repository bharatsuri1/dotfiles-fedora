readonly OLLAMA_INSTALLER_URL="https://ollama.com/install.sh"
readonly OLLAMA_BINARY="/usr/local/bin/ollama"

install_ollama() {
  if [[ -x "$OLLAMA_BINARY" ]] || command -v ollama >/dev/null 2>&1; then
    log "Ollama already installed at $(command -v ollama 2>/dev/null || printf '%s' "$OLLAMA_BINARY")"
    return
  fi

  if $DRY_RUN; then
    log 'would download, inspect, and run the official Ollama installer'
    printf '+ curl -fsSLo <temporary-installer> %q\n' "$OLLAMA_INSTALLER_URL"
    printf '+ sh <temporary-installer>\n'
    return
  fi

  local installer checksum
  installer="$(mktemp)"
  curl -fsSLo "$installer" "$OLLAMA_INSTALLER_URL"
  checksum="$(sha256sum "$installer" | cut -d' ' -f1)"
  log "Ollama installer downloaded to $installer (SHA-256: $checksum)"

  if ! confirm 'Run the official Ollama installer now?'; then
    die "Ollama installation declined; inspect $installer and rerun this phase"
  fi

  sh "$installer"
  rm -f -- "$installer"
  command -v ollama >/dev/null 2>&1 || [[ -x "$OLLAMA_BINARY" ]] \
    || die 'Ollama installer did not produce an ollama binary on PATH'
}
