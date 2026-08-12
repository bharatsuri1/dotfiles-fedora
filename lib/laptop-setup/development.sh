readonly DEVELOPMENT_PACKAGES=(
  mise
  uv
)

install_development_tools() {
  enable_copr jdxcode/mise

  local -a missing=()
  local package
  for package in "${DEVELOPMENT_PACKAGES[@]}"; do
    package_installed "$package" || missing+=("$package")
  done

  if ((${#missing[@]} == 0)); then
    log 'development runtime tools already installed'
  else
    log "installing development runtime tools: ${missing[*]}"
    local -a command=(sudo dnf install)
    $ASSUME_YES && command+=(--assumeyes)
    run "${command[@]}" "${missing[@]}"
  fi
}
