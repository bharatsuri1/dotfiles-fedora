readonly VOXTYPE_VERSION="0.7.5"
readonly VOXTYPE_REPOSITORY="https://github.com/peteonrails/voxtype"
readonly VOXTYPE_BINARY="$HOME/.local/bin/voxtype"
readonly VOXTYPE_MODEL="base.en"
readonly VOXTYPE_MODEL_FILE="$HOME/.local/share/voxtype/models/ggml-${VOXTYPE_MODEL}.bin"
readonly VOXTYPE_CONFIG_SOURCE="$REPO_ROOT/config/voxtype/config.toml"
readonly VOXTYPE_CONFIG_TARGET="$HOME/.config/voxtype/config.toml"
readonly VOXTYPE_SERVICE_SOURCE="$REPO_ROOT/config/systemd/user/voxtype.service"
readonly VOXTYPE_SERVICE_TARGET="$HOME/.config/systemd/user/voxtype.service"
readonly VOXTYPE_SERVICE_NAME="voxtype.service"
readonly VOXTYPE_RUNTIME_PACKAGES=(
  wtype
)

voxtype_asset_name() {
  case "$(uname -m)" in
    x86_64) printf 'voxtype-%s-linux-x86_64-avx2\n' "$VOXTYPE_VERSION" ;;
    aarch64) printf 'voxtype-%s-linux-aarch64-cpu\n' "$VOXTYPE_VERSION" ;;
    *) return 1 ;;
  esac
}

voxtype_expected_sha256() {
  case "$(uname -m)" in
    x86_64) printf '18ae0510d0c964689f8c9b7119c0b9a45569985e82977dc4f1ef4d76fddd887c\n' ;;
    aarch64) printf 'bf72fbfaae1f4720c25ee0a8e75ec381f6b7811b1e810d80dfb9207f4ebc2e4c\n' ;;
    *) return 1 ;;
  esac
}

voxtype_binary_valid() {
  local expected_sha256
  expected_sha256="$(voxtype_expected_sha256)" || return 1
  [[ -x "$VOXTYPE_BINARY" ]] &&
    printf '%s  %s\n' "$expected_sha256" "$VOXTYPE_BINARY" |
      sha256sum --check --status
}

voxtype_model_present() {
  [[ -f "$VOXTYPE_MODEL_FILE" && -s "$VOXTYPE_MODEL_FILE" ]]
}

install_voxtype_runtime_packages() {
  local -a missing=()
  local package

  for package in "${VOXTYPE_RUNTIME_PACKAGES[@]}"; do
    package_installed "$package" || missing+=("$package")
  done

  if ((${#missing[@]} == 0)); then
    log 'Voxtype runtime packages already installed'
  else
    log "installing Voxtype runtime packages: ${missing[*]}"
    local -a command=(sudo dnf install)
    $ASSUME_YES && command+=(--assumeyes)
    run "${command[@]}" "${missing[@]}"
  fi
}

install_voxtype_binary() {
  local asset_name expected_sha256 url
  asset_name="$(voxtype_asset_name)" ||
    die "Voxtype $VOXTYPE_VERSION supports x86_64 and aarch64; found $(uname -m)"
  expected_sha256="$(voxtype_expected_sha256)"
  url="$VOXTYPE_REPOSITORY/releases/download/v$VOXTYPE_VERSION/$asset_name"

  if voxtype_binary_valid; then
    log "Voxtype $VOXTYPE_VERSION already installed and verified"
    return
  fi

  if [[ -e "$VOXTYPE_BINARY" ]]; then
    die "$VOXTYPE_BINARY exists but is not the pinned Voxtype $VOXTYPE_VERSION binary; move it aside and rerun the voxtype phase"
  fi

  if $DRY_RUN; then
    log "would download, verify, and install Voxtype $VOXTYPE_VERSION for $(uname -m)"
    printf '+ curl -fsSLo <temporary-voxtype> %q\n' "$url"
    printf '+ verify SHA-256 %s for <temporary-voxtype>\n' "$expected_sha256"
    printf '+ install -Dm0755 <temporary-voxtype> %q\n' "$VOXTYPE_BINARY"
    return
  fi

  command -v curl >/dev/null 2>&1 || die 'curl is missing; run the packages phase first'

  local download
  download="$(mktemp)"
  curl -fsSLo "$download" "$url"
  if ! printf '%s  %s\n' "$expected_sha256" "$download" |
    sha256sum --check --status; then
    die "Voxtype $VOXTYPE_VERSION failed SHA-256 verification; downloaded artifact retained at $download"
  fi

  run install -Dm0755 "$download" "$VOXTYPE_BINARY"
  rm -f -- "$download"
  voxtype_binary_valid || die "Voxtype installation did not produce the expected binary: $VOXTYPE_BINARY"
  log "installed and verified Voxtype $VOXTYPE_VERSION at $VOXTYPE_BINARY"
}

install_voxtype_config() {
  link_config "$VOXTYPE_CONFIG_SOURCE" "$VOXTYPE_CONFIG_TARGET"
}

install_voxtype_model() {
  if voxtype_model_present; then
    log "Voxtype model $VOXTYPE_MODEL already present"
    return
  fi

  if $DRY_RUN; then
    log "would download Voxtype Whisper model $VOXTYPE_MODEL"
    printf '+ %q setup --download --model %q --quiet --no-post-install\n' \
      "$VOXTYPE_BINARY" "$VOXTYPE_MODEL"
    return
  fi

  voxtype_binary_valid || die 'Voxtype binary is missing; install the binary before downloading models'
  command -v curl >/dev/null 2>&1 || die 'curl is missing; run the packages phase first'

  log "downloading Voxtype Whisper model $VOXTYPE_MODEL"
  run "$VOXTYPE_BINARY" setup --download --model "$VOXTYPE_MODEL" --quiet --no-post-install
  voxtype_model_present || die "Voxtype model download did not produce $VOXTYPE_MODEL_FILE"
  log "downloaded Voxtype model $VOXTYPE_MODEL"
}

install_voxtype_service() {
  link_config "$VOXTYPE_SERVICE_SOURCE" "$VOXTYPE_SERVICE_TARGET"
  run systemctl --user daemon-reload

  if ! $DRY_RUN && ! systemctl --user cat "$VOXTYPE_SERVICE_NAME" >/dev/null 2>&1; then
    die "$VOXTYPE_SERVICE_NAME is unavailable after linking the unit"
  fi

  attach_niri_service "$VOXTYPE_SERVICE_NAME"

  if $DRY_RUN || systemctl --user is-active graphical-session.target >/dev/null 2>&1; then
    run systemctl --user restart "$VOXTYPE_SERVICE_NAME"
  else
    log 'graphical session is inactive; Voxtype will start with the next niri session'
  fi
}

install_voxtype() {
  install_voxtype_runtime_packages
  install_voxtype_binary
  install_voxtype_config
  install_voxtype_model
  install_voxtype_service
}

show_voxtype_status() {
  printf 'Local speech-to-text (Voxtype):\n'

  local package
  for package in "${VOXTYPE_RUNTIME_PACKAGES[@]}"; do
    if package_installed "$package"; then
      printf '  [ok]       %s\n' "$package"
    else
      printf '  [missing]  %s\n' "$package"
    fi
  done

  if voxtype_binary_valid; then
    printf '  [pinned]   Voxtype %s\n' "$VOXTYPE_VERSION"
  elif [[ -e "$VOXTYPE_BINARY" ]]; then
    printf '  [local]    %s (not the pinned artifact)\n' "$VOXTYPE_BINARY"
  else
    printf '  [missing]  Voxtype %s\n' "$VOXTYPE_VERSION"
  fi

  if [[ -L "$VOXTYPE_CONFIG_TARGET" &&
    "$(readlink -f -- "$VOXTYPE_CONFIG_TARGET")" == "$(readlink -f -- "$VOXTYPE_CONFIG_SOURCE")" ]]; then
    printf '  [linked]   %s\n' "$VOXTYPE_CONFIG_TARGET"
  elif [[ -e "$VOXTYPE_CONFIG_TARGET" ]]; then
    printf '  [local]    %s\n' "$VOXTYPE_CONFIG_TARGET"
  else
    printf '  [missing]  %s\n' "$VOXTYPE_CONFIG_TARGET"
  fi

  if voxtype_model_present; then
    printf '  [present]  model %s\n' "$VOXTYPE_MODEL"
  else
    printf '  [missing]  model %s\n' "$VOXTYPE_MODEL"
  fi

  if [[ -L "$VOXTYPE_SERVICE_TARGET" &&
    "$(readlink -f -- "$VOXTYPE_SERVICE_TARGET")" == "$(readlink -f -- "$VOXTYPE_SERVICE_SOURCE")" ]]; then
    printf '  [linked]   %s\n' "$VOXTYPE_SERVICE_NAME"
  elif [[ -e "$VOXTYPE_SERVICE_TARGET" ]]; then
    printf '  [local]    %s\n' "$VOXTYPE_SERVICE_TARGET"
  else
    printf '  [missing]  %s\n' "$VOXTYPE_SERVICE_NAME"
  fi

  if [[ -L "$HOME/.config/systemd/user/niri.service.wants/$VOXTYPE_SERVICE_NAME" ]]; then
    printf '  [attached] %s\n' "$VOXTYPE_SERVICE_NAME"
  else
    printf '  [detached] %s\n' "$VOXTYPE_SERVICE_NAME"
  fi

  if systemctl --user is-active "$VOXTYPE_SERVICE_NAME" >/dev/null 2>&1; then
    printf '  [active]   %s\n' "$VOXTYPE_SERVICE_NAME"
  else
    printf '  [inactive] %s\n' "$VOXTYPE_SERVICE_NAME"
  fi

  if command -v wtype >/dev/null 2>&1; then
    printf '  [ok]       insertion backend wtype\n'
  else
    printf '  [missing]  insertion backend wtype\n'
  fi

  if command -v wl-copy >/dev/null 2>&1; then
    printf '  [ok]       clipboard fallback wl-copy\n'
  else
    printf '  [missing]  clipboard fallback wl-copy\n'
  fi

  if systemctl --user is-active pipewire.service >/dev/null 2>&1; then
    printf '  [active]   pipewire.service\n'
  else
    printf '  [inactive] pipewire.service\n'
  fi

  if id -nG | tr ' ' '\n' | grep -Fxq input; then
    printf '  [note]     user is in the input group (not required for niri bindings)\n'
  else
    printf '  [ok]       input group not required (niri owns the bindings)\n'
  fi
}
