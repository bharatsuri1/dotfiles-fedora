install_desktop_graphics() {
  local -a missing=()
  local package

  for package in "${DESKTOP_GRAPHICS_PACKAGES[@]}"; do
    package_installed "$package" || missing+=("$package")
  done

  if ((${#missing[@]} == 0)); then
    log 'desktop graphics and media packages already installed'
  else
    log "installing desktop graphics and media packages: ${missing[*]}"
    local -a command=(sudo dnf install)
    $ASSUME_YES && command+=(--assumeyes)
    run "${command[@]}" "${missing[@]}"
  fi
}

install_desktop_audio() {
  local -a missing=()
  local package

  for package in "${DESKTOP_AUDIO_PACKAGES[@]}"; do
    package_installed "$package" || missing+=("$package")
  done

  if ((${#missing[@]} == 0)); then
    log 'desktop audio packages already installed'
  else
    log "installing desktop audio packages: ${missing[*]}"
    local -a command=(sudo dnf install)
    $ASSUME_YES && command+=(--assumeyes)
    run "${command[@]}" "${missing[@]}"
  fi
}

install_desktop_foundation() {
  install_desktop_graphics
  install_desktop_audio
}
