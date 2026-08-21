install_niri() {
  if package_installed niri; then
    log 'niri already installed'
  else
    log 'installing niri'
    local -a command=(sudo dnf install)
    $ASSUME_YES && command+=(--assumeyes)
    run "${command[@]}" niri
  fi
}
