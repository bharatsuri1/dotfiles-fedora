package_installed() {
  rpm -q --whatprovides "$1" >/dev/null 2>&1
}

install_packages() {
  local -a missing=()
  local package

  for package in "${DNF_PACKAGES[@]}"; do
    package_installed "$package" || missing+=("$package")
  done

  if ((${#missing[@]} == 0)); then
    log 'DNF packages already installed'
  else
    log "installing missing DNF packages: ${missing[*]}"
    local -a command=(sudo dnf install)
    $ASSUME_YES && command+=(--assumeyes)
    run "${command[@]}" "${missing[@]}"
  fi

  if dnf group list --installed 2>/dev/null | grep -Fqi 'Development Tools'; then
    log 'DNF Development Tools group already installed'
  else
    log 'installing the native build toolchain required by Homebrew'
    local -a group_command=(sudo dnf group install development-tools)
    $ASSUME_YES && group_command+=(--assumeyes)
    run "${group_command[@]}"
  fi
}
