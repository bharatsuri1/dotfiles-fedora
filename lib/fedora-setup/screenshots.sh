readonly SCREENSHOT_PACKAGES=(
  grim
  slurp
  libnotify
  procps-ng
  util-linux-core
  wl-clipboard
)

readonly TENSAKU_APP_ID="dev.tensaku.Tensaku"
readonly TENSAKU_VERSION="0.26.6"
readonly TENSAKU_ARCH="x86_64"
readonly TENSAKU_COMMIT="318fb27b3debdaf26498332fb20e3f1f99363fca04e0f0bcbd6f2c674f0f7bd4"
readonly TENSAKU_BUNDLE="$REPO_ROOT/assets/tensaku-v${TENSAKU_VERSION}.flatpak"
readonly TENSAKU_BUNDLE_SHA256="a38d6b29c62916791305842d1ee066b580f1d7063c3f9182faad79c081c2a423"

tensaku_bundle_valid() {
  [[ -r "$TENSAKU_BUNDLE" ]] &&
    printf '%s  %s\n' "$TENSAKU_BUNDLE_SHA256" "$TENSAKU_BUNDLE" |
      sha256sum --check --status
}

tensaku_installed() {
  command -v flatpak >/dev/null 2>&1 || return 1
  [[ "$(flatpak info --user --show-commit "$TENSAKU_APP_ID" 2>/dev/null || true)" == "$TENSAKU_COMMIT" ]]
}

install_tensaku() {
  command -v flatpak >/dev/null 2>&1 || die 'Flatpak is missing; run the packages phase first'
  [[ "$(uname -m)" == "$TENSAKU_ARCH" ]] ||
    die "managed Tensaku bundle only supports $TENSAKU_ARCH; found $(uname -m)"
  [[ -r "$TENSAKU_BUNDLE" ]] || die "managed Tensaku bundle is missing: $TENSAKU_BUNDLE"

  if ! $DRY_RUN && ! tensaku_bundle_valid; then
    die "managed Tensaku bundle failed SHA-256 verification: $TENSAKU_BUNDLE"
  fi

  if tensaku_installed; then
    log "Tensaku $TENSAKU_VERSION already installed from the managed bundle"
    return
  fi

  if $DRY_RUN; then
    log "would verify and install Tensaku $TENSAKU_VERSION from the managed bundle"
    printf '+ verify SHA-256 %s for %q\n' "$TENSAKU_BUNDLE_SHA256" "$TENSAKU_BUNDLE"
    printf '+ flatpak install --user --or-update %q\n' "$TENSAKU_BUNDLE"
    return
  fi

  local -a command=(flatpak install --user --or-update)
  $ASSUME_YES && command+=(--noninteractive)
  run "${command[@]}" "$TENSAKU_BUNDLE"

  tensaku_installed || die "Tensaku installation did not produce the expected commit: $TENSAKU_COMMIT"
}

install_screenshots() {
  local -a missing=()
  local package

  for package in "${SCREENSHOT_PACKAGES[@]}"; do
    package_installed "$package" || missing+=("$package")
  done

  if ((${#missing[@]} == 0)); then
    log 'screenshot capture packages already installed'
  else
    log "installing screenshot capture packages: ${missing[*]}"
    local -a command=(sudo dnf install)
    $ASSUME_YES && command+=(--assumeyes)
    run "${command[@]}" "${missing[@]}"
  fi

  install_tensaku
}
