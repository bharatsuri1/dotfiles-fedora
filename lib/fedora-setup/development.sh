readonly DEVELOPMENT_PACKAGES=(
  mise
  uv
)

readonly NPM_GLOBAL_PACKAGES=(
  @earendil-works/pi-coding-agent
  @openai/codex
  opencode-ai
)

npm_global_package_installed() {
  mise exec node@latest -- npm list --global --depth=0 "$1" >/dev/null 2>&1
}

install_npm_global_tools() {
  local package
  for package in "${NPM_GLOBAL_PACKAGES[@]}"; do
    if npm_global_package_installed "$package"; then
      log "$package already installed through Mise-managed npm"
    elif [[ "$package" == @earendil-works/pi-coding-agent ]]; then
      run mise exec node@latest -- npm install --global --ignore-scripts "$package"
    else
      run mise exec node@latest -- npm install --global "$package"
    fi
  done
}

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

  if $DRY_RUN || command -v mise >/dev/null 2>&1; then
    run mise install node@latest
    install_npm_global_tools
  else
    die 'Mise installation did not produce a mise executable'
  fi
}
