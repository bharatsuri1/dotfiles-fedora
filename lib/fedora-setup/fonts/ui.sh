readonly UI_FONT_PACKAGES=(rsms-inter-fonts)

install_ui_fonts() {
  local -a missing=()
  local package

  for package in "${UI_FONT_PACKAGES[@]}"; do
    package_installed "$package" || missing+=("$package")
  done

  if ((${#missing[@]} == 0)); then
    log "$UI_FONT_FAMILY UI font already installed"
  else
    log "installing $UI_FONT_FAMILY UI font: ${missing[*]}"
    local -a command=(sudo dnf install)
    $ASSUME_YES && command+=(--assumeyes)
    run "${command[@]}" "${missing[@]}"
  fi
}
