readonly DEVICE_CONTROL_PACKAGES=(
  NetworkManager-tui
  wiremix
)

readonly WLCTL_VERSION="0.1.9"
readonly WLCTL_REPOSITORY="https://github.com/aashish-thapa/wlctl"
readonly WLCTL_BINARY="$HOME/.local/bin/wlctl"

readonly BLUETUI_VERSION="0.8.1"
readonly BLUETUI_REPOSITORY="https://github.com/pythops/bluetui"
readonly BLUETUI_BINARY="$HOME/.local/bin/bluetui"

wlctl_asset_name() {
  case "$(uname -m)" in
    x86_64) printf 'wlctl-x86_64-unknown-linux-musl\n' ;;
    aarch64) printf 'wlctl-aarch64-unknown-linux-musl\n' ;;
    *) return 1 ;;
  esac
}

wlctl_expected_sha256() {
  case "$(uname -m)" in
    x86_64) printf '5b9532a63d87ca7a3790c5f3c6f9a1c727e92321b7e7089c9e034c649210e903\n' ;;
    aarch64) printf '33eb22fdc1665200bcdf59b06a28b17ca27c4f6df34a871ced97120f6b315c40\n' ;;
    *) return 1 ;;
  esac
}

wlctl_binary_valid() {
  local expected_sha256
  expected_sha256="$(wlctl_expected_sha256)" || return 1
  [[ -x "$WLCTL_BINARY" ]] &&
    printf '%s  %s\n' "$expected_sha256" "$WLCTL_BINARY" |
      sha256sum --check --status
}

install_wlctl() {
  local asset_name expected_sha256 url
  asset_name="$(wlctl_asset_name)" ||
    die "wlctl $WLCTL_VERSION supports x86_64 and aarch64; found $(uname -m)"
  expected_sha256="$(wlctl_expected_sha256)"
  url="$WLCTL_REPOSITORY/releases/download/v$WLCTL_VERSION/$asset_name"

  if wlctl_binary_valid; then
    log "wlctl $WLCTL_VERSION already installed and verified"
    return
  fi

  if [[ -e "$WLCTL_BINARY" ]]; then
    die "$WLCTL_BINARY exists but is not the pinned wlctl $WLCTL_VERSION binary; move it aside and rerun the device-controls phase"
  fi

  if $DRY_RUN; then
    log "would download, verify, and install wlctl $WLCTL_VERSION for $(uname -m)"
    printf '+ curl -fsSLo <temporary-wlctl> %q\n' "$url"
    printf '+ verify SHA-256 %s for <temporary-wlctl>\n' "$expected_sha256"
    printf '+ install -Dm0755 <temporary-wlctl> %q\n' "$WLCTL_BINARY"
    return
  fi

  command -v curl >/dev/null 2>&1 || die 'curl is missing; run the packages phase first'

  local download
  download="$(mktemp)"
  curl -fsSLo "$download" "$url"
  if ! printf '%s  %s\n' "$expected_sha256" "$download" |
    sha256sum --check --status; then
    die "wlctl $WLCTL_VERSION failed SHA-256 verification; downloaded artifact retained at $download"
  fi

  run install -Dm0755 "$download" "$WLCTL_BINARY"
  rm -f -- "$download"
  wlctl_binary_valid || die "wlctl installation did not produce the expected binary: $WLCTL_BINARY"
  log "installed and verified wlctl $WLCTL_VERSION at $WLCTL_BINARY"
}

bluetui_asset_name() {
  case "$(uname -m)" in
    x86_64) printf 'bluetui-x86_64-linux-musl\n' ;;
    aarch64) printf 'bluetui-aarch64-linux-musl\n' ;;
    *) return 1 ;;
  esac
}

bluetui_expected_sha256() {
  case "$(uname -m)" in
    x86_64) printf 'c6d133930af3ef85d5fb6492c98982958619284d1f583c2c8ecf46992460d60e\n' ;;
    aarch64) printf '66a5b1dbf5ab5274a05f6926c62bb4bd27601e15a67606c41df625a0a1f1284f\n' ;;
    *) return 1 ;;
  esac
}

bluetui_binary_valid() {
  local expected_sha256
  expected_sha256="$(bluetui_expected_sha256)" || return 1
  [[ -x "$BLUETUI_BINARY" ]] &&
    printf '%s  %s\n' "$expected_sha256" "$BLUETUI_BINARY" |
      sha256sum --check --status
}

install_device_control_packages() {
  local -a missing=()
  local package

  for package in "${DEVICE_CONTROL_PACKAGES[@]}"; do
    package_installed "$package" || missing+=("$package")
  done

  if ((${#missing[@]} == 0)); then
    log 'Fedora device-control packages already installed'
  else
    log "installing Fedora device-control packages: ${missing[*]}"
    local -a command=(sudo dnf install)
    $ASSUME_YES && command+=(--assumeyes)
    run "${command[@]}" "${missing[@]}"
  fi
}

install_bluetui() {
  local asset_name expected_sha256 url
  asset_name="$(bluetui_asset_name)" ||
    die "Bluetui $BLUETUI_VERSION supports x86_64 and aarch64; found $(uname -m)"
  expected_sha256="$(bluetui_expected_sha256)"
  url="$BLUETUI_REPOSITORY/releases/download/v$BLUETUI_VERSION/$asset_name"

  if bluetui_binary_valid; then
    log "Bluetui $BLUETUI_VERSION already installed and verified"
    return
  fi

  if [[ -e "$BLUETUI_BINARY" ]]; then
    die "$BLUETUI_BINARY exists but is not the pinned Bluetui $BLUETUI_VERSION binary; move it aside and rerun the device-controls phase"
  fi

  if $DRY_RUN; then
    log "would download, verify, and install Bluetui $BLUETUI_VERSION for $(uname -m)"
    printf '+ curl -fsSLo <temporary-bluetui> %q\n' "$url"
    printf '+ verify SHA-256 %s for <temporary-bluetui>\n' "$expected_sha256"
    printf '+ install -Dm0755 <temporary-bluetui> %q\n' "$BLUETUI_BINARY"
    return
  fi

  command -v curl >/dev/null 2>&1 || die 'curl is missing; run the packages phase first'

  local download
  download="$(mktemp)"
  curl -fsSLo "$download" "$url"
  if ! printf '%s  %s\n' "$expected_sha256" "$download" |
    sha256sum --check --status; then
    die "Bluetui $BLUETUI_VERSION failed SHA-256 verification; downloaded artifact retained at $download"
  fi

  run install -Dm0755 "$download" "$BLUETUI_BINARY"
  rm -f -- "$download"
  bluetui_binary_valid || die "Bluetui installation did not produce the expected binary: $BLUETUI_BINARY"
  log "installed and verified Bluetui $BLUETUI_VERSION at $BLUETUI_BINARY"
}

install_device_controls() {
  install_device_control_packages
  install_wlctl
  install_bluetui
}

show_device_controls_status() {
  printf 'Standalone device controls:\n'
  local package
  for package in "${DEVICE_CONTROL_PACKAGES[@]}"; do
    if package_installed "$package"; then
      printf '  [ok]       %s\n' "$package"
    else
      printf '  [missing]  %s\n' "$package"
    fi
  done

  if wlctl_binary_valid; then
    printf '  [pinned]   wlctl %s\n' "$WLCTL_VERSION"
  elif [[ -e "$WLCTL_BINARY" ]]; then
    printf '  [local]    %s (not the pinned artifact)\n' "$WLCTL_BINARY"
  else
    printf '  [missing]  wlctl %s\n' "$WLCTL_VERSION"
  fi

  if bluetui_binary_valid; then
    printf '  [pinned]   Bluetui %s\n' "$BLUETUI_VERSION"
  elif [[ -e "$BLUETUI_BINARY" ]]; then
    printf '  [local]    %s (not the pinned artifact)\n' "$BLUETUI_BINARY"
  else
    printf '  [missing]  Bluetui %s\n' "$BLUETUI_VERSION"
  fi

  local service
  for service in NetworkManager.service bluetooth.service; do
    if systemctl is-active "$service" >/dev/null 2>&1; then
      printf '  [active]   %s\n' "$service"
    else
      printf '  [inactive] %s\n' "$service"
    fi
  done
  for service in pipewire.service wireplumber.service; do
    if systemctl --user is-active "$service" >/dev/null 2>&1; then
      printf '  [active]   %s\n' "$service"
    else
      printf '  [inactive] %s\n' "$service"
    fi
  done
}
