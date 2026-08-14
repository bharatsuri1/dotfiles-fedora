install_quickshell() {
  local -a missing=()
  local package

  for package in "${QUICKSHELL_PACKAGES[@]}"; do
    package_installed "$package" || missing+=("$package")
  done

  if ((${#missing[@]} == 0)); then
    log 'Quickshell packages already installed'
  else
    log "installing Quickshell packages: ${missing[*]}"
    local -a command=(sudo dnf install)
    $ASSUME_YES && command+=(--assumeyes)
    run "${command[@]}" "${missing[@]}"
  fi
}