readonly OLLAMA_INSTALLER_URL="https://ollama.com/install.sh"
readonly OLLAMA_BINARY="/usr/local/bin/ollama"

# ### Manual uninstall commands ###
# These commands apply to the system-wide installation created by the official
# Ollama installer. Run them only if you decide to remove Ollama.
# The final two removal commands delete downloaded models and user state.
#
# sudo systemctl stop ollama
# sudo systemctl disable ollama
# sudo rm -f /etc/systemd/system/ollama.service
# sudo rm -rf /usr/local/lib/ollama
# sudo rm -f /usr/local/bin/ollama
# sudo userdel ollama
# sudo groupdel ollama
# sudo rm -rf /usr/share/ollama
# rm -rf /home/bharat/.ollama
# sudo systemctl daemon-reload
# ### End manual uninstall commands ###

ensure_ollama_service() {
  local load_state enabled_state
  load_state="$(systemctl show ollama.service -p LoadState --value 2>/dev/null || true)"
  if [[ "$load_state" == masked ]]; then
    die 'ollama.service is masked; review the mask before enabling the service'
  fi
  if [[ "$load_state" != loaded ]]; then
    die 'ollama.service is unavailable; inspect or rerun the official Ollama installer to restore its systemd unit'
  fi

  enabled_state="$(systemctl is-enabled ollama.service 2>/dev/null || true)"
  if [[ "$enabled_state" == enabled ]] && systemctl is-active --quiet ollama.service; then
    log 'Ollama service already enabled and active'
    return
  fi

  log 'enabling and starting the Ollama service'
  run sudo systemctl enable --now ollama.service
  if ! $DRY_RUN; then
    if [[ "$(systemctl is-enabled ollama.service 2>/dev/null || true)" != enabled ]] ||
      ! systemctl is-active --quiet ollama.service; then
      die 'ollama.service did not become enabled and active; inspect systemctl status ollama.service and journalctl -u ollama.service'
    fi
  fi
}

install_ollama() {
  section Ollama
  if [[ -x "$OLLAMA_BINARY" ]] || command -v ollama >/dev/null 2>&1; then
    log "Ollama already installed at $(command -v ollama 2>/dev/null || printf '%s' "$OLLAMA_BINARY")"
    ensure_ollama_service
    return
  fi

  if $DRY_RUN; then
    log 'would download, inspect, and run the official Ollama installer'
    printf '+ curl -fsSLo <temporary-installer> %q\n' "$OLLAMA_INSTALLER_URL"
    printf '+ sh <temporary-installer>\n'
    run sudo systemctl enable --now ollama.service
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
  ensure_ollama_service
}

show_ollama_status() {
  section Ollama
  if command -v ollama >/dev/null 2>&1 || [[ -x "$OLLAMA_BINARY" ]]; then
    report ok "$(command -v ollama 2>/dev/null || printf '%s' "$OLLAMA_BINARY")"
  else
    report missing "$OLLAMA_BINARY"
  fi

  local load_state enabled_state
  load_state="$(systemctl show ollama.service -p LoadState --value 2>/dev/null || true)"
  if [[ "$load_state" != loaded ]]; then
    report missing "ollama.service (${load_state:-unavailable})"
    return
  fi
  report ok 'ollama.service unit loaded'
  enabled_state="$(systemctl is-enabled ollama.service 2>/dev/null || true)"
  if [[ "$enabled_state" == enabled ]]; then
    report ok 'ollama.service enabled'
  else
    report missing "ollama.service enablement (${enabled_state:-unknown}); run fedora-setup ollama"
  fi
  if systemctl is-active --quiet ollama.service; then
    report ok 'ollama.service active'
  else
    report missing 'ollama.service inactive; run fedora-setup ollama'
  fi
}
