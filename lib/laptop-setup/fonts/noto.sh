readonly NOTO_FONT_PACKAGES=(
  google-noto-sans-fonts
  google-noto-serif-fonts
  google-noto-color-emoji-fonts
  google-noto-sans-cjk-fonts
)

install_noto_fonts() {
  local -a missing=()
  local package

  for package in "${NOTO_FONT_PACKAGES[@]}"; do
    package_installed "$package" || missing+=("$package")
  done

  if ((${#missing[@]} == 0)); then
    log 'Noto fallback fonts already installed'
  else
    log "installing Noto fallback fonts: ${missing[*]}"
    local -a command=(sudo dnf install)
    $ASSUME_YES && command+=(--assumeyes)
    run "${command[@]}" "${missing[@]}"
  fi
}
