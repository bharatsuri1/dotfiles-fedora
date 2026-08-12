readonly KEYD_CONFIG_SOURCE="$REPO_ROOT/config/keyd/default.conf"
readonly KEYD_CONFIG_TARGET="/etc/keyd/default.conf"

install_keyd() {
  enable_copr alternateved/keyd

  if package_installed keyd; then
    log 'keyd already installed'
  else
    log 'installing keyd'
    local -a command=(sudo dnf install)
    $ASSUME_YES && command+=(--assumeyes)
    run "${command[@]}" keyd
  fi

  run sudo install -d /etc/keyd
  run sudo install -m 0644 "$KEYD_CONFIG_SOURCE" "$KEYD_CONFIG_TARGET"

  if $DRY_RUN; then
    run sudo systemctl enable --now keyd.service
  elif systemctl is-enabled keyd.service >/dev/null 2>&1 &&
    systemctl is-active keyd.service >/dev/null 2>&1; then
    run sudo systemctl restart keyd.service
  else
    run sudo systemctl enable --now keyd.service
  fi
}
