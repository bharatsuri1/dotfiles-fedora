readonly VOXTYPE_VERSION="0.7.5"
readonly VOXTYPE_REPOSITORY="https://github.com/peteonrails/voxtype"
readonly VOXTYPE_BINARY="$HOME/.local/bin/voxtype"
readonly VOXTYPE_OSD_BINARY="$HOME/.local/bin/voxtype-osd-gtk4"
readonly VOXTYPE_OSD_WRAPPER_BINARY="$HOME/.local/bin/voxtype-osd"
readonly VOXTYPE_MODEL="base.en"
readonly VOXTYPE_MODEL_FILE="$HOME/.local/share/voxtype/models/ggml-${VOXTYPE_MODEL}.bin"
readonly VOXTYPE_MODEL_REVISION="5359861c739e955e79d9a303bcbc70fb988958b1"
readonly VOXTYPE_MODEL_SHA256="a03779c86df3323075f5e796cb2ce5029f00ec8869eee3fdfb897afe36c6d002"
readonly VOXTYPE_MODEL_URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/${VOXTYPE_MODEL_REVISION}/ggml-${VOXTYPE_MODEL}.bin"
readonly VOXTYPE_CONFIG_SOURCE="$REPO_ROOT/config/voxtype/config.toml"
readonly VOXTYPE_CONFIG_TARGET="$HOME/.config/voxtype/config.toml"
readonly VOXTYPE_SERVICE_SOURCE="$REPO_ROOT/config/systemd/user/voxtype.service"
readonly VOXTYPE_SERVICE_TARGET="$HOME/.config/systemd/user/voxtype.service"
readonly VOXTYPE_SERVICE_NAME="voxtype.service"
readonly VOXTYPE_NIRI_CONFIG="$HOME/.config/niri/config.kdl"
readonly VOXTYPE_RUNTIME_PACKAGES=(
  wtype
  gtk4-layer-shell
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

voxtype_osd_asset_name() {
  case "$(uname -m)" in
    x86_64) printf 'voxtype-%s-linux-x86_64-osd-gtk4\n' "$VOXTYPE_VERSION" ;;
    *) return 1 ;;
  esac
}

voxtype_osd_expected_sha256() {
  case "$(uname -m)" in
    x86_64) printf 'fed81695551cee95bb0fd376ec6dc49638b0fd714480504d78aa597b006a5952\n' ;;
    *) return 1 ;;
  esac
}

voxtype_osd_wrapper_asset_name() {
  case "$(uname -m)" in
    x86_64) printf 'voxtype-%s-linux-x86_64-osd\n' "$VOXTYPE_VERSION" ;;
    *) return 1 ;;
  esac
}

voxtype_osd_wrapper_expected_sha256() {
  case "$(uname -m)" in
    x86_64) printf 'c510388dff6a69b59055a1915830fee8e0cb5aafd8f065e3e382b78a84eebab7\n' ;;
    *) return 1 ;;
  esac
}

voxtype_osd_binary_valid() {
  local expected_sha256
  expected_sha256="$(voxtype_osd_expected_sha256)" || return 1
  [[ -x "$VOXTYPE_OSD_BINARY" ]] &&
    printf '%s  %s\n' "$expected_sha256" "$VOXTYPE_OSD_BINARY" |
      sha256sum --check --status
}

voxtype_osd_wrapper_binary_valid() {
  local expected_sha256
  expected_sha256="$(voxtype_osd_wrapper_expected_sha256)" || return 1
  [[ -x "$VOXTYPE_OSD_WRAPPER_BINARY" ]] &&
    printf '%s  %s\n' "$expected_sha256" "$VOXTYPE_OSD_WRAPPER_BINARY" |
      sha256sum --check --status
}

voxtype_binary_valid() {
  local expected_sha256
  expected_sha256="$(voxtype_expected_sha256)" || return 1
  [[ -x "$VOXTYPE_BINARY" ]] &&
    printf '%s  %s\n' "$expected_sha256" "$VOXTYPE_BINARY" |
      sha256sum --check --status
}

voxtype_model_valid() {
  [[ -f "$VOXTYPE_MODEL_FILE" ]] &&
    printf '%s  %s\n' "$VOXTYPE_MODEL_SHA256" "$VOXTYPE_MODEL_FILE" |
      sha256sum --check --status
}

voxtype_niri_binding_present() {
  [[ -r "$VOXTYPE_NIRI_CONFIG" ]] &&
    grep -Eq '^[[:space:]]*Mod\+Ctrl\+Alt\+Shift\+S[[:space:]].*spawn "voxtype" "record" "toggle"' \
      "$VOXTYPE_NIRI_CONFIG"
}

voxtype_cancel_key_configured() {
  [[ -r "$VOXTYPE_CONFIG_TARGET" ]] &&
    grep -Eq '^[[:space:]]*enabled[[:space:]]*=[[:space:]]*true[[:space:]]*$' \
      "$VOXTYPE_CONFIG_TARGET" &&
    grep -Eq '^[[:space:]]*cancel_key[[:space:]]*=[[:space:]]*"ESC"[[:space:]]*$' \
      "$VOXTYPE_CONFIG_TARGET"
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

install_voxtype_osd_asset() {
  local asset_name expected_sha256 url target label
  asset_name="$1"
  expected_sha256="$2"
  target="$3"
  label="$4"
  url="$VOXTYPE_REPOSITORY/releases/download/v$VOXTYPE_VERSION/$asset_name"

  if [[ -x "$target" ]] &&
    printf '%s  %s\n' "$expected_sha256" "$target" | sha256sum --check --status; then
    log "Voxtype OSD $label already installed and verified"
    return
  fi

  if [[ -e "$target" ]]; then
    die "$target exists but is not the pinned Voxtype $VOXTYPE_VERSION OSD $label; move it aside and rerun the voxtype phase"
  fi

  if $DRY_RUN; then
    log "would download, verify, and install Voxtype OSD $label for $(uname -m)"
    printf '+ curl -fsSLo <temporary-osd> %q\n' "$url"
    printf '+ verify SHA-256 %s for <temporary-osd>\n' "$expected_sha256"
    printf '+ install -Dm0755 <temporary-osd> %q\n' "$target"
    return
  fi

  command -v curl >/dev/null 2>&1 || die 'curl is missing; run the packages phase first'

  local download
  download="$(mktemp)"
  curl -fsSLo "$download" "$url"
  if ! printf '%s  %s\n' "$expected_sha256" "$download" |
    sha256sum --check --status; then
    die "Voxtype OSD $label failed SHA-256 verification; downloaded artifact retained at $download"
  fi

  run install -Dm0755 "$download" "$target"
  rm -f -- "$download"
  printf '%s  %s\n' "$expected_sha256" "$target" | sha256sum --check --status ||
    die "Voxtype OSD $label installation did not produce the expected binary: $target"
  log "installed and verified Voxtype OSD $label at $target"
}

install_voxtype_osd_binary() {
  local asset_name expected_sha256
  asset_name="$(voxtype_osd_asset_name)" || {
    log "Voxtype $VOXTYPE_VERSION has no OSD frontend asset for $(uname -m); skipping the waveform OSD"
    return
  }
  expected_sha256="$(voxtype_osd_expected_sha256)"
  install_voxtype_osd_asset "$asset_name" "$expected_sha256" "$VOXTYPE_OSD_BINARY" "frontend (gtk4)"

  asset_name="$(voxtype_osd_wrapper_asset_name)" || return
  expected_sha256="$(voxtype_osd_wrapper_expected_sha256)"
  install_voxtype_osd_asset "$asset_name" "$expected_sha256" "$VOXTYPE_OSD_WRAPPER_BINARY" "wrapper"
}

install_voxtype_config() {
  link_config "$VOXTYPE_CONFIG_SOURCE" "$VOXTYPE_CONFIG_TARGET"
}

install_voxtype_input_access() {
  local current_user
  current_user="$(id -un)"

  if id -nG "$current_user" | tr ' ' '\n' | grep -Fxq input; then
    log "$current_user already belongs to the input group"
    return
  fi

  log "granting $current_user input-group access for Voxtype's state-aware cancel key"
  run sudo usermod --append --groups input "$current_user"
  log 'input-group changes take effect after logout or reboot'
}

install_voxtype_model() {
  if voxtype_model_valid; then
    log "Voxtype model $VOXTYPE_MODEL already installed and verified"
    return
  fi

  if [[ -e "$VOXTYPE_MODEL_FILE" ]]; then
    die "$VOXTYPE_MODEL_FILE exists but does not match the pinned model; move it aside and rerun the voxtype phase"
  fi

  if $DRY_RUN; then
    log "would download, verify, and install Voxtype Whisper model $VOXTYPE_MODEL"
    printf '+ curl -fsSLo <temporary-model> %q\n' "$VOXTYPE_MODEL_URL"
    printf '+ verify SHA-256 %s for <temporary-model>\n' "$VOXTYPE_MODEL_SHA256"
    printf '+ install -Dm0644 <temporary-model> %q\n' "$VOXTYPE_MODEL_FILE"
    return
  fi

  command -v curl >/dev/null 2>&1 || die 'curl is missing; run the packages phase first'

  local download
  download="$(mktemp)"
  curl -fsSLo "$download" "$VOXTYPE_MODEL_URL"
  if ! printf '%s  %s\n' "$VOXTYPE_MODEL_SHA256" "$download" |
    sha256sum --check --status; then
    die "Voxtype model $VOXTYPE_MODEL failed SHA-256 verification; downloaded artifact retained at $download"
  fi

  run install -Dm0644 "$download" "$VOXTYPE_MODEL_FILE"
  rm -f -- "$download"
  voxtype_model_valid || die "Voxtype installation did not produce the expected model: $VOXTYPE_MODEL_FILE"
  log "installed and verified Voxtype model $VOXTYPE_MODEL"
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
  section Voxtype
  install_voxtype_runtime_packages
  install_voxtype_binary
  install_voxtype_osd_binary
  install_voxtype_config
  install_voxtype_input_access
  install_voxtype_model
  install_voxtype_service
}

show_voxtype_status() {
  section Voxtype

  local package
  for package in "${VOXTYPE_RUNTIME_PACKAGES[@]}"; do
    if package_installed "$package"; then
      report ok "$package"
    else
      report missing "$package"
    fi
  done

  if voxtype_binary_valid; then
    report pinned "Voxtype $VOXTYPE_VERSION"
  elif [[ -e "$VOXTYPE_BINARY" ]]; then
    report local "$VOXTYPE_BINARY (not the pinned artifact)"
  else
    report missing "Voxtype $VOXTYPE_VERSION"
  fi

  if voxtype_osd_binary_valid; then
    report pinned 'Voxtype OSD frontend (gtk4)'
  elif [[ -e "$VOXTYPE_OSD_BINARY" ]]; then
    report local "$VOXTYPE_OSD_BINARY (not the pinned artifact)"
  else
    report missing 'Voxtype OSD frontend (gtk4)'
  fi

  if voxtype_osd_wrapper_binary_valid; then
    report pinned 'Voxtype OSD wrapper'
  elif [[ -e "$VOXTYPE_OSD_WRAPPER_BINARY" ]]; then
    report local "$VOXTYPE_OSD_WRAPPER_BINARY (not the pinned artifact)"
  else
    report missing 'Voxtype OSD wrapper'
  fi

  if [[ -L "$VOXTYPE_CONFIG_TARGET" &&
    "$(readlink -f -- "$VOXTYPE_CONFIG_TARGET")" == "$(readlink -f -- "$VOXTYPE_CONFIG_SOURCE")" ]]; then
    report linked "$VOXTYPE_CONFIG_TARGET"
  elif [[ -e "$VOXTYPE_CONFIG_TARGET" ]]; then
    report local "$VOXTYPE_CONFIG_TARGET"
  else
    report missing "$VOXTYPE_CONFIG_TARGET"
  fi

  if voxtype_model_valid; then
    report pinned "model $VOXTYPE_MODEL"
  elif [[ -e "$VOXTYPE_MODEL_FILE" ]]; then
    report missing "model $VOXTYPE_MODEL (checksum mismatch)"
  else
    report missing "model $VOXTYPE_MODEL"
  fi

  if [[ -L "$VOXTYPE_SERVICE_TARGET" &&
    "$(readlink -f -- "$VOXTYPE_SERVICE_TARGET")" == "$(readlink -f -- "$VOXTYPE_SERVICE_SOURCE")" ]]; then
    report linked "$VOXTYPE_SERVICE_NAME"
  elif [[ -e "$VOXTYPE_SERVICE_TARGET" ]]; then
    report local "$VOXTYPE_SERVICE_TARGET"
  else
    report missing "$VOXTYPE_SERVICE_NAME"
  fi

  if [[ -L "$HOME/.config/systemd/user/niri.service.wants/$VOXTYPE_SERVICE_NAME" ]]; then
    report ok "$VOXTYPE_SERVICE_NAME attached to the niri session"
  else
    report missing "$VOXTYPE_SERVICE_NAME detached from the niri session"
  fi

  if systemctl --user is-active "$VOXTYPE_SERVICE_NAME" >/dev/null 2>&1; then
    report ok "$VOXTYPE_SERVICE_NAME"
  else
    report local "$VOXTYPE_SERVICE_NAME (inactive)"
  fi

  if command -v wtype >/dev/null 2>&1; then
    report ok 'insertion backend wtype'
  else
    report missing 'insertion backend wtype'
  fi

  if command -v wl-copy >/dev/null 2>&1; then
    report ok 'clipboard fallback wl-copy'
  else
    report missing 'clipboard fallback wl-copy'
  fi

  if systemctl --user is-active pipewire.service >/dev/null 2>&1; then
    report ok 'pipewire.service'
  else
    report local 'pipewire.service (inactive)'
  fi

  if command -v wpctl >/dev/null 2>&1 &&
    wpctl inspect '@DEFAULT_AUDIO_SOURCE@' >/dev/null 2>&1; then
    report ok 'default microphone source'
  else
    report missing 'default microphone source'
  fi

  if voxtype_niri_binding_present; then
    report ok 'niri Hyper+S toggle binding'
  else
    report missing 'niri Hyper+S toggle binding'
  fi

  if voxtype_cancel_key_configured; then
    report ok 'Voxtype state-aware Escape cancellation'
  else
    report missing 'Voxtype state-aware Escape cancellation'
  fi

  if id -nG | tr ' ' '\n' | grep -Fxq input; then
    report ok 'input group (required for Escape listener)'
  else
    report missing 'input group (log out after running the voxtype phase)'
  fi
}
